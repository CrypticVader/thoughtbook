import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/cloud_note_tag.dart';

part 'local_note_tag.g.dart';

@Collection(inheritance: false)
class LocalNoteTag with EquatableMixin {
  @id
  final int isarId;

  final String? cloudDocumentId;

  @Index(unique: true)
  final String name;

  @utc
  final DateTime modified;

  @utc
  final DateTime created;

  final bool isSyncedWithCloud;

  LocalNoteTag({
    required this.isarId,
    required this.name,
    required this.cloudDocumentId,
    required this.created,
    required this.modified,
    required this.isSyncedWithCloud,
  });

  LocalNoteTag.fromCloudNoteTag(CloudNoteTag noteTag, int id)
      : isarId = id,
        cloudDocumentId = noteTag.documentId,
        name = noteTag.name,
        created = noteTag.created.toDate(),
        modified = noteTag.modified.toDate(),
        isSyncedWithCloud = false;

  @override
  String toString() {
    return 'LocalNoteTag{id: $isarId, cloudDocumentId: $cloudDocumentId, '
        'name: $name, created: $created, modified: $modified, '
        'isSyncedWithCloud: $isSyncedWithCloud}';
  }

  @ignore
  @override
  List<Object?> get props => [
        isarId,
        name,
        cloudDocumentId,
        created,
        modified,
        isSyncedWithCloud,
      ];
}
