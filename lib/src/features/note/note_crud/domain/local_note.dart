import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note.dart';

part 'local_note.g.dart';

@Collection(inheritance: false)
class LocalNote with EquatableMixin {
  /// The ID of the note in the local database.
  @id
  final int isarId;

  /// The ID of the corresponding document in the cloud database.
  @Index(unique: true)
  final String? cloudDocumentId;

  /// The title of the note.
  final String title;

  /// The content of the note.
  final String content;

  /// The list of id of tags  added to this note.
  final List<int> tagIds;

  /// The color of the note.
  final int? color;

  final bool isTrashed;

  /// Whether the note is synced with the cloud database.
  final bool isSyncedWithCloud;

  /// The date and time when the note was created, in UTC.
  @index
  @utc
  final DateTime created;

  /// The date and time when the note was last modified, in UTC.
  @index
  @utc
  final DateTime modified;

  LocalNote({
    required this.isarId,
    required this.cloudDocumentId,
    required this.title,
    required this.content,
    required this.tagIds,
    required this.color,
    required this.created,
    required this.modified,
    required this.isTrashed,
    required this.isSyncedWithCloud,
  });

  LocalNote.fromCloudNote({
    required CloudNote note,
    required this.isarId,
    required this.tagIds,
  })  : cloudDocumentId = note.documentId,
        title = note.title,
        content = note.content,
        color = note.color,
        isTrashed = note.isTrashed,
        isSyncedWithCloud = false,
        created = note.created.toDate(),
        modified = note.modified.toDate();

  @override
  String toString() {
    return 'LocalNote{localId: $isarId, cloudDocumentId: $cloudDocumentId, '
        'title: $title, color: $color, content: $content, isSyncedWithCloud: '
        '$isSyncedWithCloud, created: $created, modified: $modified}, isTrashed: $isTrashed,';
  }

  @ignore
  @override
  List<Object?> get props => [
        isarId,
        cloudDocumentId,
        title,
        content,
        color,
        tagIds,
        created,
        modified,
        isTrashed,
        isSyncedWithCloud,
      ];
}
