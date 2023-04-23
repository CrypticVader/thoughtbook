import 'package:flutter/foundation.dart';
import 'package:thoughtbook/services/cloud/firestore_notes_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class CloudNote {
  final String documentId;

  final String ownerUserId;

  final String content;

  final String title;

  final int? color;

  final Timestamp created;

  final Timestamp modified;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.content,
    required this.color,
    required this.created,
    required this.modified,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        content = snapshot.data()[contentFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        color = snapshot.data()[colorFieldName],
        created = snapshot.data()[createdFieldName] as Timestamp,
        modified = snapshot.data()[modifiedFieldName] as Timestamp;

  @override
  bool operator ==(covariant CloudNote other) => documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;

  @override
  String toString() {
    return 'CloudNote{documentId: $documentId, ownerUserId: $ownerUserId, title: $title, color: $color, content: $content, created: $created, modified: $modified}';
  }
}
