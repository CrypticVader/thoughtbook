import 'dart:async';
import 'dart:developer';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_tag_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_tag_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_tag_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_tag_syncable/note_tag_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_tag_syncable/note_tag_change_sync_mixin.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/sync_utils.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

class NoteTagSyncable
    with SyncUtilsMixin, NoteTagChangeSyncMixin
    implements Syncable<LocalNoteTagStorable, CloudNoteTagStorable> {
  static final NoteTagSyncable _shared = NoteTagSyncable._sharedInstance();

  factory NoteTagSyncable() => _shared;

  NoteTagSyncable._sharedInstance();

  /// Should be called after the first user login to retrieve noteTags from the
  /// Firestore collection.
  ///
  /// Returns a [Stream] indicating the progress, in percentage, of the operation.
  @override
  Stream<int> initLocalFromCloud() async* {
    ensureUserIsSignedInOrThrow();

    // Take first event from the stream, and map each element from CloudNoteTag to LocalNoteTag
    Iterable<CloudNoteTag> cloudNoteTags =
        await CloudStore.noteTag.allItems.first;
    final int cloudNoteTagsCount = cloudNoteTags.length;
    int loadedCount = 0;
    // Load all noteTags from Firestore belonging to the user to Isar database locally
    for (CloudNoteTag cloudNoteTag in cloudNoteTags) {
      LocalNoteTag newNoteTag =
          await LocalStore.noteTag.createItem(addToChangeFeed: false);
      final noteTag =
          LocalNoteTag.fromCloudNoteTag(cloudNoteTag, newNoteTag.isarId);
      await LocalStore.noteTag.updateItem(
        id: newNoteTag.isarId,
        cloudDocumentId: noteTag.cloudDocumentId,
        created: noteTag.created,
        modified: noteTag.modified,
        name: noteTag.name,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );

      loadedCount++;
      yield ((loadedCount * 100) ~/ cloudNoteTagsCount);
    }
  }

  /// Helper method which will set up background workers to sync noteTags while the app is
  /// running.
  @override
  Future<void> startSync() async {
    log(
      '[1/3] Starting sync service...',
      name: 'NoteTagSyncService',
    );
    unawaited(NoteTagChangeStorable().handleLocalChangeFeed());
    log(
      '[2/3] Started LocalNoteTag change-feed handler.',
      name: 'NoteTagSyncService',
    );
    unawaited(syncLocalChangeFeed());
    log(
      '[3/3] Started sync worker.',
      name: 'NoteTagSyncService',
    );
  }

  /// Responsible for syncing the changes from the change-feed collection to the Firestore noteTags collection.
  @override
  Future<void> syncLocalChangeFeed() async {
    ensureUserIsSignedInOrThrow();

    Stream<void> changeCollectionEvent =
        await NoteTagChangeStorable().newChangeNotifier;
    while (true) {
      bool changesPending =
          !(await NoteTagChangeStorable().hasNoPendingChanges);
      if (changesPending) {
        if (await InternetConnectionChecker().hasConnection) {
          try {
            NoteTagChange change =
                await NoteTagChangeStorable().getOldestChangeAndDelete();
            await syncOrIgnoreLocalChange(
              change: change,
              ownerUserId: currentUser.id,
            );
          } on CouldNotFindChangeException {
            log(
              'Could not find change to sync.',
              name: 'NoteTagSyncService',
            );
          } on CouldNotDeleteChangeSyncException {
            // empty
          }
        } else {
          log(
            'Internet connection not detected. Pausing sync.',
            name: 'NoteTagSyncService',
          );
          Stream<InternetConnectionStatus> connectionStream =
              InternetConnectionChecker().onStatusChange.asBroadcastStream();
          await for (InternetConnectionStatus status in connectionStream) {
            if (status == InternetConnectionStatus.connected) {
              await connectionStream.listen((_) {}).cancel();
              break;
            }
          }
        }
      } else {
        log(
          'No changes to sync.',
          name: 'NoteTagSyncService',
        );
        await for (void _ in changeCollectionEvent) {
          log('changeCollectionEvent fired');
          break;
        }
      }
    }
  }
}
