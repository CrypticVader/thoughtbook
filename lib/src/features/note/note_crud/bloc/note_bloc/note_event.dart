import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/sort_props.dart';

@immutable
abstract class NoteEvent {
  const NoteEvent();
}

class NoteInitializeEvent extends NoteEvent {
  const NoteInitializeEvent();
}

class NoteSearchEvent extends NoteEvent {
  final String query;

  const NoteSearchEvent({required this.query});
}

class NoteModifyFilteringEvent extends NoteEvent {
  final int? selectedTagId;
  final bool requireEntireFilter;

  const NoteModifyFilteringEvent({
    required this.selectedTagId,
    required this.requireEntireFilter,
  });
}

class NoteModifySortingEvent extends NoteEvent {
  final SortOrder sortOrder;
  final SortMode sortMode;

  const NoteModifySortingEvent({
    required this.sortMode,
    required this.sortOrder,
  });
}

class NoteModifyGroupingEvent extends NoteEvent {
  final GroupParameter groupParameter;
  final GroupOrder groupOrder;
  final TagGroupLogic tagGroupLogic;

  const NoteModifyGroupingEvent({
    required this.groupParameter,
    required this.groupOrder,
    required this.tagGroupLogic,
  });
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
