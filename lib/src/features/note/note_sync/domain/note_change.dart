import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';

part 'note_change.g.dart';

@Collection()
class NoteChange {
  /// Required by Isar, unused field
  @id
  final int isarId;

  /// Represents the type of change that was made to the note
  final SyncableChangeType type;

  /// The [LocalNote] that was changed
  final ChangedNote note;

  /// Represents the time when this change was made locally
  @Index()
  @utc
  final DateTime timestamp;

  NoteChange({
    required this.isarId,
    required this.type,
    required this.timestamp,
    required this.note,
  });
}

@embedded
class ChangedNote {
  /// The ID of the note in the local database.
  @id
  final int isarId;

  /// The ID of the corresponding document in the cloud database.
  final String? cloudDocumentId;

  /// The title of the note.
  final String title;

  /// The content of the note.
  final String content;

  /// The list of id of tags added to this note.
  final List<int> tagIds;

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

  final bool isTrashed;

  ChangedNote({
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

  ChangedNote.fromLocalNote(LocalNote note)
      : isarId = note.isarId,
        content = note.content,
        title = note.title,
        color = note.color,
        tagIds = note.tagIds,
        created = note.created,
        modified = note.modified,
        isTrashed = note.isTrashed,
        isSyncedWithCloud = note.isSyncedWithCloud,
        cloudDocumentId = note.cloudDocumentId;

  @override
  bool operator ==(covariant ChangedNote other) => isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;

  @override
  String toString() {
    return 'ChangedNote{localId: $isarId, cloudDocumentId: $cloudDocumentId, '
        'tagIds: $tagIds ,title: $title, color: $color, content: $content, '
        'isSyncedWithCloud: $isSyncedWithCloud, created: $created, '
        'modified: $modified, isTrashed: $isTrashed}';
  }
}
