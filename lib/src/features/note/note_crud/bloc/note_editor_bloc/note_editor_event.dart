import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';

@immutable
abstract class NoteEditorEvent {
  const NoteEditorEvent();
}

class NoteEditorInitializeEvent extends NoteEditorEvent {
  final LocalNote? note;

  const NoteEditorInitializeEvent({required this.note});
}

class NoteEditorShareEvent extends NoteEditorEvent {
  const NoteEditorShareEvent();
}

class NoteEditorCopyEvent extends NoteEditorEvent {
  const NoteEditorCopyEvent();
}

class NoteEditorUpdateEvent extends NoteEditorEvent {
  final String newTitle;
  final String newContent;

  const NoteEditorUpdateEvent({
    required this.newTitle,
    required this.newContent,
  });
}

class NoteEditorUpdateColorEvent extends NoteEditorEvent {
  final Color? newColor;

  const NoteEditorUpdateColorEvent({required this.newColor});
}

class NoteEditorUpdateTagEvent extends NoteEditorEvent {
  final LocalNoteTag selectedTag;

  const NoteEditorUpdateTagEvent({required this.selectedTag});
}

class NoteEditorDeleteEvent extends NoteEditorEvent {
  const NoteEditorDeleteEvent();
}

class NoteEditorCloseEvent extends NoteEditorEvent {
  const NoteEditorCloseEvent();
}

class NoteEditorUndoEvent extends NoteEditorEvent {
  final String currentTitle;
  final String currentContent;

  const NoteEditorUndoEvent({
    required this.currentContent,
    required this.currentTitle,
  });
}

class NoteEditorRedoEvent extends NoteEditorEvent {
  final String currentTitle;
  final String currentContent;

  const NoteEditorRedoEvent({
    required this.currentContent,
    required this.currentTitle,
  });
}
