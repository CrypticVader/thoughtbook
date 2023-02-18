import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/services/note/bloc/note_event.dart';
import 'package:thoughtbook/services/note/bloc/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(const NoteStateDeselected()) {
    // note opened
    on<NoteEventOpen>(
      (event, emit) {
        emit(NoteStateOpened(isEmpty: event.note.text.isEmpty));
      },
    );
  }
}
