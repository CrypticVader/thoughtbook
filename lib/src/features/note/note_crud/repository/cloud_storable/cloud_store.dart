import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_tag_storable.dart';

class CloudStore {
  static CloudNoteStorable? _note;
  static CloudNoteTagStorable? _noteTag;

  static CloudNoteStorable get note => _note!;

  static CloudNoteTagStorable get noteTag => _noteTag!;

  static Future<void> open() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: 1048576, // This is the minimum accepted value
    );
    _note = CloudNoteStorable();
    _noteTag = CloudNoteTagStorable();
  }

  static Future<void> close() async {
    _note = null;
    _noteTag = null;
  }
}
