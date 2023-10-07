import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable_constants.dart';

class CloudNoteTag {
  final String documentId;

  final String ownerUserId;

  final String name;

  final Timestamp created;

  final Timestamp modified;

  const CloudNoteTag({
    required this.documentId,
    required this.ownerUserId,
    required this.name,
    required this.created,
    required this.modified,
  });

  CloudNoteTag.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        name = snapshot.data()[nameFieldName] as String,
        created = snapshot.data()[createdFieldName] as Timestamp,
        modified = snapshot.data()[modifiedFieldName] as Timestamp;

  @override
  bool operator ==(covariant CloudNoteTag other) => documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;

  @override
  String toString() {
    return 'CloudNoteTag{documentId: $documentId, ownerUserId: $ownerUserId, name: $name, created: $created, modified: $modified}';
  }
}
