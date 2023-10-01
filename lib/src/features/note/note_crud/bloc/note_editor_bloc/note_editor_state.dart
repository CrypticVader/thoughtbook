import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';

@immutable
abstract class NoteEditorState {
  final String snackBarText;

  const NoteEditorState(this.snackBarText);
}

class NoteEditorUninitialized extends NoteEditorState {
  const NoteEditorUninitialized() : super('');
}

class NoteEditorInitialized extends NoteEditorState {
  final ValueStream<LocalNote> Function() noteStream;
  final ValueStream<PresentableNoteData> Function() noteData;
  final ValueStream<List<LocalNoteTag>> Function() allNoteTags;
  final bool canUndo;
  final bool canRedo;
  final ({String content, String title})? textFieldValues;

  const NoteEditorInitialized({
    required String snackBarText,
    this.textFieldValues,
    required this.canUndo,
    required this.canRedo,
    required this.noteStream,
    required this.noteData,
    required this.allNoteTags,
  }) : super(snackBarText);
}

class NoteEditorDeleted extends NoteEditorState {
  final LocalNote deletedNote;

  const NoteEditorDeleted({
    required this.deletedNote,
    required String snackBarText,
  }) : super(snackBarText);
}
