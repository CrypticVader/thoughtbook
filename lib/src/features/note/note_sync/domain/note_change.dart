import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_sync_service/note_sync_service.dart';

part 'note_change.g.dart';

@Collection()
class NoteChange {
  /// Required by Isar, unused field
  Id id;

  /// Represents the type of change that was made to the note
  @enumerated
  final NoteChangeType type;

  /// Represents the time when the change was made locally
  @Index()
  final DateTime timestamp;

  /// Field will be null if change was a delete operation
  @Index()
  final int noteIsarId;

  /// In the case whether the note was deleted locally, this field will be accessed to delete from the cloud
  /// Field will be null if change was a create operation
  final String? cloudDocumentId;

  /// The title of the note.
  String title;

  /// The content of the note.
  String content;

  /// The list of id of tags associated with this note
  List<int> tags;

  /// The color of the note.
  int? color;

  /// The date and time when the note was created.
  @Index()
  DateTime created;

  /// The date and time when the note was last modified.
  @Index()
  DateTime modified;

  NoteChange.fromLocalNote({
    required LocalNote note,
    required this.type,
    required this.timestamp,
  })  : id = Isar.autoIncrement,
        noteIsarId = note.isarId,
        title = note.title,
        content = note.content,
        tags = note.tags,
        color = note.color,
        created = note.created,
        modified = note.modified,
        cloudDocumentId = note.cloudDocumentId;

  NoteChange({
    required this.type,
    required this.noteIsarId,
    required this.cloudDocumentId,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.tags,
    required this.color,
    required this.modified,
    required this.created,
  }) : id = Isar.autoIncrement;
}
