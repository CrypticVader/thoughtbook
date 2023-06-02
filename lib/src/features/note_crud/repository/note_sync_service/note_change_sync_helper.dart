import 'dart:developer';

import 'package:thoughtbook/src/features/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';
import 'package:thoughtbook/src/features/note_crud/repository/cloud_note_service/firestore_notes_service.dart';
import 'package:thoughtbook/src/features/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/repository/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_change_helper.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_service.dart';

class NoteChangeSyncHelper {
  Future<void> syncOrIgnoreLocalChange({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    switch (change.type) {
      case NoteChangeType.create:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalCreate(
          change: change,
          ownerUserId: ownerUserId,
        );
        break;
      case NoteChangeType.update:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalUpdate(change);
        break;
      case NoteChangeType.delete:
        await NoteChangeSyncHelper()._syncOrIgnoreLocalDelete(change);
        break;
      default:
        throw InvalidNoteChangeTypeSyncException();
    }
  }

  /// Method to sync a [LocalNote] which does not exist in the cloud yet.
  Future<void> _syncOrIgnoreLocalCreate({
    required NoteChange change,
    required String ownerUserId,
  }) async {
    try {
      await LocalNoteService().getNote(isarId: change.noteIsarId);
    } on CouldNotFindNoteException {
      log(
        'Could not find LocalNote with isarId=${change.noteIsarId} to sync local create. Proceeding to delete all changes to the missing note from change feed.',
        name: 'NoteSyncService',
      );
      await NoteChangeHelper()
          .deleteAllChangesToNote(isarNoteId: change.noteIsarId);
      return;
    }

    // Create a new note in the Firestore collection
    final CloudNote newCloudNote =
        await FirestoreNoteService().createNewNote(ownerUserId: ownerUserId);

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
      localNote = await LocalNoteService().getNote(isarId: change.noteIsarId);
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
      localNote = await LocalNoteService().getNote(isarId: change.noteIsarId);
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
}
