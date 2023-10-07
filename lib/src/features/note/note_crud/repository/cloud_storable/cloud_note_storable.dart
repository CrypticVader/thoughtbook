import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable_constants.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';

//TODO: Handle exceptions due to network errors/timeouts
class CloudNoteStorable implements CloudStorable<CloudNote> {
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  String get _userId => AuthService.firebase().currentUser!.id;

  @override
  CollectionReference<Map<String, dynamic>> get storableCollection =>
      _firestoreInstance.collection(getFirestoreNotesCollectionPath(_userId));

  @override
  Future<void> deleteItem({required String cloudDocumentId}) async {
    try {
      await storableCollection.doc(cloudDocumentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  @override
  Future<void> updateItem({
    required String cloudDocumentId,
    String? title,
    String? content,
    List<String>? tagDocumentIds,
    int? color = -1,
    DateTime? created,
    DateTime? modified,
    bool? isTrashed,
  }) async {
    try {
      final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
      await storableCollection.doc(cloudDocumentId).update(
        {
          if (title != null) titleFieldName: title,
          if (content != null) contentFieldName: content,
          if (tagDocumentIds != null) tagDocumentIdsFieldName: tagDocumentIds,
          if (color == null || color > 0) colorFieldName: color,
          if (created != null) createdFieldName: created,
          modifiedFieldName: modified ?? currentTime,
          if (isTrashed != null) isTrashedFieldName: isTrashed,
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
    final allNotes = storableCollection
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
    final note = await storableCollection.doc(cloudDocumentId).get();
    return CloudNote(
      documentId: note.id,
      ownerUserId: note.data()?[ownerUserIdFieldName] as String,
      content: note.data()?[contentFieldName] as String,
      title: note.data()?[titleFieldName] as String,
      tagDocumentIds: List<String>.from(note.data()?[tagDocumentIdsFieldName] ?? []),
      color: note.data()?[colorFieldName] as int?,
      created: note.data()?[createdFieldName] as Timestamp,
      modified: note.data()?[modifiedFieldName] as Timestamp,
      isTrashed: note.data()?[isTrashedFieldName] as bool,
    );
  }

  @override
  Future<CloudNote> createItem() async {
    final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
    final document = await storableCollection.add(
      {
        ownerUserIdFieldName: _userId,
        titleFieldName: '',
        contentFieldName: '',
        tagDocumentIdsFieldName: [],
        colorFieldName: null,
        createdFieldName: currentTime,
        modifiedFieldName: currentTime,
        isTrashedFieldName: false,
      },
    );

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: _userId,
      title: '',
      content: '',
      tagDocumentIds: const [],
      color: null,
      created: currentTime,
      modified: currentTime,
      isTrashed: false,
    );
  }
}
