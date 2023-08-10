import 'dart:developer';

import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

class NoteChangeSyncHelper {
  Future<void> syncOrIgnoreLocalChange({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    switch (change.type) {
      case SyncableChangeType.create:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalCreate(
          change: change,
          ownerUserId: ownerUserId,
        );
        break;
      case SyncableChangeType.update:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalUpdate(change);
        break;
      case SyncableChangeType.delete:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalDelete(change);
        break;
      default:
        throw InvalidNoteChangeTypeSyncException();
    }
  }

  /// Method to sync a [ChangedNote] which does not exist in the cloud yet.
  Future<void> _syncOrIgnoreLocalCreate({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    try {
      await LocalStore.note.getItem(id: change.changedNote.isarId);
    } on CouldNotFindNoteException {
      log(
        'Could not find LocalNote with isarId=${change.changedNote.isarId} to sync local create. Proceeding to delete all changes to the missing note from change feed.',
        name: 'NoteSyncService',
      );
      await NoteChangeStorable()
          .deleteAllChangesToNote(isarNoteId: change.changedNote.isarId);
      return;
    }

    // Create a new note in the Firestore collection
    final CloudNote newCloudNote = await CloudStore.note.createItem();

    // Set the correct metadata for the new note in the Firestore collection
    await CloudStore.note.updateItem(
      cloudDocumentId: newCloudNote.documentId,
      title: change.changedNote.title,
      content: change.changedNote.content,
      tags: change.changedNote.tags,
      color: change.changedNote.color,
      created: change.changedNote.created,
      modified: change.changedNote.modified,
    );

    // The local note is fetched again as its possible that it got deleted/outdated
    // between async operations
    late final LocalNote localNote;
    try {
      localNote = await LocalStore.note.getItem(id: change.changedNote.isarId);
    } on CouldNotFindNoteException {
      log('Could not find local note with isarId=${change.changedNote.isarId} to sync local create.');
      return;
    }

    // Update the cloudDocumentId field for the corresponding LocalNote
    // and mark it as synced with the cloud
    await LocalStore.note.updateItem(
      id: change.changedNote.isarId,
      cloudDocumentId: newCloudNote.documentId,
      isSyncedWithCloud: true,
      title: localNote.title,
      content: localNote.content,
      tags: localNote.tags,
      color: localNote.color,
      addToChangeFeed: false,
    );

    log('New note with isarId=${change.changedNote.isarId} synced with cloud.');
  }

  /// Method to sync a locally updated note with the cloud.
  Future<void> _syncOrIgnoreLocalUpdate(NoteChange change) async {
    LocalNote localNote;
    try {
      localNote = await LocalStore.note.getItem(id: change.changedNote.isarId);
    } on CouldNotFindNoteException {
      // The note could have been deleted locally by the user by the time the
      // update operation got processed for syncing.
      log('Could not find local note with isarId=${change.changedNote.isarId} to sync local update.');
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
    final cloudNote = await CloudStore.note
        .getItem(cloudDocumentId: localNote.cloudDocumentId!);
    if (cloudNote.modified.toDate().isAfter(localNote.modified)) {
      log('Local change to note with isarId=${localNote.isarId} is outdated. Ignoring sync.');

      // Mark corresponding LocalNote as synced with cloud
      try {
        await LocalStore.note.updateItem(
          id: localNote.isarId,
          isSyncedWithCloud: true,
          title: localNote.title,
          content: localNote.content,
          tags: localNote.tags,
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
      await CloudStore.note.updateItem(
        cloudDocumentId: localNote.cloudDocumentId!,
        title: localNote.title,
        content: localNote.content,
        tags: localNote.tags,
        color: localNote.color,
        created: localNote.created,
        modified: localNote.modified,
      );
    } on CouldNotUpdateNoteException {
      log(
        'Could not update LocalNote with isarId=${change.changedNote.isarId} & cloudId=${localNote.cloudDocumentId!}',
        name: 'NoteSyncService',
      );
      return;
    }

    // Mark corresponding LocalNote as synced with cloud
    try {
      await LocalStore.note.updateItem(
        id: localNote.isarId,
        isSyncedWithCloud: true,
        addToChangeFeed: false,
      );
    } on CouldNotUpdateNoteException {
      log(
        name: 'NoteSync',
        'Could not update LocalNote with isarId=${change.changedNote.isarId} to mark it as synced.',
      );
      return;
    }
    log('Note with isarId=${change.changedNote.isarId} synced with cloud');
  }

  /// Method to sync a locally deleted note with the cloud.
  Future<void> _syncOrIgnoreLocalDelete(NoteChange change) async {
    if (change.changedNote.cloudDocumentId == null) {
      log('cloudDocumentId field found to be null in NoteChange instance with isarId=${change.changedNote.isarId}. Cannot proceed to sync local delete operation');
      return;
    }

    try {
      await CloudStore.note
          .deleteItem(cloudDocumentId: change.changedNote.cloudDocumentId!);
    } on CouldNotDeleteNoteException {
      log(
        'Could not find CloudNote with isarId=${change.changedNote.isarId} & cloudId=${change.changedNote.cloudDocumentId} to delete.',
        name: 'NoteSyncService',
      );
      return;
    }

    log('Deleted localNote with isarId=${change.changedNote.isarId} from the cloud');
  }
}
