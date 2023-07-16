import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable_constants.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/crud_exceptions.dart';

//TODO: Handle exceptions due to network errors/timeouts
class CloudNoteStorable implements CloudStorable<CloudNote> {
  static final _shared = CloudNoteStorable._sharedInstance();

  CloudNoteStorable._sharedInstance();

  factory CloudNoteStorable() => _shared;

  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  String get _userId => AuthService.firebase().currentUser!.id;

  @override
  CollectionReference<Map<String, dynamic>> get entityCollection =>
      _firestoreInstance.collection(getFirestoreNotesCollectionPath(_userId));

  @override
  Future<void> deleteItem({required String cloudDocumentId}) async {
    try {
      await entityCollection.doc(cloudDocumentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  @override
  Future<void> updateItem({
    required String cloudDocumentId,
    String? title,
    String? content,
    List<int>? tags,
    int? color = -1,
    DateTime? created,
    DateTime? modified,
  }) async {
    try {
      final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
      await entityCollection.doc(cloudDocumentId).update(
        {
          if (title != null) titleFieldName: title,
          if (content != null) contentFieldName: content,
          if (tags != null) tagsFieldName: tags,
          if (color == null || color > 0) colorFieldName: color,
          if (created != null) createdFieldName: created,
          modifiedFieldName: modified ?? currentTime,
        },
      );
    } catch (e) {
      // rethrow;
      throw CouldNotUpdateNoteException();
    }
  }

  /// Returns a [Stream] of an [Iterable] of [CloudNote] from the Firestore 'notes'
  /// collection belonging to the logged in user
  @override
  Stream<Iterable<CloudNote>> get allItems {
    final allNotes = entityCollection
        .where(
          ownerUserIdFieldName,
          isEqualTo: _userId,
        )
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => CloudNote.fromSnapshot(doc),
          ),
        );

    return allNotes;
  }

  @override
  Future<CloudNote> getItem({required String cloudDocumentId}) async {
    final note = await entityCollection.doc(cloudDocumentId).get();
    return CloudNote(
      documentId: note.id,
      ownerUserId: note.data()?[ownerUserIdFieldName] as String,
      content: note.data()?[contentFieldName] as String,
      title: note.data()?[titleFieldName] as String,
      tags: List<int>.from(note.data()?[tagsFieldName]),
      color: note.data()?[colorFieldName] as int?,
      created: note.data()?[createdFieldName] as Timestamp,
      modified: note.data()?[modifiedFieldName] as Timestamp,
    );
  }

  @override
  Future<CloudNote> createItem() async {
    final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
    final document = await entityCollection.add(
      {
        ownerUserIdFieldName: _userId,
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
      ownerUserId: _userId,
      title: '',
      content: '',
      tags: const [],
      color: null,
      created: currentTime,
      modified: currentTime,
    );
  }
}
