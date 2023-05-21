import 'dart:async';
import 'dart:developer';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:async/async.dart';
import 'package:thoughtbook/src/features/authentication/application/auth_service.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/note_crud/application/cloud_note_service/firestore_notes_service.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';

/// Service used to keep the local and cloud databases up to date with the latest changes in notes.
/// Works only when a user is signed in to the application.
class NoteSyncService {
  NoteSyncService._sharedInstance() {
    _ensureNoteChangeCollectionIsOpen();
    _changeFeedQueue = StreamQueue<NoteChange>(
      LocalNoteService().getNoteChangeFeed,
    );
  }

  static final NoteSyncService _shared = NoteSyncService._sharedInstance();

  factory NoteSyncService() => _shared;

  Isar? _isar;

  IsarCollection<NoteChange> get _getNotesCollection => _isar!.noteChanges;

  AuthUser get authUser => AuthService.firebase().currentUser!;

  late StreamQueue<NoteChange> _changeFeedQueue;

  /// Should be called after the first user login to retrieve notes from the cloud database
  Future<void> initLocalNotes() async {
    _ensureUserIsSignedInOrThrow();

    // Take first event from the stream, and map each element from CloudNote to LocalNote
    Iterable<LocalNote> notes = await FirestoreNoteService()
        .allNotes(ownerUserId: authUser.id)
        .first
        .then(
          (notesIterable) => notesIterable.map(
            (note) => LocalNote.fromCloudNote(note),
          ),
        );
    // Load all notes from Firestore belonging to the user to Isar database locally
    for (LocalNote note in notes) {
      await LocalNoteService().createNote(addToChangeFeed: false).then(
        (LocalNote newNote) async {
          await LocalNoteService().updateNote(
            isarId: newNote.isarId,
            cloudDocumentId: note.cloudDocumentId,
            title: note.title,
            content: note.content,
            color: note.color,
            created: note.created,
            modified: note.modified,
            isSyncedWithCloud: true,
            addToChangeFeed: false,
          );
        },
      );
    }
  }

  /// Responsible for syncing any pending changes in the local database with the cloud.
  /// Listens for changes within the local database.
  ///
  /// Runs when the application is in foreground &
  /// also in background if any changes are pending to be synced
  Future<void> syncLocalToCloud() async {
    _ensureUserIsSignedInOrThrow();
    Stream<InternetConnectionStatus> connectionStatusStream =
        InternetConnectionChecker().onStatusChange;

    while (true) {
      while (await connectionStatusStream.first ==
          InternetConnectionStatus.connected) {
        try {
          NoteChange change = await _changeFeedQueue.next;
          log("local change: ${change.type}");

          switch (change.type) {
            case NoteChangeType.create:
              await _handleLocalCreate(change);
              break;
            case NoteChangeType.update:
              await _handleLocalUpdate(change);
              break;
            case NoteChangeType.delete:
              await _handleLocalDelete(change);
              break;
          }
        } on StateError {
          throw NoteFeedClosedSyncException();
        }
      }
    }
  }

  /// Responsible for retrieving changes from the cloud to the local database.
  ///
  /// Runs when the application is in foreground,
  /// runs on the start of every application session,
  /// and also runs as a background service.
  ///
  /// Can be triggered manuallly by the user within the application
  /// and can be prevented from running in the background by the user.
  Future<void> syncCloudToLocal() async {
    _ensureUserIsSignedInOrThrow();
  }

  /// Private helper method to sync a locally created note with the cloud.
  Future<void> _handleLocalCreate(NoteChange change) async {
    LocalNote localNote;
    try {
      localNote = await LocalNoteService().getNote(id: change.isarId!);
    } catch (e) {
      throw CouldNotFindNote();
    }

    // Create a new note in the Firestore collection
    final CloudNote newCloudNote = await FirestoreNoteService().createNewNote(
      ownerUserId: authUser.id,
    );

    // Set the correct metadata for the new note in the Firestore collection
    await FirestoreNoteService().updateNote(
      documentId: newCloudNote.documentId,
      title: localNote.title,
      content: localNote.content,
      color: localNote.color,
      created: localNote.created,
      modified: localNote.modified,
    );

    // Update the cloudDocumentId field for the corresponding LocalNote
    // and mark it as synced with the cloud

    // The local note is fetched again as its possible that the old version got outdated between async operations
    try {
      localNote = await LocalNoteService().getNote(id: localNote.isarId);
    } on CouldNotFindNote {
      log("Could not find local note with isarId=${change.isarId!} to sync local create.");
      return;
    }

    await LocalNoteService().updateNote(
      isarId: localNote.isarId,
      cloudDocumentId: newCloudNote.documentId,
      isSyncedWithCloud: true,
      title: localNote.title,
      content: localNote.content,
      color: localNote.color,
      addToChangeFeed: false,
    );

    log("New note with isarId=${change.isarId} synced with cloud");
  }

  /// Private helper method to sync a locally updated note with the cloud.
  Future<void> _handleLocalUpdate(NoteChange change) async {
    LocalNote localNote;
    try {
      localNote = await LocalNoteService().getNote(id: change.isarId!);
    } catch (e) {
      // The note could have been deleted locally by the user by the time the
      // previous update operation gets processed for syncing.
      // throw CouldNotFindNote();
      log("Could not find local note with isarId=${change.isarId!} to sync local update.");
      return;
    }

    // If no cloudId was passed, then return
    if (localNote.cloudDocumentId == null ||
        localNote.cloudDocumentId!.isEmpty) {
      log("cloudDocumentId field found to be null in NoteChange instance. Cannot proceed to sync local update operation.");
      return;
    } else {
      log('Syncing note with cloudId=${localNote.cloudDocumentId!}');
    }

    // Check if the local change is outdated
    final cloudNote = await FirestoreNoteService()
        .getNote(cloudDocumentId: localNote.cloudDocumentId!);
    if (cloudNote.modified.toDate().isAfter(localNote.modified)) {
      log("Local change to note with isarId=${localNote.isarId} is outdated. Ignoring sync.");

      // Mark corresponding LocalNote as synced with cloud
      await LocalNoteService().updateNote(
        isarId: localNote.isarId,
        isSyncedWithCloud: true,
        title: localNote.title,
        content: localNote.content,
        color: localNote.color,
        addToChangeFeed: false,
      );
      return;
    }

    // Update the note in the Firestore collection
    await FirestoreNoteService().updateNote(
      documentId: localNote.cloudDocumentId!,
      title: localNote.title,
      content: localNote.content,
      color: localNote.color,
      created: localNote.created,
      modified: localNote.modified,
    );

    // Mark corresponding LocalNote as synced with cloud
    try {
      await LocalNoteService().markNoteAsSynced(isarId: localNote.isarId);
    } on CouldNotUpdateNote {
      log(
        name: "NoteSync",
        "Something went wrong. Could not find LocalNote to mark it as synced.",
      );
      return;
    }
    log("Note with isarId=${change.isarId} synced with cloud");
  }

  /// Private helper method to sync a locally deleted note with the cloud.
  Future<void> _handleLocalDelete(NoteChange change) async {
    if (change.cloudDocumentId == null) {
      log("cloudDocumentId field found to be null in NoteChange instance. Cannot proceed to sync local delete operation");
      return;
    }

    await FirestoreNoteService()
        .deleteNote(documentId: change.cloudDocumentId!);

    log("Deleted localNote with isarId=${change.isarId} from cloud");
  }

  void _ensureUserIsSignedInOrThrow() {
    final currentUser = AuthService.firebase().currentUser;
    if (currentUser == null) {
      throw UserNotLoggedInSyncException();
    }
  }

  Future<void> open() async {
    if (_isar != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [NoteChangeSchema],
        directory: docsPath.path,
        inspector: true,
      );
      _isar = isar;
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> _ensureNoteChangeCollectionIsOpen() async {
    try {
      await _openNoteChangeCollection();
    } on CollectionAlreadyOpenException {
      // empty
    }
  }

  Future<void> _openNoteChangeCollection() async {}
}

class NoteFeedClosedSyncException implements Exception {}

class UserNotLoggedInSyncException implements Exception {}

class CollectionAlreadyOpenException implements Exception {}

enum NoteChangeType {
  create,
  update,
  delete,
}
