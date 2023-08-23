import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';

@immutable
abstract class NoteEditorState {
  final String snackBarText;

  const NoteEditorState(this.snackBarText);
}

class NoteEditorUninitializedState extends NoteEditorState {
  const NoteEditorUninitializedState() : super('');
}

class NoteEditorInitializedState extends NoteEditorState {
  final Stream<LocalNote> noteStream;
  final bool isEditable;

  const NoteEditorInitializedState({
    required snackBarText,
    required this.isEditable,
    required this.noteStream,
  }) : super(snackBarText);
}

class NoteEditorDeletedState extends NoteEditorState {
  final LocalNote deletedNote;

  const NoteEditorDeletedState({
    required this.deletedNote,
    required snackBarText,
  }) : super(snackBarText);
}
