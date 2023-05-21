import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';

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

class NoteEditorDeleteEvent extends NoteEditorEvent {
  const NoteEditorDeleteEvent();
}

class NoteEditorCloseEvent extends NoteEditorEvent {
  const NoteEditorCloseEvent();
}
