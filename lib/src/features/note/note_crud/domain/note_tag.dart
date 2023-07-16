import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';

part 'note_tag.g.dart';

@Collection()
class LocalNoteTag {
  Id id;

  String? cloudDocumentId;

  @Index(unique: true)
  String name;

  DateTime modified;

  DateTime created;

  LocalNoteTag({
    required this.name,
    required this.cloudDocumentId,
    required this.created,
    required this.modified,
  }) : id = Isar.autoIncrement;

  LocalNoteTag.fromCloudNoteTag(CloudNoteTag noteTag)
      : id = Isar.autoIncrement,
        cloudDocumentId = noteTag.documentId,
        name = noteTag.name,
        created = noteTag.created.toDate(),
        modified = noteTag.modified.toDate();

  @override
  bool operator ==(covariant LocalNoteTag other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoteTag{id: $id, cloudDocumentId: $cloudDocumentId, name: $name, created: $created, modified: $modified,}';
  }
}
