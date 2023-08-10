import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';

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

  /// Field will be null if change was a delete operation
  @Index()
  final int noteTagIsarId;

  /// In the case whether the note was deleted locally, this field will be accessed to delete from the cloud
  /// Field will be null if change was a create operation
  final String? cloudDocumentId;

  /// The name of the note tag.
  final String name;

  NoteTagChange({
    required this.isarId,
    required this.type,
    required this.timestamp,
    required this.noteTagIsarId,
    required this.cloudDocumentId,
    required this.name,
  });
}
