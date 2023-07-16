import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';

@immutable
abstract class NoteEvent {
  const NoteEvent();
}

class NoteInitializeEvent extends NoteEvent {
  const NoteInitializeEvent();
}

class NoteDeleteEvent extends NoteEvent {
  /// List of notes to be deleted
  final List<LocalNote> notes;

  const NoteDeleteEvent({
    required this.notes,
  });
}

class NoteTapEvent extends NoteEvent {
  /// Note that was tapped
  final LocalNote note;

  /// Existing list of selected notes
  final List<LocalNote> selectedNotes;

  const NoteTapEvent({
    required this.note,
    required this.selectedNotes,
  });
}

class NoteLongPressEvent extends NoteEvent {
  /// Note that was long pressed
  final LocalNote note;

  /// Existing list of selected notes
  final List<LocalNote> selectedNotes;

  const NoteLongPressEvent({
    required this.note,
    required this.selectedNotes,
  });
}

class NoteUnselectAllEvent extends NoteEvent {
  const NoteUnselectAllEvent();
}

class NoteEventSelectAllNotes extends NoteEvent {
  const NoteEventSelectAllNotes();
}

class NoteUpdateColorEvent extends NoteEvent {
  /// Note to be updated
  final LocalNote note;

  /// Value of the new color
  final int? color;

  const NoteUpdateColorEvent({
    required this.note,
    required this.color,
  });
}

class NoteCopyEvent extends NoteEvent {
  /// Note to be copied
  final LocalNote note;

  const NoteCopyEvent(
    this.note,
  );
}

class NoteShareEvent extends NoteEvent {
  /// Note to be shared
  final LocalNote note;

  const NoteShareEvent(
    this.note,
  );
}

class NoteToggleLayoutEvent extends NoteEvent {
  const NoteToggleLayoutEvent();
}

class NoteUndoDeleteEvent extends NoteEvent {
  /// List of notes to be restored
  final List<LocalNote> deletedNotes;

  const NoteUndoDeleteEvent({required this.deletedNotes});
}

class NoteCreateTagEvent extends NoteEvent {
  final String name;

  const NoteCreateTagEvent({required this.name});
}

class NoteEditTagEvent extends NoteEvent {
  final LocalNoteTag tag;
  final String newName;

  const NoteEditTagEvent({
    required this.tag,
    required this.newName,
  });
}

class NoteDeleteTagEvent extends NoteEvent {
  final LocalNoteTag tag;

  const NoteDeleteTagEvent({required this.tag});
}
