import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/authentication/application/auth_service.dart';
import 'package:thoughtbook/src/features/note_crud/application/cloud_note_service/firestore_notes_constants.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/domain/cloud_note.dart';

//TODO: Handle exceptions due to network errors/timeouts
class FirestoreNoteService {
  CollectionReference<Map<String, dynamic>> get notes {
    final authUserId = AuthService.firebase().currentUser!.id;
    return FirebaseFirestore.instance
        .collection('thoughtbookData/$authUserId/notes');
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String title,
    required String content,
    required int? color,
    DateTime? created,
    DateTime? modified,
  }) async {
    try {
      final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
      await notes.doc(documentId).update(
        {
          titleFieldName: title,
          contentFieldName: content,
          colorFieldName: color,
          modifiedFieldName: modified ?? currentTime,

          //TODO: Fix this later
          createdFieldName: created ?? currentTime,
        },
      );
    } catch (e) {
      // throw
      throw CouldNotUpdateNoteException();
    }
  }

  /// Returns a [Stream] of an [Iterable] of [CloudNote] from the Firestore 'notes'
  /// collection belonging to the user with the given userId.
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

  Future<CloudNote> getNote({required String cloudDocumentId}) async {
    final note = await notes.doc(cloudDocumentId).get();
    return CloudNote(
      documentId: note.id,
      ownerUserId: note.data()?[ownerUserIdFieldName],
      content: note.data()?[contentFieldName] as String,
      title: note.data()?[titleFieldName] as String,
      color: note.data()?[colorFieldName] as int?,
      created: note.data()?[createdFieldName] as Timestamp,
      modified: note.data()?[modifiedFieldName] as Timestamp,
    );
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
