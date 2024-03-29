import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable_constants.dart';

/// Data model for notes stored in the Firebase Firestore database.
@immutable
class CloudNote {
  final String documentId;

  final String ownerUserId;

  final String content;

  final String title;

  final List<String> tagDocumentIds;

  final int? color;

  final Timestamp created;

  final Timestamp modified;

  final bool isTrashed;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.title,
    required this.content,
    required this.tagDocumentIds,
    required this.color,
    required this.created,
    required this.modified,
    required this.isTrashed,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        content = snapshot.data()[contentFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        tagDocumentIds = List<String>.from(snapshot.data()[tagDocumentIdsFieldName] ?? []),
        // do not cast as int as it is nullable
        color = snapshot.data()[colorFieldName] as int?,
        created = snapshot.data()[createdFieldName] as Timestamp,
        modified = snapshot.data()[modifiedFieldName] as Timestamp,
        isTrashed = snapshot.data()[isTrashedFieldName] as bool;

  @override
  bool operator ==(covariant CloudNote other) => documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;

  @override
  String toString() {
    return 'CloudNote{documentId: $documentId, ownerUserId: $ownerUserId, '
        'tagDocumentIds: $tagDocumentIds, title: $title, color: $color, '
        'content: $content, created: $created, modified: $modified, isTrashed: $isTrashed}';
  }
}
