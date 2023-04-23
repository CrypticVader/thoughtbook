import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/services/cloud/firestore_notes_constants.dart';
import 'package:thoughtbook/services/cloud/firestore_notes_exceptions.dart';

class FirestoreNoteService {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String content,
    required int? color,
  }) async {
    try {
      final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
      await notes.doc(documentId).update(
        {
          titleFieldName: title,
          contentFieldName: content,
          colorFieldName: color,
          modifiedFieldName: currentTime,
        },
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
        .orderBy(createdFieldName, descending: true)
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => CloudNote.fromSnapshot(doc),
          ),
        );

    return allNotes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
    final document = await notes.add(
      {
        ownerUserIdFieldName: ownerUserId,
        titleFieldName: '',
        contentFieldName: '',
        colorFieldName: null,
        createdFieldName: currentTime,
        modifiedFieldName: currentTime,
      },
    );

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      title: '',
      content: '',
      color: null,
      created: currentTime,
      modified: currentTime,
    );
  }

  static final _shared = FirestoreNoteService._sharedInstance();

  FirestoreNoteService._sharedInstance();

  factory FirestoreNoteService() => _shared;
}
