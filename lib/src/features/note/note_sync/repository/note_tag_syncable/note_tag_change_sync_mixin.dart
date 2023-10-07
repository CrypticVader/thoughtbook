import 'dart:developer';

import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_tag_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_tag_syncable/note_tag_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

mixin NoteTagChangeSyncMixin {
  Future<void> syncOrIgnoreLocalChange({
    required NoteTagChange change,
    required String ownerUserId,
  }) async {
    switch (change.type) {
      case SyncableChangeType.create:
        await _syncOrIgnoreLocalCreate(
          change: change,
          ownerUserId: ownerUserId,
        );
        break;
      case SyncableChangeType.update:
        await _syncOrIgnoreLocalUpdate(change);
        break;
      case SyncableChangeType.delete:
        await _syncOrIgnoreLocalDelete(change);
        break;
      default:
        throw InvalidSyncableTypeSyncException();
    }
  }

  /// Method to sync a [ChangedNote] which does not exist in the cloud yet.
  Future<void> _syncOrIgnoreLocalCreate({
    required NoteTagChange change,
    required String ownerUserId,
  }) async {
    try {
      await LocalStore.noteTag.getItem(id: change.noteTag.isarId);
    } on CouldNotFindNoteTagException {
      log(
        'Could not find LocalNoteTag with isarId=${change.noteTag.isarId} to'
        'sync local create. Proceeding to delete all changes to the missing noteTag from change feed.',
        name: 'NoteSyncService',
      );
      await NoteTagChangeStorable().deleteAllChangesForNoteTag(isarNoteId: change.noteTag.isarId);
      return;
    }

    // Create a new noteTag in the Firestore collection
    final CloudNoteTag newCloudNoteTag = await CloudStore.noteTag.createItem();

    // Set the correct metadata for the new noteTag in the Firestore collection
    await CloudStore.noteTag.updateItem(
      cloudDocumentId: newCloudNoteTag.documentId,
      created: change.noteTag.created,
      modified: change.noteTag.modified,
      name: change.noteTag.name,
    );

    // Update the cloudDocumentId field for the corresponding LocalNoteTag
    // and mark it as synced with the cloud
    try {
      await LocalStore.noteTag.updateItem(
        id: change.noteTag.isarId,
        cloudDocumentId: newCloudNoteTag.documentId,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );
    } on CouldNotFindNoteTagException {
      log('Could not find local noteTag with isarId=${change.noteTag.isarId}'
          'to sync local create.');
      return;
    } on CouldNotUpdateNoteTagException {
      log('Could not update local noteTag with isarId=${change.noteTag.isarId}'
          'to sync local create.');
      return;
    }

    log('New noteTag with isarId=${change.noteTag.isarId} synced with cloud.');
  }

  /// Method to sync a locally updated noteTag with the cloud.
  Future<void> _syncOrIgnoreLocalUpdate(NoteTagChange change) async {
    LocalNoteTag localNoteTag;
    try {
      localNoteTag = await LocalStore.noteTag.getItem(id: change.noteTag.isarId);
    } on CouldNotFindNoteTagException {
      // The noteTag could have been deleted locally by the user by the time the
      // update operation got processed for syncing.
      log('Could not find local noteTag with isarId=${change.noteTag.isarId}'
          'to sync local update.');
      return;
    }

    // If no cloudId was passed, then return
    if (localNoteTag.cloudDocumentId == null || localNoteTag.cloudDocumentId!.isEmpty) {
      log('cloudDocumentId field is null in NoteTagChange instance.'
          'Cannot proceed to sync local update operation.');
      return;
    } else {
      log('Syncing noteTag with cloudId=${localNoteTag.cloudDocumentId!}');
    }

    // Check if the local change is outdated
    final cloudNote =
        await CloudStore.noteTag.getItem(cloudDocumentId: localNoteTag.cloudDocumentId!);
    if (cloudNote.modified.toDate().isAfter(localNoteTag.modified)) {
      log('Local change to noteTag with isarId=${localNoteTag.isarId} is outdated.'
          'Ignoring sync.');

      // Mark corresponding LocalNoteTag as synced with cloud
      try {
        await LocalStore.noteTag.updateItem(
          id: localNoteTag.isarId,
          isSyncedWithCloud: true,
          addToChangeFeed: false,
        );
      } on CouldNotUpdateNoteException {
        log('Could not mark LocalNoteTag as synced');
      }
      return;
    }

    // Update the noteTag in the Firestore collection
    try {
      await CloudStore.noteTag.updateItem(
        cloudDocumentId: localNoteTag.cloudDocumentId!,
        name: change.noteTag.name,
        created: change.noteTag.created,
        modified: change.noteTag.modified,
      );
    } on CouldNotUpdateNoteException {
      log(
        'Could not update LocalNoteTag with isarId=${change.noteTag.isarId} &'
        'cloudId=${localNoteTag.cloudDocumentId!}',
        name: 'NoteSyncService',
      );
      return;
    }

    // Mark corresponding LocalNoteTag as synced with the cloud
    try {
      await LocalStore.noteTag.updateItem(
        id: localNoteTag.isarId,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );
    } on CouldNotUpdateNoteException {
      log(
        name: 'NoteTagSync',
        'Could not update LocalNoteTag with isarId=${change.noteTag.isarId}'
        'to mark it as synced.',
      );
      return;
    }
    log('Note with isarId=${change.noteTag.isarId} synced with cloud');
  }

  /// Method to sync a locally deleted noteTag with the cloud.
  Future<void> _syncOrIgnoreLocalDelete(NoteTagChange change) async {
    if (change.noteTag.cloudDocumentId == null) {
      log('cloudDocumentId field found to be null in NoteTagChange instance with'
          'isarId=${change.noteTag.isarId}.'
          'Cannot proceed to sync local delete operation');
      return;
    }

    try {
      await CloudStore.noteTag.deleteItem(cloudDocumentId: change.noteTag.cloudDocumentId!);
    } on CouldNotDeleteNoteTagException {
      log(
        'Could not find CloudNoteTag with isarId=${change.noteTag.isarId} &'
        'cloudId=${change.noteTag.cloudDocumentId} to delete.',
        name: 'NoteTagSyncService',
      );
      return;
    }

    log('Deleted NoteTag with isarId=${change.noteTag.isarId} from the cloud');
  }
}
