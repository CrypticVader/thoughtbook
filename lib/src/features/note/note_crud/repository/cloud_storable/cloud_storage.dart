import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_tag_storable.dart';

class CloudStorage {
  static CloudNoteStorable get note => CloudNoteStorable();

  static CloudNoteTagStorable get noteTag => CloudNoteTagStorable();
}
