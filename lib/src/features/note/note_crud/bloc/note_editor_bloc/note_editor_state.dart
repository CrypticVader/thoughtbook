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

class NoteEditorUninitializedState extends NoteEditorState {
  const NoteEditorUninitializedState() : super('');
}

class NoteEditorInitializedState extends NoteEditorState {
  final ValueStream<LocalNote> Function() noteStream;
  final ValueStream<PresentableNoteData> Function() noteData;
  final ValueStream<List<LocalNoteTag>> Function() allNoteTags;
  final bool isEditable;

  const NoteEditorInitializedState({
    required String snackBarText,
    required this.isEditable,
    required this.noteStream,
    required this.noteData,
    required this.allNoteTags,
  }) : super(snackBarText);
}

class NoteEditorDeletedState extends NoteEditorState {
  final LocalNote deletedNote;

  const NoteEditorDeletedState({
    required this.deletedNote,
    required String snackBarText,
  }) : super(snackBarText);
}
