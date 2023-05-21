import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note_crud/application/note_sync_service/note_sync_service.dart';

part 'note_change.g.dart';

@Collection()
class NoteChange {
  // Required by Isar, unused field
  Id id = Isar.autoIncrement;

  // Represents the type of change that was made to the note
  @enumerated
  final NoteChangeType type;

  // Field will be null if change was a delete operation
  final int? isarId;

  // In the case whether the note was deleted locally, this field will be accessed to delete from the cloud
  // Field will be null if change was a create operation
  final String? cloudDocumentId;

  // Represents the time when the change was made locally
  @Index()
  final DateTime timestamp;

  NoteChange({
    required this.type,
    required this.isarId,
    required this.cloudDocumentId,
    required this.timestamp,
  });
}
