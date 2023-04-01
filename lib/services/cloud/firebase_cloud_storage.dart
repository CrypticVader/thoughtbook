import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/services/cloud/cloud_storage_constants.dart';
import 'package:thoughtbook/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote?> updateNote({
    required String documentId,
    required String title,
    required String content,
    required int? color,
  }) async {
    try {
      await notes.doc(documentId).update({
        titleFieldName: title,
        contentFieldName: content,
        colorFieldName: color,
      });
      final updatedNote = await notes.doc(documentId).get();
      return CloudNote(
        documentId: updatedNote.id,
        ownerUserId: updatedNote[ownerUserIdFieldName],
        title: updatedNote[titleFieldName],
        content: updatedNote[contentFieldName],
        color: updatedNote[colorFieldName],
      );
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: ownerUserId,
        )
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => CloudNote.fromSnapshot(doc),
          ),
        );

    return allNotes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add(
      {
        ownerUserIdFieldName: ownerUserId,
        titleFieldName: '',
        contentFieldName: '',
        colorFieldName: null,
      },
    );

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      title: '',
      content: '',
      color: null,
    );
  }

  static final _shared = FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;
}
