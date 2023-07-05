import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_note_service/firestore_notes_constants.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/crud_exceptions.dart';

//TODO: Handle exceptions due to network errors/timeouts
class FirestoreNoteService {
  static final _shared = FirestoreNoteService._sharedInstance();

  FirestoreNoteService._sharedInstance();

  factory FirestoreNoteService() => _shared;

  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  String get userId => AuthService.firebase().currentUser!.id;

  CollectionReference<Map<String, dynamic>> get notes =>
      _firestoreInstance.collection(getFirestoreNotesCollectionPath(userId));

  CollectionReference<Map<String, dynamic>> get noteTags =>
      _firestoreInstance.collection(getFirestoreNoteTagsCollectionPath(userId));

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
    required List<int> tags,
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
          tagsFieldName: tags,
          colorFieldName: color,
          modifiedFieldName: modified ?? currentTime,
          if (created != null) createdFieldName: created,
        },
      );
    } catch (e) {
      // throw
      throw CouldNotUpdateNoteException();
    }
  }

  /// Returns a [Stream] of an [Iterable] of [CloudNote] from the Firestore 'notes'
  /// collection belonging to the logged in user
  Stream<Iterable<CloudNote>> allNotes() {
    final allNotes = notes
        .where(
          ownerUserIdFieldName,
          isEqualTo: userId,
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
      tags: List<int>.from(note.data()?[tagsFieldName]),
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
        tagsFieldName: [],
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
      tags: const [],
      color: null,
      created: currentTime,
      modified: currentTime,
    );
  }
}
