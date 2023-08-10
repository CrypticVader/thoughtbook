import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_tag_storable.dart';

class CloudStore {
  static CloudNoteStorable? _note;
  static CloudNoteTagStorable? _noteTag;

  static CloudNoteStorable get note => _note!;

  static CloudNoteTagStorable get noteTag => _noteTag!;

  static void open() {
    _note = CloudNoteStorable();
    _noteTag = CloudNoteTagStorable();
  }

  static void close() {
    _note = null;
    _noteTag = null;
  }
}
