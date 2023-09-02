import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';

part 'note_tag_change.g.dart';

@Collection()
class NoteTagChange {
  /// Required by Isar, unused field
  @id
  final int isarId;

  /// Represents the type of change that was made to the note tag
  @enumValue
  final SyncableChangeType type;

  /// Represents the time when the change was made locally
  @Index()
  @utc
  final DateTime timestamp;

  final ChangedNoteTag noteTag;

  NoteTagChange({
    required this.isarId,
    required this.type,
    required this.timestamp,
    required this.noteTag,
  });
}

@Embedded()
class ChangedNoteTag {
  final int isarId;

  final String? cloudDocumentId;

  final String name;

  @utc
  final DateTime modified;

  @utc
  final DateTime created;

  ChangedNoteTag({
    required this.isarId,
    required this.name,
    required this.cloudDocumentId,
    required this.created,
    required this.modified,
  });

  ChangedNoteTag.fromLocalNoteTag(LocalNoteTag noteTag)
      : isarId = noteTag.isarId,
        cloudDocumentId = noteTag.cloudDocumentId,
        name = noteTag.name,
        created = noteTag.created,
        modified = noteTag.modified;

  @override
  bool operator ==(covariant ChangedNoteTag other) => isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;

  @override
  String toString() {
    return 'ChangedNoteTag{id: $isarId, cloudDocumentId: $cloudDocumentId, '
        'name: $name, created: $created, modified: $modified,}';
  }
}
