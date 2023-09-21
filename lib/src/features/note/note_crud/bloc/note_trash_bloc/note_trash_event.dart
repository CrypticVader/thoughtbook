part of 'note_trash_bloc.dart';

abstract class NoteTrashEvent {
  const NoteTrashEvent();
}

class NoteTrashInitializeEvent extends NoteTrashEvent {
  const NoteTrashInitializeEvent();
}

class NoteTrashRestoreEvent extends NoteTrashEvent {
  final Set<LocalNote> notes;

  const NoteTrashRestoreEvent({required this.notes});
}

class NoteTrashDeleteEvent extends NoteTrashEvent {
  final Set<LocalNote> notes;

  const NoteTrashDeleteEvent({required this.notes});
}

class NoteTrashTapEvent extends NoteTrashEvent {
  final LocalNote note;
  final void Function() openNote;

  const NoteTrashTapEvent({
    required this.note,
    required this.openNote,
  });
}

class NoteTrashLongPressEvent extends NoteTrashEvent {
  final LocalNote note;

  const NoteTrashLongPressEvent({
    required this.note,
  });
}

class NoteTrashSelectAllEvent extends NoteTrashEvent {
  const NoteTrashSelectAllEvent();
}

class NoteTrashToggleLayoutEvent extends NoteTrashEvent {
  const NoteTrashToggleLayoutEvent();
}
