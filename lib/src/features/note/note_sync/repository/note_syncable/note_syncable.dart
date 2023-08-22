import 'dart:async';
import 'dart:developer';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_change_sync_mixin.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/sync_utils.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

/// Service used to keep the local and cloud databases up to date with the latest changes in notes.
/// Works only when a user is signed in to the application.
class NoteSyncable
    with SyncUtilsMixin, NoteChangeSyncMixin
    implements Syncable<LocalNoteStorable, CloudNoteStorable> {
  static final NoteSyncable _shared = NoteSyncable._sharedInstance();

  factory NoteSyncable() => _shared;

  NoteSyncable._sharedInstance();

  /// Should be called after the first user login to retrieve notes from the Firestore collection.
  ///
  /// Returns a [Stream] indicating the progress, in percentage, of the operation.
  @override
  Stream<int> initLocalFromCloud() async* {
    ensureUserIsSignedInOrThrow();

    // Take first event from the stream, and map each element from CloudNote to LocalNote
    Iterable<CloudNote> notes = await CloudStore.note.allItems.first;

    final int cloudNotesCount = notes.length;
    int loadedCount = 0;
    // Load all notes from Firestore belonging to the user to Isar database locally
    for (CloudNote cloudNote in notes) {
      LocalNote newNote =
      await LocalStore.note.createItem(addToChangeFeed: false);
      final tagIds = LocalStore.noteTag.getLocalIdsFor(
          documentIds: cloudNote.tagDocumentIds);
      final note = LocalNote.fromCloudNote(
        note: cloudNote,
        isarId: newNote.isarId,
        tagIds: tagIds,
      );
      await LocalStore.note.updateItem(
        id: newNote.isarId,
        cloudDocumentId: note.cloudDocumentId,
        title: note.title,
        content: note.content,
        tags: note.tagIds,
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
  @override
  Future<void> startSync() async {
    log(
      '[1/3] Starting sync service...',
      name: 'NoteSyncService',
    );
    unawaited(NoteChangeStorable().handleLocalChangeFeed());
    log(
      '[2/3] Started LocalNote change-feed handler.',
      name: 'NoteSyncService',
    );
    unawaited(syncLocalChangeFeed());
    log(
      '[3/3] Started sync worker.',
      name: 'NoteSyncService',
    );
  }

  /// Responsible for syncing the changes from the change-feed collection to the Firestore notes collection.
  @override
  Future<void> syncLocalChangeFeed() async {
    ensureUserIsSignedInOrThrow();

    Stream<void> changeCollectionEvent =
    await NoteChangeStorable().newChangeNotifier;
    while (true) {
      bool changesPending = !(await NoteChangeStorable().hasNoPendingChanges);
      if (changesPending) {
        if (await InternetConnectionChecker().hasConnection) {
          try {
            NoteChange change =
            await NoteChangeStorable().getOldestChangeAndDelete();
            await syncLocalChange(
              change: change,
              ownerUserId: currentUser.id,
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
        await for (void _ in changeCollectionEvent) {
          log('changeCollectionEvent fired');
          break;
        }
      }
    }
  }
}
