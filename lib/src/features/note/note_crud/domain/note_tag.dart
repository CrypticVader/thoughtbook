import 'package:isar/isar.dart';

part 'note_tag.g.dart';

@Collection()
class NoteTag {
  Id id;

  String? cloudDocumentId;

  @Index(unique: true)
  String name;

  NoteTag({
    required this.name,
    required this.cloudDocumentId,
  }) : id = Isar.autoIncrement;

  @override
  bool operator ==(covariant NoteTag other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NoteTag{id: $id, name: $name}';
  }
}
