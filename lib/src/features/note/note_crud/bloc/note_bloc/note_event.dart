import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';

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

class NoteModifyFilterEvent extends NoteEvent {
  final FilterProps props;

  const NoteModifyFilterEvent({required this.props});
}

class NoteModifySortEvent extends NoteEvent {
  final SortOrder sortOrder;
  final SortMode sortMode;

  const NoteModifySortEvent({
    required this.sortMode,
    required this.sortOrder,
  });
}

class NoteModifyGroupPropsEvent extends NoteEvent {
  final GroupParameter groupParameter;
  final GroupOrder groupOrder;
  final TagGroupLogic tagGroupLogic;

  const NoteModifyGroupPropsEvent({
    required this.groupParameter,
    required this.groupOrder,
    required this.tagGroupLogic,
  });
}

class NoteDeleteEvent extends NoteEvent {
  /// List of notes to be deleted
  final Set<LocalNote> notes;

  const NoteDeleteEvent({
    required this.notes,
  });
}

class NoteTapEvent extends NoteEvent {
  /// Note that was tapped
  final LocalNote note;

  const NoteTapEvent({
    required this.note,
  });
}

class NoteLongPressEvent extends NoteEvent {
  /// Note that was long pressed
  final LocalNote note;

  const NoteLongPressEvent({
    required this.note,
  });
}

class NoteSelectEvent extends NoteEvent {
  final Iterable<LocalNote> notes;

  const NoteSelectEvent({required this.notes});
}

class NoteUnselectEvent extends NoteEvent {
  final Iterable<LocalNote> notes;

  const NoteUnselectEvent({required this.notes});
}

class NoteUnselectAllEvent extends NoteEvent {
  const NoteUnselectAllEvent();
}

class NoteSelectAllEvent extends NoteEvent {
  const NoteSelectAllEvent();
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
  final Set<LocalNote> deletedNotes;

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
