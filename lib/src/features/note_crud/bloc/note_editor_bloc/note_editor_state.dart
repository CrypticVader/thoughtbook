import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';

@immutable
abstract class NoteEditorState {
  const NoteEditorState();
}

class NoteEditorUninitializedState extends NoteEditorState {
  const NoteEditorUninitializedState();
}

class NoteEditorNoNoteState extends NoteEditorState {
  const NoteEditorNoNoteState();
}

class NoteEditorInitializedState extends NoteEditorState {
  final Stream<LocalNote> noteStream;

  const NoteEditorInitializedState({
    required this.noteStream,
  });
}

class NoteEditorWithSnackbarState extends NoteEditorState {
  final String snackBarText;

  const NoteEditorWithSnackbarState({
    required this.snackBarText,
  });
}

class NoteEditorDeletedState extends NoteEditorState {
  final LocalNote deletedNote;

  const NoteEditorDeletedState({required this.deletedNote});
}
