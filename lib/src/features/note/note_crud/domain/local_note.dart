import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';

part 'local_note.g.dart';

@collection
class LocalNote {
  /// The ID of the note in the local database.
  @id
  final int isarId;

  /// The ID of the corresponding document in the cloud database.
  final String? cloudDocumentId;

  /// The title of the note.
  final String title;

  /// The content of the note.
  final String content;

  /// The list of id of tags  added to this note.
  final List<int> tags;

  /// The color of the note.
  final int? color;

  /// Whether the note is synced with the cloud database.
  final bool isSyncedWithCloud;

  /// The date and time when the note was created, in UTC.
  @utc
  final DateTime created;

  /// The date and time when the note was last modified, in UTC.
  @utc
  final DateTime modified;

  LocalNote({
    required this.isarId,
    required this.cloudDocumentId,
    required this.title,
    required this.content,
    required this.tags,
    required this.color,
    required this.created,
    required this.modified,
    required this.isSyncedWithCloud,
  });

  LocalNote.fromCloudNote(CloudNote note, int id)
      : isarId = id,
        cloudDocumentId = note.documentId,
        title = note.title,
        content = note.content,
        tags = note.tags,
        color = note.color,
        isSyncedWithCloud = false,
        created = note.created.toDate(),
        modified = note.modified.toDate();

  @override
  bool operator ==(covariant LocalNote other) => isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;

  @override
  String toString() {
    return 'LocalNote{localId: $isarId, cloudDocumentId: $cloudDocumentId, title: $title, color: $color, content: $content, isSyncedWithCloud: $isSyncedWithCloud, created: $created, modified: $modified}';
  }
}
