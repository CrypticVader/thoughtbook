import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable_constants.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/crud_exceptions.dart';

class CloudNoteTagStorable implements CloudStorable<CloudNoteTag> {
  static final _shared = CloudNoteTagStorable._sharedInstance();

  CloudNoteTagStorable._sharedInstance();

  factory CloudNoteTagStorable() => _shared;

  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  String get _userId => AuthService.firebase().currentUser!.id;

  @override
  CollectionReference<Map<String, dynamic>> get entityCollection =>
      _firestoreInstance
          .collection(getFirestoreNoteTagsCollectionPath(_userId));

  /// Returns a [Stream] of an [Iterable] of [CloudNoteTag] from the Firestore 'noteTags'
  /// collection belonging to the logged in user
  @override
  Stream<Iterable<CloudNoteTag>> get allItems {
    final allNotes = entityCollection
        .where(
          ownerUserIdFieldName,
          isEqualTo: _userId,
        )
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => CloudNoteTag.fromSnapshot(doc),
          ),
        );

    return allNotes;
  }

  @override
  Future<CloudNoteTag> createItem() async {
    final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
    final document = await entityCollection.add(
      {
        ownerUserIdFieldName: _userId,
        nameFieldName: '',
        createdFieldName: currentTime,
        modifiedFieldName: currentTime,
      },
    );

    final fetchedNoteTag = await document.get();
    return CloudNoteTag(
      documentId: fetchedNoteTag.id,
      ownerUserId: _userId,
      name: '',
      created: currentTime,
      modified: currentTime,
    );
  }

  @override
  Future<void> deleteItem({required String cloudDocumentId}) async {
    try {
      await entityCollection.doc(cloudDocumentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteTagException();
    }
  }

  @override
  Future<CloudNoteTag> getItem({required String cloudDocumentId}) async {
    final noteTag = await entityCollection.doc(cloudDocumentId).get();
    return CloudNoteTag(
      documentId: noteTag.id,
      ownerUserId: noteTag.data()?[ownerUserIdFieldName] as String,
      name: noteTag.data()?[nameFieldName] as String,
      created: noteTag.data()?[createdFieldName] as Timestamp,
      modified: noteTag.data()?[modifiedFieldName] as Timestamp,
    );
  }

  @override
  Future<void> updateItem({
    required String cloudDocumentId,
    String? name,
    DateTime? created,
    DateTime? modified,
  }) async {
    try {
      final currentTime = Timestamp.fromDate(DateTime.now().toUtc());
      await entityCollection.doc(cloudDocumentId).update(
        {
          if (name != null) titleFieldName: name,
          if (created != null) createdFieldName: created,
          modifiedFieldName: modified ?? currentTime,
        },
      );
    } catch (e) {
      // rethrow;
      throw CouldNotUpdateNoteException();
    }
  }
}
