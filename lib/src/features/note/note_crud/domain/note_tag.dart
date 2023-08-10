import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';

part 'note_tag.g.dart';

@Collection()
class LocalNoteTag {
  @id
  final int isarId;

  final String? cloudDocumentId;

  @Index(unique: true)
  final String name;

  @utc
  final DateTime modified;

  @utc
  final DateTime created;

  LocalNoteTag({
    required this.isarId,
    required this.name,
    required this.cloudDocumentId,
    required this.created,
    required this.modified,
  });

  LocalNoteTag.fromCloudNoteTag(CloudNoteTag noteTag, int id)
      : isarId = id,
        cloudDocumentId = noteTag.documentId,
        name = noteTag.name,
        created = noteTag.created.toDate(),
        modified = noteTag.modified.toDate();

  @override
  bool operator ==(covariant LocalNoteTag other) => isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;

  @override
  String toString() {
    return 'LocalNoteTag{id: $isarId, cloudDocumentId: $cloudDocumentId, name: $name, created: $created, modified: $modified,}';
  }
}
