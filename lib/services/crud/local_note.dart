import 'package:isar/isar.dart';

part 'local_note.g.dart';

@collection
class LocalNote {
  // The ID of the note in the local database.
  Id isarId;

  // The ID of the corresponding document in the cloud storage.
  String? cloudDocumentId;

  // The title of the note.
  String title;

  // The content of the note.
  String content;

  // The color of the note.
  int? color;

  // Whether the note is synced with the cloud storage.
  bool isSyncedWithCloud;

  // The date and time when the note was created.
  @Index()
  DateTime created;

  // The date and time when the note was last modified.
  @Index()
  DateTime modified;

  LocalNote({
    required this.cloudDocumentId,
    required this.title,
    required this.content,
    required this.color,
    required this.created,
    required this.modified,
    required this.isSyncedWithCloud,
  }) : isarId = Isar.autoIncrement;

  @override
  bool operator ==(covariant LocalNote other) => isarId == other.isarId;

  @override
  int get hashCode => isarId.hashCode;

  @override
  String toString() {
    return 'LocalNote{localId: $isarId, cloudDocumentId: $cloudDocumentId, title: $title, color: $color, content: $content, isSyncedWithCloud: $isSyncedWithCloud, created: $created, modified: $modified}';
  }
}
