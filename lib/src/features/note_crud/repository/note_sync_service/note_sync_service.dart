import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';
import 'package:thoughtbook/src/features/note_crud/repository/cloud_note_service/firestore_notes_service.dart';
import 'package:thoughtbook/src/features/note_crud/repository/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_change_helper.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_change_sync_helper.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_exceptions.dart';

/// Service used to keep the local and cloud databases up to date with the latest changes in notes.
/// Works only when a user is signed in to the application.
class NoteSyncService {
  /// A getter which returns the device's current internet connection status
  Future<bool> get hasInternetConnection async =>
      await InternetConnectionChecker().hasConnection;

  AuthUser get authUser => AuthService.firebase().currentUser!;

  // A StreamQueue to handle the local change feed stream
  late StreamQueue<NoteChange> _changeFeedQueue;
  late StreamQueue<Iterable<CloudNote>> _firestoreNotesSnapshots;

  static final NoteSyncService _shared = NoteSyncService._sharedInstance();

  factory NoteSyncService() => _shared;

  NoteSyncService._sharedInstance() {
    // Sets up the local change feed stream as a StreamQueue, with debounced events
    _changeFeedQueue = StreamQueue<NoteChange>(
      LocalNoteService().getNoteChangeFeed.transform(
        StreamTransformer.fromHandlers(
          handleData: (change, sink) {
            sink.add(change);
          },
        ),
      ),
    );
    _firestoreNotesSnapshots = StreamQueue<Iterable<CloudNote>>(
      FirestoreNoteService().allNotes(
        ownerUserId: authUser.id,
      ),
    );
  }

  /// Should be called after the first user login to retrieve notes from the Firestore collection.
  ///
  /// Returns a [Stream] indicating the progress, in percentage, of the operation.
  Stream<int> initLocalNotes() async* {
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

    final int cloudNotesCount = notes.length;
    int loadedCount = 0;
    // Load all notes from Firestore belonging to the user to Isar database locally
    for (LocalNote note in notes) {
      LocalNote newNote =
          await LocalNoteService().createNote(addToChangeFeed: false);
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

      loadedCount++;
      yield ((loadedCount * 100) ~/ cloudNotesCount);
    }
  }

  /// Helper method which will set up background workers to sync notes while the app is
  /// running.
  Future<void> setup() async {
    log(
      '[1/4] Starting sync service...',
      name: 'NoteSyncService',
    );
    unawaited(handleLocalChangeFeed());
    log(
      '[2/4] Started LocalNote change-feed handler.',
      name: 'NoteSyncService',
    );
    unawaited(syncLocalChangeFeed());
    log(
      '[3/4] Started local change-feed sync worker.',
      name: 'NoteSyncService',
    );
    unawaited(syncCloudToLocal());
    log(
      '[4/4] Started cloud to local sync worker.',
      name: 'NoteSyncService',
    );
  }

  // TODO: WIP!!
  // Create a StreamQueue to store events from the Firestore collection [DONE!]
  // If local changeFeed is empty, then procced to sync
  /// Responsible for retrieving changes from the Firestore notes collection to the local database.
  Future<void> syncCloudToLocal() async {
    _ensureUserIsSignedInOrThrow();
  }

  /// Responsible for syncing the changes from the change-feed collection to the Firestore notes collection.
  Future<void> syncLocalChangeFeed() async {
    _ensureUserIsSignedInOrThrow();

    late Stream<void> changeCollectionEvent;
    while (true) {
      bool changesPending = !(await NoteChangeHelper().isCollectionEmpty);
      if (changesPending) {
        if (await InternetConnectionChecker().hasConnection) {
          try {
            NoteChange change =
                await NoteChangeHelper().getOldestChangeAndDelete();
            await NoteChangeSyncHelper().syncOrIgnoreLocalChange(
              change: change,
              ownerUserId: authUser.id,
            );
          } on CouldNotFindChangeException {
            log(
              'Could not find change to sync.',
              name: 'NoteSyncService',
            );
          } on CouldNotDeleteChangeSyncException {
            // empty
          }
        } else {
          log(
            'Internet connection not detected. Pausing sync.',
            name: 'NoteSyncService',
          );
          Stream<InternetConnectionStatus> connectionStream =
              InternetConnectionChecker().onStatusChange.asBroadcastStream();
          await for (InternetConnectionStatus status in connectionStream) {
            if (status == InternetConnectionStatus.connected) {
              await connectionStream.listen((event) {}).cancel();
              break;
            }
          }
        }
      } else {
        log(
          'No changes to sync.',
          name: 'NoteSyncService',
        );
        changeCollectionEvent = await NoteChangeHelper().eventNotifier
          ..asBroadcastStream();
        await for (void _ in changeCollectionEvent) {
          log('changeCollectionEvent fired');
          break;
        }
      }
    }
  }

  /// Responsible for listening for [NoteChange] and adding them to the change feed collection.
  Future<void> handleLocalChangeFeed() async {
    _ensureUserIsSignedInOrThrow();
    while (true) {
      try {
        NoteChange change = await _changeFeedQueue.next;
        log('local change: ${change.type}');
        if (change.type == NoteChangeType.create) {
          await NoteChangeHelper().handleCreateChange(change: change);
        } else if (change.type == NoteChangeType.update) {
          await NoteChangeHelper().handleUpdateChange(change: change);
        } else if (change.type == NoteChangeType.delete) {
          await NoteChangeHelper().handleDeleteChange(change: change);
        } else {
          log('Invalid NoteChangeType of value ${change.type.toString()}');
        }
      } on StateError {
        throw NoteFeedClosedSyncException();
      }
    }
  }

  void _ensureUserIsSignedInOrThrow() {
    final currentUser = AuthService.firebase().currentUser;
    if (currentUser == null) {
      throw UserNotLoggedInSyncException();
    }
  }
}

enum NoteChangeType {
  create,
  update,
  delete,
}
