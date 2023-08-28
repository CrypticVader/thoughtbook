import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/sort_type.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/synchronizer.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  String _searchParameter = '';

  SortType _sortType = const SortType(
    mode: SortMode.dataCreated,
    order: SortOrder.descending,
  );

  final FilterProps _filterProps = FilterProps(
    filterSet: <int>{},
    requireEntireFilter: false,
  );

  FilterProps get _getFilterProps => FilterProps(
        filterSet: Set.from(_filterProps.filterSet),
        requireEntireFilter: _filterProps.requireEntireFilter,
      );

  Set<int> get _setFilterTagIds => _filterProps.filterSet;

  AuthUser? get _user => AuthService.firebase().currentUser;

  String get _layoutPreference =>
      AppPreferenceService().getPreference(PreferenceKey.layout) as String;

  ValueStream<List<LocalNoteTag>> get _allNoteTags =>
      LocalStore.noteTag.allItemStream;

  ValueStream<List<PresentableNoteData>> get _notesData {
    // Processing the stream using the search parameter
    late final ValueStream<List<PresentableNoteData>> queriedStream;
    if (_searchParameter.isEmpty) {
      queriedStream = Rx.combineLatest2(
          LocalStore.note.allItemStream, _allNoteTags, (notes, tags) {
        List<PresentableNoteData> noteData = [];
        for (final note in notes) {
          final noteTags =
              tags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
          noteData.add(PresentableNoteData(note: note, noteTags: noteTags));
        }
        return noteData;
      }).shareValue();
    } else {
      queriedStream = Rx.combineLatest2(
          LocalStore.note.allItemStream, _allNoteTags, (notes, tags) {
        List<PresentableNoteData> noteData = [];
        for (final note in notes) {
          final noteTags =
              tags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
          final noteContainsQuery = note.title.contains(_searchParameter) ||
              note.content.contains(_searchParameter);
          final tagContainsQuery = noteTags
              .where((tag) => tag.name.contains(_searchParameter))
              .isNotEmpty;
          if (noteContainsQuery || tagContainsQuery) {
            noteData.add(PresentableNoteData(note: note, noteTags: noteTags));
          }
        }
        return noteData;
      }).shareValue();
    }

    // Processing the stream using the filter set
    late final ValueStream<List<PresentableNoteData>> filteredStream;
    if (_getFilterProps.filterSet.isEmpty) {
      filteredStream = queriedStream;
    } else {
      filteredStream = queriedStream
          .transform<List<PresentableNoteData>>(StreamTransformer.fromHandlers(
        handleData: (notesData, sink) {
          late final List<PresentableNoteData> filteredData;
          if (_getFilterProps.requireEntireFilter) {
            filteredData = getNotesWithAllTags(
              notesData: notesData,
              filterTagIds: _getFilterProps.filterSet,
            );
          } else {
            filteredData = getNotesWithAnyTag(
              notesData: notesData,
              filterTagIds: _getFilterProps.filterSet,
            );
          }
          sink.add(filteredData);
        },
      )).shareValue();
    }

    // Processing the stream using the sort mode
    late final ValueStream<List<PresentableNoteData>> sortedStream;
    switch (_sortType.mode) {
      case SortMode.dateModified:
        if (_sortType.order == SortOrder.descending) {
          sortedStream = filteredStream.map((notesData) {
            notesData
                .sort((a, b) => -a.note.modified.compareTo(b.note.modified));
            return notesData;
          }).shareValue();
        } else {
          sortedStream = filteredStream.map((notesData) {
            notesData
                .sort((a, b) => a.note.modified.compareTo(b.note.modified));
            return notesData;
          }).shareValue();
        }
      case SortMode.dataCreated:
        if (_sortType.order == SortOrder.descending) {
          sortedStream = filteredStream.map((notesData) {
            notesData.sort((a, b) => -a.note.created.compareTo(b.note.created));
            return notesData;
          }).shareValue();
        } else {
          sortedStream = filteredStream.map((notesData) {
            notesData.sort((a, b) => a.note.created.compareTo(b.note.created));
            return notesData;
          }).shareValue();
        }
    }
    return sortedStream;
  }

  NoteBloc()
      : super(const NoteUninitializedState(
          isLoading: true,
          user: null,
        )) {
    // Initialize
    on<NoteInitializeEvent>(
      (event, emit) async {
        if (_user == null) {
          await LocalStore.open(
              // noteChange: false,
              // noteTagChange: false,
              );
          log('Isar opened in NoteBloc, no user');
          emit(
            NoteInitializedState(
              isLoading: false,
              user: null,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
            ),
          );
        } else {
          CloudStore.open();
          await LocalStore.open();
          log('Isar opened in NoteBloc, user logged in');
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
            ),
          );

          // Start local to cloud sync service
          unawaited(Synchronizer.note.startSync());
          unawaited(Synchronizer.noteTag.startSync());
        }
        log('NoteBloc initialized');
      },
    );

    // Search notes
    on<NoteSearchEvent>(
      (event, emit) {
        _searchParameter = event.query;
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Modify note filter
    on<NoteModifyFilterEvent>((event, emit) {
      _filterProps.requireEntireFilter = event.requireEntireFilter;

      if (event.selectedTagId != null) {
        if (_getFilterProps.filterSet.contains(event.selectedTagId!)) {
          _setFilterTagIds.remove(event.selectedTagId!);
        } else {
          _setFilterTagIds.add(event.selectedTagId!);
        }
      }
      emit(
        NoteInitializedState(
          isLoading: false,
          user: _user,
          noteData: () => _notesData,
          filterProps: _getFilterProps,
          sortType: _sortType,
          noteTags: () => _allNoteTags,
          selectedNotes: const [],
          layoutPreference: _layoutPreference,
        ),
      );
    });

    // Modify sort type
    on<NoteModifySortEvent>((event, emit) {
      _sortType = SortType(mode: event.sortMode, order: event.sortOrder);
      emit(
        NoteInitializedState(
          isLoading: false,
          user: _user,
          noteData: () => _notesData,
          filterProps: _getFilterProps,
          sortType: _sortType,
          noteTags: () => _allNoteTags,
          selectedNotes: const [],
          layoutPreference: _layoutPreference,
        ),
      );
    });

    // Delete note
    on<NoteDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.notes) {
          await LocalStore.note.deleteItem(id: note.isarId);
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            deletedNotes: event.notes,
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Tap on a note
    on<NoteTapEvent>(
      (event, emit) async {
        if (event.selectedNotes.contains(event.note)) {
          final List<LocalNote> newSelectedNotes = event.selectedNotes
              .where((element) => element.isarId != event.note.isarId)
              .toList();
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: newSelectedNotes,
              layoutPreference: _layoutPreference,
            ),
          );
        } else {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: event.selectedNotes + [event.note],
              layoutPreference: _layoutPreference,
            ),
          );
        }
      },
    );

    // Long press on a note
    on<NoteLongPressEvent>(
      (event, emit) async {
        if (event.selectedNotes.contains(event.note)) {
          final List<LocalNote> newSelectedNotes = event.selectedNotes
              .where((element) => element.isarId != event.note.isarId)
              .toList();
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: newSelectedNotes,
              layoutPreference: _layoutPreference,
            ),
          );
        } else {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: event.selectedNotes + [event.note],
              layoutPreference: _layoutPreference,
            ),
          );
        }
      },
    );

    // Unselect all notes
    on<NoteUnselectAllEvent>(
      (event, emit) {
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Select all notes
    on<NoteEventSelectAllNotes>(
      (event, emit) async {
        final List<LocalNote> notes = await LocalStore.note.getAllItems;
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: notes,
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Update note color
    on<NoteUpdateColorEvent>(
      (event, emit) async {
        final currentColor = event.note.color;
        final newColor = event.color;
        if (newColor != currentColor) {
          await LocalStore.note.updateItem(
            id: event.note.isarId,
            title: event.note.title,
            content: event.note.content,
            tags: event.note.tagIds,
            color: newColor,
            isSyncedWithCloud: false,
          );
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Copy note
    on<NoteCopyEvent>(
      (event, emit) async {
        await Clipboard.setData(
          ClipboardData(text: '${event.note.title}\n${event.note.content}'),
        );
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            snackBarText: 'Note copied to clipboard',
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Share note
    on<NoteShareEvent>(
      (event, emit) async {
        await Share.share(event.note.content);
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Toggle note view layout
    on<NoteToggleLayoutEvent>(
      (event, emit) async {
        final currentLayout = AppPreferenceService()
            .getPreference(PreferenceKey.layout) as String;

        if (currentLayout == LayoutPreference.list.value) {
          await AppPreferenceService().setPreference(
            key: PreferenceKey.layout,
            value: LayoutPreference.grid.value,
          );
        } else if (currentLayout == LayoutPreference.grid.value) {
          await AppPreferenceService().setPreference(
            key: PreferenceKey.layout,
            value: LayoutPreference.list.value,
          );
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Create New Note, used to restore a deleted note
    on<NoteUndoDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.deletedNotes) {
          final newNote = await LocalStore.note.createItem();
          await LocalStore.note.updateItem(
            id: newNote.isarId,
            title: note.title,
            content: note.content,
            tags: note.tagIds,
            color: note.color,
            isSyncedWithCloud: false,
            created: note.created,
            modified: note.modified,
          );
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            noteData: () => _notesData,
            filterProps: _getFilterProps,
            sortType: _sortType,
            noteTags: () => _allNoteTags,
            selectedNotes: const [],
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // On creating a new note tag
    on<NoteCreateTagEvent>(
      (event, emit) async {
        final String tagName = event.name;
        if (tagName.isEmpty || tagName.replaceAll(' ', '').isEmpty) {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
              snackBarText: 'Please enter a name for the tag.',
            ),
          );
        } else {
          final tag = await LocalStore.noteTag.createItem();
          try {
            await LocalStore.noteTag.updateItem(
              id: tag.isarId,
              name: event.name,
            );
          } on DuplicateNoteTagException {
            await LocalStore.noteTag.deleteItem(id: tag.isarId);
            emit(
              NoteInitializedState(
                isLoading: false,
                user: _user,
                noteData: () => _notesData,
                filterProps: _getFilterProps,
                sortType: _sortType,
                noteTags: () => _allNoteTags,
                selectedNotes: const [],
                layoutPreference: _layoutPreference,
                snackBarText: 'A tag with the given name already exists.',
              ),
            );
          } on CouldNotUpdateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: _user,
                noteData: () => _notesData,
                filterProps: _getFilterProps,
                sortType: _sortType,
                noteTags: () => _allNoteTags,
                selectedNotes: const [],
                layoutPreference: _layoutPreference,
                snackBarText: 'Oops. Could not create the tag.',
              ),
            );
          }
        }
      },
    );

    // On editing an existing note tag
    on<NoteEditTagEvent>(
      (event, emit) async {
        final String tagName = event.newName;
        if (tagName.isEmpty || tagName.replaceAll(' ', '').isEmpty) {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
              snackBarText: 'Please enter a name for the tag.',
            ),
          );
        } else {
          try {
            await LocalStore.noteTag.updateItem(
              id: event.tag.isarId,
              name: event.newName,
            );
          } on CouldNotFindNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: _user,
                noteData: () => _notesData,
                filterProps: _getFilterProps,
                sortType: _sortType,
                noteTags: () => _allNoteTags,
                selectedNotes: const [],
                layoutPreference: _layoutPreference,
                snackBarText: 'Could not find the tag to update.',
              ),
            );
          } on CouldNotUpdateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: _user,
                noteData: () => _notesData,
                filterProps: _getFilterProps,
                sortType: _sortType,
                noteTags: () => _allNoteTags,
                selectedNotes: const [],
                layoutPreference: _layoutPreference,
                snackBarText: 'Oops. Could not update tag',
              ),
            );
          } on DuplicateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: _user,
                noteData: () => _notesData,
                filterProps: _getFilterProps,
                sortType: _sortType,
                noteTags: () => _allNoteTags,
                selectedNotes: const [],
                layoutPreference: _layoutPreference,
                snackBarText: 'A tag with the given name already exists.',
              ),
            );
          }
        }
      },
    );

    // On deleting an existing note tag
    on<NoteDeleteTagEvent>(
      (event, emit) async {
        try {
          await LocalStore.noteTag.deleteItem(id: event.tag.isarId);
        } on CouldNotFindNoteTagException {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
              snackBarText: 'Could not find the tag to delete.',
            ),
          );
        } on CouldNotDeleteNoteTagException {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: _user,
              noteData: () => _notesData,
              filterProps: _getFilterProps,
              sortType: _sortType,
              noteTags: () => _allNoteTags,
              selectedNotes: const [],
              layoutPreference: _layoutPreference,
              snackBarText: 'Oops. Could not delete tag',
            ),
          );
        }
      },
    );
  }

  @override
  void onTransition(Transition<NoteEvent, NoteState> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }
}

List<PresentableNoteData> getNotesWithAllTags({
  required List<PresentableNoteData> notesData,
  required Set<int> filterTagIds,
}) {
  return notesData
      .where((noteData) =>
          filterTagIds.intersection(Set.from(noteData.note.tagIds)).length ==
          filterTagIds.length)
      .toList();
}

List<PresentableNoteData> getNotesWithAnyTag({
  required List<PresentableNoteData> notesData,

  /// Do not access this field directly. Use its getter `getFilterTagIds` to read,
  /// & the setter 'setFilterTagIds' only if necessary.
  required Set<int> filterTagIds,
}) {
  return notesData
      .where((noteData) =>
          filterTagIds.intersection(Set.from(noteData.note.tagIds)).isNotEmpty)
      .toList();
}

class FilterProps {
  Set<int> filterSet;
  bool requireEntireFilter;

  FilterProps({
    required this.filterSet,
    required this.requireEntireFilter,
  });
}
