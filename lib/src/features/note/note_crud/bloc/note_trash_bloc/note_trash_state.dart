part of 'note_trash_bloc.dart';

abstract class NoteTrashState extends Equatable {
  const NoteTrashState();
}

class NoteTrashUninitialized extends NoteTrashState {
  @override
  List<Object> get props => [];
}

class NoteTrashInitialized extends NoteTrashState {
  final ValueStream<List<PresentableNoteData>> Function() trashedNotes;
  final Set<LocalNote> selectedNotes;
  final String layout;

  const NoteTrashInitialized({
    required this.trashedNotes,
    required this.selectedNotes,
    required this.layout,
  });

  @override
  List<Object> get props => [
        selectedNotes,
        layout,
        trashedNotes,
      ];
}
