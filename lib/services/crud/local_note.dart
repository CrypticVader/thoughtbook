import 'package:isar/isar.dart';

part 'local_note.g.dart';

@collection
class LocalNote {
  final Id localId = Isar.autoIncrement;

  String? cloudDocumentId;

  String title;

  String content;

  int? color;

  bool isSyncedWithCloud;

  @Index()
  DateTime created;

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
  });

  @override
  bool operator ==(covariant LocalNote other) => localId == other.localId;

  @override
  int get hashCode => localId.hashCode;

  @override
  String toString() {
    return 'LocalNote{localId: $localId, cloudDocumentId: $cloudDocumentId, title: $title, color: $color, content: $content, isSyncedWithCloud: $isSyncedWithCloud, created: $created, modified: $modified}';
  }
}
