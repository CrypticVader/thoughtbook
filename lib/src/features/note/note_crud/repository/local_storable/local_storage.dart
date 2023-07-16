import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_tag_storable.dart';

class LocalStorage {
  static LocalNoteStorable get note => LocalNoteStorable();

  static LocalNoteTagStorable get noteTag => LocalNoteTagStorable();
}
