import 'dart:developer';

import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

mixin NoteChangeSyncMixin {
  Future<void> syncLocalChange({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    switch (change.type) {
      case SyncableChangeType.create:
        await _syncLocalCreate(
          change: change,
          ownerUserId: ownerUserId,
        );
        break;
      case SyncableChangeType.update:
        await _syncLocalUpdate(change);
        break;
      case SyncableChangeType.delete:
        await _syncLocalDelete(change);
        break;
      default:
        throw InvalidSyncableTypeSyncException();
    }
  }

  /// Method to sync a [LocalNote] which does not exist in the cloud yet.
  Future<void> _syncLocalCreate({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    try {
      await LocalStore.note.getItem(id: change.note.isarId);
    } on CouldNotFindNoteException {
      log(
        'Could not find LocalNote with isarId=${change.note.isarId} to'
        'sync local create. Proceeding to delete all changes to the missing note from change feed.',
        name: 'NoteSyncService',
      );
      await NoteChangeStorable()
          .deleteAllChangesForNote(isarNoteId: change.note.isarId);
      return;
    }

    // Create a new note in the Firestore collection
    final CloudNote newCloudNote = await CloudStore.note.createItem();

    // Obtain the documentIds for tags from their isarIds
    final tagDocIds =
        LocalStore.noteTag.getCloudIdsFor(isarIds: change.note.tagIds);
    if (tagDocIds.length != change.note.tagIds.length) {
      final diff = change.note.tagIds.length - tagDocIds.length;
      log(
        '$diff noteTag(s) attached to note with isarId=${change.note.isarId} '
        'are pending to be synced. This is preventing the note from '
        'properly updating its cloudDocumentIds field',
        name: 'NoteSyncService',
      );
    }
    // Set the correct properties for the new note in the Firestore collection
    await CloudStore.note.updateItem(
      cloudDocumentId: newCloudNote.documentId,
      title: change.note.title,
      content: change.note.content,
      tagDocumentIds: tagDocIds,
      color: change.note.color,
      created: change.note.created,
      modified: change.note.modified,
    );

    try {
      // Update the cloudDocumentId field for the corresponding LocalNote
      // and mark it as synced with the cloud
      await LocalStore.note.updateItem(
        id: change.note.isarId,
        cloudDocumentId: newCloudNote.documentId,
        modified: change.note.modified,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );
      log('New note with isarId=${change.note.isarId} synced with cloud.');
    } on CouldNotFindNoteException {
      log('Could not find local note with isarId=${change.note.isarId}'
          'to sync local create.');
      return;
    }
  }

  /// Method to sync a locally updated note with the cloud.
  Future<void> _syncLocalUpdate(NoteChange change) async {
    LocalNote localNote;
    try {
      localNote = await LocalStore.note.getItem(id: change.note.isarId);
    } on CouldNotFindNoteException {
      // The note could have been deleted locally by the user by the time the
      // update operation got processed for syncing.
      log('Could not find local note with isarId=${change.note.isarId}'
          'to sync local update.');
      return;
    }

    // If no cloudId was passed, then return
    if (localNote.cloudDocumentId == null ||
        localNote.cloudDocumentId!.isEmpty) {
      log('cloudDocumentId field found to be null in NoteChange instance.'
          'Cannot proceed to sync local update operation.');
      return;
    } else {
      log('Syncing note with cloudId=${localNote.cloudDocumentId!}');
    }

    // Update the note in the Firestore collection
    try {
      final tagDocIds =
          LocalStore.noteTag.getCloudIdsFor(isarIds: change.note.tagIds);
      log(tagDocIds.toString());
      if (tagDocIds.length != change.note.tagIds.length) {
        final diff = change.note.tagIds.length - tagDocIds.length;
        log(
          '$diff noteTag(s) attached to note with isarId=${change.note.isarId} '
          'are pending to be synced. This is preventing the note from '
          'properly updating its cloudDocumentIds field',
          name: 'NoteSyncService',
        );
      }
      await CloudStore.note.updateItem(
        cloudDocumentId: localNote.cloudDocumentId!,
        title: change.note.title,
        content: change.note.content,
        tagDocumentIds: tagDocIds,
        color: change.note.color,
        created: change.note.created,
        modified: change.note.modified,
      );
    } on CouldNotUpdateNoteException {
      log(
        'Could not update LocalNote with isarId=${change.note.isarId} &'
        'cloudId=${localNote.cloudDocumentId!}',
        name: 'NoteSyncService',
      );
      return;
    }

    // Mark corresponding LocalNote as synced with cloud
    try {
      await LocalStore.note.updateItem(
        id: localNote.isarId,
        modified: localNote.modified,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );
    } on CouldNotUpdateNoteException {
      log(
        name: 'NoteSync',
        'Could not update LocalNote with isarId=${change.note.isarId}'
        'to mark it as synced.',
      );
      return;
    }
    log('Note with isarId=${change.note.isarId} synced with cloud');
  }

  /// Method to sync a locally deleted note with the cloud.
  Future<void> _syncLocalDelete(NoteChange change) async {
    if (change.note.cloudDocumentId == null) {
      log('cloudDocumentId field found to be null in NoteChange instance with'
          'isarId=${change.note.isarId}.'
          'Cannot proceed to sync local delete operation');
      return;
    }

    try {
      await CloudStore.note
          .deleteItem(cloudDocumentId: change.note.cloudDocumentId!);
    } on CouldNotDeleteNoteException {
      log(
        'Could not find CloudNote with isarId=${change.note.isarId} &'
        'cloudId=${change.note.cloudDocumentId} to delete.',
        name: 'NoteSyncService',
      );
      return;
    }

    log('Deleted localNote with isarId=${change.note.isarId} from the cloud');
  }
}
