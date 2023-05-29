import 'dart:async';
import 'dart:developer';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:async/async.dart';
import 'package:thoughtbook/src/features/authentication/application/auth_service.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/note_crud/application/cloud_note_service/firestore_notes_service.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note_crud/application/note_sync_service/note_change_helper.dart';
import 'package:thoughtbook/src/features/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

/// Service used to keep the local and cloud databases up to date with the latest changes in notes.
/// Works only when a user is signed in to the application.
class NoteSyncService {
  // Used to debounce the change feed stream, hence reducing network and database load.
  final _debouncer =
      Debouncer<NoteChange>(delay: const Duration(milliseconds: 250));

  /// A getter which returns the device's current internet connection status
  Future<bool> get hasInternetConnection async =>
      await InternetConnectionChecker().hasConnection;

  AuthUser get authUser => AuthService.firebase().currentUser!;

  // A StreamQueue to handle the local change feed stream
  late StreamQueue<NoteChange> _changeFeedQueue;

  static final NoteSyncService _shared = NoteSyncService._sharedInstance();

  factory NoteSyncService() => _shared;

  NoteSyncService._sharedInstance() {
    // Sets up the local change feed stream as a StreamQueue, with debounced events
    _changeFeedQueue = StreamQueue<NoteChange>(
      LocalNoteService().getNoteChangeFeed.transform(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(data);
            // NoteChange? previousChange = _debouncer.previousEvent;
            // if (previousChange != null) {
            //   if ((data.type != previousChange.type) ||
            //       (previousChange.noteIsarId != data.noteIsarId)) {
            //     _debouncer.cancelTimer();
            //     sink.add(previousChange);
            //     sink.add(data);
            //   } else {
            //     _debouncer.run(() => sink.add(data));
            //   }
            // } else {
            //   _debouncer.run(() => sink.add(data));
            // }
            // _debouncer.previousEvent = data;
          },
        ),
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
      '[1/3] Starting sync service...',
      name: 'NoteSyncService',
    );
    unawaited(handleLocalChangeFeed());
    log(
      '[2/3] Started LocalNote change-feed handler.',
      name: 'NoteSyncService',
    );
    unawaited(syncLocalChangeFeed());
    log(
      '[3/3] Started change-feed sync worker.',
      name: 'NoteSyncService',
    );
  }

  /// Responsible for retrieving changes from the Firestore notes collection to the local database.
  Future<void> syncCloudToLocal() async {
    _ensureUserIsSignedInOrThrow();
  }

  /// Responsible for syncing the changes from the change-feed collection to the Firestore notes collection.
  Future<void> syncLocalChangeFeed() async {
    _ensureUserIsSignedInOrThrow();
    // // Notifies whenever there is any change in the NoteChange collection
    // late Stream<void> changeCollectionEvent;
    // List<NoteChange> changes = await NoteChangeHelper().getAllChanges;
    // // Notifies whenever there is a change in the internet connection status
    // final connectionStream =
    //     InternetConnectionChecker().onStatusChange.asBroadcastStream();
    // await for (InternetConnectionStatus status in connectionStream) {
    //   if (status == InternetConnectionStatus.connected) {
    //     if (changes.isNotEmpty) {
    //       for (NoteChange change in changes) {
    //         await _syncOrIgnoreLocalChange(change);
    //         await NoteChangeHelper().deleteChange(id: change.id);
    //       }
    //     } else {
    //       changeCollectionEvent = await NoteChangeHelper().eventNotifier;
    //       await for (void _ in changeCollectionEvent.listenAndBuffer()) {
    //         try {
    //           NoteChange change =
    //               await NoteChangeHelper().getOldestChangeAndDelete();
    //           await _syncOrIgnoreLocalChange(change);
    //         } on CouldNotFindChangeException {
    //           log(
    //             'No changes to sync.',
    //             name: 'NoteSyncService',
    //           );
    //         } on CouldNotDeleteChangeException {
    //           // empty
    //         }
    //       }
    //     }
    //   } else if (status == InternetConnectionStatus.disconnected) {
    //     // Remove the listener to avoid memory leaks
    //     await changeCollectionEvent
    //         .listen(
    //           (event) {},
    //         )
    //         .cancel();
    //     log(
    //       'Internet connection not detected. Pausing sync.',
    //       name: 'NoteSyncService',
    //     );
    //     continue;
    //   }
    // }

    late Stream<void> changeCollectionEvent;

    while (true) {
      bool changesPending = !(await NoteChangeHelper().isCollectionEmpty);
      if (changesPending) {
        if (await InternetConnectionChecker().hasConnection) {
          try {
            NoteChange change =
                await NoteChangeHelper().getOldestChangeAndDelete();
            await _syncOrIgnoreLocalChange(change);
          } on CouldNotFindChangeException {
            log(
              'Could not find change to sync.',
              name: 'NoteSyncService',
            );
          } on CouldNotDeleteChangeException {
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
        await for (void changeEvent in changeCollectionEvent) {
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

  Future<void> _syncOrIgnoreLocalChange(NoteChange change) async {
    switch (change.type) {
      case NoteChangeType.create:
        await _syncOrIgnoreLocalCreate(change);
        break;
      case NoteChangeType.update:
        await _syncOrIgnoreLocalUpdate(change);
        break;
      case NoteChangeType.delete:
        await _syncOrIgnoreLocalDelete(change);
        break;
      default:
        throw InvalidNoteChangeTypeException();
    }
  }

  /// Method to sync a LocalNote which does not exist in the cloud yet.
  Future<void> _syncOrIgnoreLocalCreate(NoteChange change) async {
    try {
      await LocalNoteService().getNote(id: change.noteIsarId);
    } on CouldNotFindNoteException {
      log(
        'Could not find LocalNote with isarId=${change.noteIsarId} to sync local create',
        name: 'NoteSyncService',
      );
      return;
    }

    // Create a new note in the Firestore collection
    final CloudNote newCloudNote =
        await FirestoreNoteService().createNewNote(ownerUserId: authUser.id);

    // Set the correct metadata for the new note in the Firestore collection
    await FirestoreNoteService().updateNote(
      documentId: newCloudNote.documentId,
      title: change.title,
      content: change.content,
      color: change.color,
      created: change.created,
      modified: change.modified,
    );

    // The local note is fetched again as its possible that it got deleted/outdated
    // between async operations
    late final LocalNote localNote;
    try {
      localNote = await LocalNoteService().getNote(id: change.noteIsarId);
    } on CouldNotFindNoteException {
      log('Could not find local note with isarId=${change.noteIsarId} to sync local create.');
      return;
    }

    // Update the cloudDocumentId field for the corresponding LocalNote
    // and mark it as synced with the cloud
    await LocalNoteService().updateNote(
      isarId: change.noteIsarId,
      cloudDocumentId: newCloudNote.documentId,
      isSyncedWithCloud: true,
      title: localNote.title,
      content: localNote.content,
      color: localNote.color,
      addToChangeFeed: false,
    );

    log('New note with isarId=${change.noteIsarId} synced with cloud.');
  }

  /// Method to sync a locally updated note with the cloud.
  Future<void> _syncOrIgnoreLocalUpdate(NoteChange change) async {
    LocalNote localNote;
    try {
      localNote = await LocalNoteService().getNote(id: change.noteIsarId);
    } on CouldNotFindNoteException {
      // The note could have been deleted locally by the user by the time the
      // update operation got processed for syncing.
      log('Could not find local note with isarId=${change.noteIsarId} to sync local update.');
      return;
    }

    // If no cloudId was passed, then return
    if (localNote.cloudDocumentId == null ||
        localNote.cloudDocumentId!.isEmpty) {
      log('cloudDocumentId field found to be null in NoteChange instance. Cannot proceed to sync local update operation.');
      return;
    } else {
      log('Syncing note with cloudId=${localNote.cloudDocumentId!}');
    }

    // Check if the local change is outdated
    final cloudNote = await FirestoreNoteService()
        .getNote(cloudDocumentId: localNote.cloudDocumentId!);
    if (cloudNote.modified.toDate().isAfter(localNote.modified)) {
      log('Local change to note with isarId=${localNote.isarId} is outdated. Ignoring sync.');

      // Mark corresponding LocalNote as synced with cloud
      try {
        await LocalNoteService().updateNote(
          isarId: localNote.isarId,
          isSyncedWithCloud: true,
          title: localNote.title,
          content: localNote.content,
          color: localNote.color,
          addToChangeFeed: false,
        );
      } on CouldNotUpdateNoteException {
        log('Could not mark local note as synced');
      }
      return;
    }

    // Update the note in the Firestore collection
    try {
      await FirestoreNoteService().updateNote(
        documentId: localNote.cloudDocumentId!,
        title: localNote.title,
        content: localNote.content,
        color: localNote.color,
        created: localNote.created,
        modified: localNote.modified,
      );
    } on CouldNotUpdateNoteException {
      log(
        'Could not update LocalNote with isarId=${change.noteIsarId} & cloudId=${localNote.cloudDocumentId!}',
        name: 'NoteSyncService',
      );
      return;
    }

    // Mark corresponding LocalNote as synced with cloud
    try {
      await LocalNoteService().markNoteAsSynced(isarId: localNote.isarId);
    } on CouldNotUpdateNoteException {
      log(
        name: 'NoteSync',
        'Something went wrong. Could not update LocalNote with isarId=${change.noteIsarId} to mark it as synced.',
      );
      return;
    }
    log('Note with isarId=${change.noteIsarId} synced with cloud');
  }

  /// Method to sync a locally deleted note with the cloud.
  Future<void> _syncOrIgnoreLocalDelete(NoteChange change) async {
    if (change.cloudDocumentId == null) {
      log('cloudDocumentId field found to be null in NoteChange instance with isarId=${change.noteIsarId}. Cannot proceed to sync local delete operation');
      return;
    }

    try {
      await FirestoreNoteService()
          .deleteNote(documentId: change.cloudDocumentId!);
    } on CouldNotDeleteNoteException {
      log(
        'Could not find CloudNote with isarid=${change.noteIsarId} & cloudId=${change.cloudDocumentId} to delete.',
        name: 'NoteSyncService',
      );
      return;
    }

    log('Deleted localNote with isarId=${change.noteIsarId} from the cloud');
  }

  void _ensureUserIsSignedInOrThrow() {
    final currentUser = AuthService.firebase().currentUser;
    if (currentUser == null) {
      throw UserNotLoggedInSyncException();
    }
  }
}

class NoteFeedClosedSyncException implements Exception {}

class UserNotLoggedInSyncException implements Exception {}

class CouldNotDeleteChangeException implements Exception {}

class InvalidNoteChangeTypeException implements Exception {}

enum NoteChangeType {
  create,
  update,
  delete,
}
