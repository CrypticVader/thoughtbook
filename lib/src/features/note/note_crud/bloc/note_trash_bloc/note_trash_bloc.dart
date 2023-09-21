import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

part 'note_trash_event.dart';

part 'note_trash_state.dart';

class NoteTrashBloc extends Bloc<NoteTrashEvent, NoteTrashState> {
  Set<LocalNote> _selectedNotes = <LocalNote>{};
  String _layout = LayoutPreference.list.value;

  ValueStream<List<PresentableNoteData>> trashedNotes() => Rx.combineLatest2(
          LocalStore.note.allItemStream, LocalStore.noteTag.allItemStream,
          (notes, tags) {
        final trashedNotes = notes.where((note) => note.isTrashed);
        List<PresentableNoteData> noteData = [];
        for (final note in trashedNotes) {
          final noteTags =
              tags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
          noteData.add(PresentableNoteData(note: note, noteTags: noteTags));
        }
        return noteData;
      }).shareValue();

  NoteTrashBloc() : super(NoteTrashUninitialized()) {
    on<NoteTrashInitializeEvent>((event, emit) {
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });

    on<NoteTrashRestoreEvent>((event, emit) async {
      for (final note in event.notes) {
        await LocalStore.note.updateItem(id: note.isarId, isTrashed: false);
        _selectedNotes.remove(note);
      }
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });

    on<NoteTrashDeleteEvent>((event, emit) async {
      for (final note in event.notes) {
        await LocalStore.note.deleteItem(id: note.isarId);
        _selectedNotes.remove(note);
      }
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });

    on<NoteTrashSelectAllEvent>((event, emit) async {
      _selectedNotes = (await LocalStore.note.getAllItems)
          .where((element) => element.isTrashed)
          .toSet();
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });

    on<NoteTrashTapEvent>((event, emit) {
      if (_selectedNotes.isNotEmpty) {
        if (_selectedNotes.contains(event.note)) {
          _selectedNotes.remove(event.note);
        } else {
          _selectedNotes.add(event.note);
        }
        emit(NoteTrashInitialized(
          layout: _layout,
          trashedNotes: trashedNotes,
          selectedNotes: Set.from(_selectedNotes),
        ));
      } else {
        event.openNote();
      }
    });

    on<NoteTrashLongPressEvent>((event, emit) {
      if (_selectedNotes.contains(event.note)) {
        _selectedNotes.remove(event.note);
      } else {
        _selectedNotes.add(event.note);
      }
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });

    on<NoteTrashToggleLayoutEvent>((event, emit) {
      if (_layout == LayoutPreference.list.value) {
        _layout = LayoutPreference.grid.value;
      } else {
        _layout = LayoutPreference.list.value;
      }
      emit(NoteTrashInitialized(
        layout: _layout,
        trashedNotes: trashedNotes,
        selectedNotes: Set.from(_selectedNotes),
      ));
    });
  }
}
