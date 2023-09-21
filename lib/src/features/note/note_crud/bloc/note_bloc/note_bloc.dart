import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartx/dartx.dart';
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
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/synchronizer.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteInitializedState _getInitializedState({
    String? snackBarText,
    bool hasUser = true,
    Set<LocalNote>? deletedNotes,
  }) =>
      NoteInitializedState(
        isLoading: false,
        user: _user,
        notesData: () => _adaptedNotesData,
        filterProps: _getFilterProps,
        sortProps: _sortProps,
        groupProps: _groupProps,
        noteTags: () => _allNoteTags,
        hasSelectedNotes: _selectedNotes.isNotEmpty,
        selectedNotes: () => _getSelectedNotes,
        layoutPreference: _layoutPreference,
        snackBarText: snackBarText,
        deletedNotes: deletedNotes,
      );

  String _searchParameter = '';

  final Set<int> _selectedNotes = <int>{};

  ValueStream<Set<LocalNote>> get _getSelectedNotes => LocalStore
      .note.allItemStream
      .map<Set<LocalNote>>((notes) =>
          notes.where((note) => _selectedNotes.contains(note.isarId)).toSet())
      .shareValue();

  SortProps _sortProps = const SortProps(
    mode: SortMode.dataCreated,
    order: SortOrder.descending,
  );

  GroupProps _groupProps = const GroupProps(
    groupParameter: GroupParameter.none,
    groupOrder: GroupOrder.descending,
    tagGroupLogic: TagGroupLogic.separateCombinations,
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

  ValueStream<Map<String, List<PresentableNoteData>>> get _adaptedNotesData {
    // Processing the stream using the search parameter
    late final ValueStream<List<PresentableNoteData>> queriedStream;
    if (_searchParameter.isEmpty) {
      queriedStream = Rx.combineLatest2(
          LocalStore.note.allItemStream, _allNoteTags, (allNotes, tags) {
        final notes = allNotes.where((note) => !note.isTrashed);
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

    // Processing the stream using the sorting mode
    late final ValueStream<List<PresentableNoteData>> sortedStream;
    switch (_sortProps.mode) {
      case SortMode.dateModified:
        if (_sortProps.order == SortOrder.descending) {
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
        if (_sortProps.order == SortOrder.descending) {
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

    // Processing the stream using the grouping type
    late final ValueStream<Map<String, List<PresentableNoteData>>>
        groupedStream;
    switch (_groupProps.groupParameter) {
      case GroupParameter.dateModified:
        groupedStream = sortedStream
            .map<Map<String, List<PresentableNoteData>>>((notesData) =>
                groupByModified(
                  notesData: notesData,
                  inAscending: _groupProps.groupOrder == GroupOrder.ascending,
                ))
            .shareValue();
      case GroupParameter.dateCreated:
        groupedStream = sortedStream
            .map<Map<String, List<PresentableNoteData>>>((notesData) =>
                groupByCreated(
                  notesData: notesData,
                  inAscending: _groupProps.groupOrder == GroupOrder.ascending,
                ))
            .shareValue();
      case GroupParameter.tag:
        groupedStream = sortedStream
            .map<Map<String, List<PresentableNoteData>>>(
                (notesData) => groupByTag(
                      notesData: notesData,
                      tagGroupLogic: _groupProps.tagGroupLogic,
                    ))
            .shareValue();
      case GroupParameter.none:
        groupedStream = sortedStream
            .map<Map<String, List<PresentableNoteData>>>(
                (noteData) => {'': noteData})
            .shareValue();
    }
    return groupedStream;
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
          emit(_getInitializedState(hasUser: false));
        } else {
          CloudStore.open();
          await LocalStore.open();
          log('Isar opened in NoteBloc, user logged in');
          emit(_getInitializedState());

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
        emit(_getInitializedState());
      },
    );

    // Modify note filter
    on<NoteModifyFilteringEvent>((event, emit) {
      _filterProps.requireEntireFilter = event.requireEntireFilter;

      if (event.selectedTagId != null) {
        if (_getFilterProps.filterSet.contains(event.selectedTagId!)) {
          _setFilterTagIds.remove(event.selectedTagId!);
        } else {
          _setFilterTagIds.add(event.selectedTagId!);
        }
      }
      emit(_getInitializedState());
    });

    // Modify sort type
    on<NoteModifySortingEvent>((event, emit) {
      _sortProps = SortProps(
        mode: event.sortMode,
        order: event.sortOrder,
      );
      emit(_getInitializedState());
    });

    // Modify grouping props
    on<NoteModifyGroupingEvent>((event, emit) {
      _groupProps = GroupProps(
        groupParameter: event.groupParameter,
        groupOrder: event.groupOrder,
        tagGroupLogic: event.tagGroupLogic,
      );
      emit(_getInitializedState());
    });

    // Delete note
    on<NoteDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.notes) {
          // await LocalStore.note.deleteItem(id: note.isarId);
          await LocalStore.note.updateItem(id: note.isarId, isTrashed: true);
          _selectedNotes.remove(note.isarId);
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: _user,
            notesData: () => _adaptedNotesData,
            filterProps: _getFilterProps,
            sortProps: _sortProps,
            groupProps: _groupProps,
            noteTags: () => _allNoteTags,
            hasSelectedNotes: _selectedNotes.isNotEmpty,
            selectedNotes: () => _getSelectedNotes,
            deletedNotes: event.notes,
            layoutPreference: _layoutPreference,
          ),
        );
      },
    );

    // Tap on a note
    on<NoteTapEvent>(
      (event, emit) async {
        if (_selectedNotes.contains(event.note.isarId)) {
          _selectedNotes.remove(event.note.isarId);
        } else {
          _selectedNotes.add(event.note.isarId);
        }
        emit(_getInitializedState());
      },
    );

    // Long press on a note
    on<NoteLongPressEvent>(
      (event, emit) async {
        if (_selectedNotes.contains(event.note.isarId)) {
          _selectedNotes.remove(event.note.isarId);
        } else {
          _selectedNotes.add(event.note.isarId);
        }
        emit(_getInitializedState());
      },
    );

    // Select notes
    on<NoteSelectEvent>((event, emit) {
      _selectedNotes.addAll(event.notes.map<int>((e) => e.isarId));
      emit(_getInitializedState());
    });

    // Unselect notes
    on<NoteUnselectEvent>((event, emit) {
      _selectedNotes.removeAll(event.notes.map<int>((e) => e.isarId));
      emit(_getInitializedState());
    });

    // Select all notes
    on<NoteSelectAllEvent>(
      (event, emit) async {
        _selectedNotes.clear();
        _selectedNotes.addAll((await LocalStore.note.getAllItems)
            .where((note) => !note.isTrashed)
            .map((note) => note.isarId));
        emit(_getInitializedState());
      },
    );

    // Unselect all notes
    on<NoteUnselectAllEvent>(
      (event, emit) {
        _selectedNotes.clear();
        emit(_getInitializedState());
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
            color: newColor,
            isSyncedWithCloud: false,
          );
        }
        emit(_getInitializedState());
      },
    );

    // Copy note
    on<NoteCopyEvent>(
      (event, emit) async {
        await Clipboard.setData(
          ClipboardData(text: '${event.note.title}\n${event.note.content}'),
        );
        emit(_getInitializedState(snackBarText: 'Note copied to clipboard'));
      },
    );

    // Share note
    on<NoteShareEvent>(
      (event, emit) async {
        await Share.share(event.note.content);
        emit(_getInitializedState());
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
        emit(_getInitializedState());
      },
    );

    // Restore a deleted note
    on<NoteUndoDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.deletedNotes) {
          await LocalStore.note.updateItem(
            id: note.isarId,
            isSyncedWithCloud: false,
            isTrashed: false,
          );
        }
        emit(_getInitializedState());
      },
    );

    // On creating a new note tag
    on<NoteCreateTagEvent>(
      (event, emit) async {
        final String tagName = event.name;
        if (tagName.isEmpty || tagName.replaceAll(' ', '').isEmpty) {
          emit(_getInitializedState(
              snackBarText: 'Please enter a name for the tag.'));
        } else {
          final tag = await LocalStore.noteTag.createItem();
          try {
            await LocalStore.noteTag.updateItem(
              id: tag.isarId,
              name: event.name,
            );
          } on DuplicateNoteTagException {
            await LocalStore.noteTag.deleteItem(id: tag.isarId);
            emit(_getInitializedState(
                snackBarText: 'A tag with the given name already exists.'));
          } on CouldNotUpdateNoteTagException {
            emit(_getInitializedState(
                snackBarText: 'Oops. Could not create the tag.'));
          }
        }
      },
    );

    // On editing an existing note tag
    on<NoteEditTagEvent>(
      (event, emit) async {
        final String tagName = event.newName;
        if (tagName.isEmpty || tagName.replaceAll(' ', '').isEmpty) {
          emit(_getInitializedState(
              snackBarText: 'Please enter a name for the tag.'));
        } else {
          try {
            await LocalStore.noteTag.updateItem(
              id: event.tag.isarId,
              name: event.newName,
            );
          } on CouldNotFindNoteTagException {
            emit(_getInitializedState(
                snackBarText: 'Could not find the tag to update.'));
          } on CouldNotUpdateNoteTagException {
            emit(_getInitializedState(
                snackBarText: 'Oops. Could not update tag'));
          } on DuplicateNoteTagException {
            emit(_getInitializedState(
                snackBarText: 'A tag with the given name already exists.'));
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
          emit(_getInitializedState(
              snackBarText: 'Could not find the tag to delete.'));
        } on CouldNotDeleteNoteTagException {
          emit(
              _getInitializedState(snackBarText: 'Oops. Could not delete tag'));
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
  required Set<int> filterTagIds,
}) {
  return notesData
      .where((noteData) =>
          filterTagIds.intersection(Set.from(noteData.note.tagIds)).isNotEmpty)
      .toList();
}

Map<String, List<PresentableNoteData>> groupByModified({
  required List<PresentableNoteData> notesData,
  required bool inAscending,
}) {
  Map<String, List<PresentableNoteData>> groupedData = {};

  final now = DateTime.now();

  final notesToday = notesData
      .where((noteData) => noteData.note.modified.toLocal().isToday)
      .toList();
  if (notesToday.isNotEmpty) {
    groupedData['Today'] = notesToday;
    notesData.removeWhere((noteData) => notesToday
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesYesterday = notesData
      .where((noteData) => noteData.note.modified.toLocal().wasYesterday)
      .toList();
  if (notesYesterday.isNotEmpty) {
    groupedData['Yesterday'] = notesYesterday;
    notesData.removeWhere((noteData) => notesYesterday
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesThisWeek = notesData.where((noteData) {
    final startOfThisWeek = (now.weekday + 1).days.ago;
    final isSameWeek =
        noteData.note.modified.toLocal().between(startOfThisWeek, now);
    return isSameWeek;
  }).toList();
  if (notesThisWeek.isNotEmpty) {
    groupedData['Earlier this Week'] = notesThisWeek;
    notesData.removeWhere((noteData) => notesThisWeek
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesLastWeek = notesData.where((noteData) {
    final endOfLastWeek = now.weekday.days.ago;
    final startOfLastWeek = (now.weekday + 6).days.ago;
    final isSameWeek = (noteData.note.modified
        .toLocal()
        .between(startOfLastWeek, endOfLastWeek));
    return isSameWeek;
  }).toList();
  if (notesLastWeek.isNotEmpty) {
    groupedData['Last Week'] = notesLastWeek;
    notesData.removeWhere((noteData) => notesLastWeek
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesThisMonth = notesData.where((noteData) {
    final monthDiff = now.month - noteData.note.modified.toLocal().month;
    final yearDiff = now.year - noteData.note.modified.toLocal().year;
    return (monthDiff == 0) && (yearDiff == 0);
  }).toList();
  if (notesThisMonth.isNotEmpty) {
    groupedData['Earlier this month'] = notesThisMonth;
    notesData.removeWhere((noteData) => notesThisMonth
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesLastMonth = notesData.where((noteData) {
    final yearDiff = now.year - noteData.note.modified.toLocal().year;
    final monthDiff = now.month - noteData.note.modified.toLocal().month;
    final wasLastMonth = ((yearDiff * 12 + monthDiff) == 1);
    return wasLastMonth;
  }).toList();
  if (notesLastMonth.isNotEmpty) {
    groupedData['Last month'] = notesLastMonth;
    notesData.removeWhere((noteData) => notesLastMonth
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesEarlierThisYear = notesData.where((noteData) {
    final yearDiff = now.year - noteData.note.modified.toLocal().year;
    return (yearDiff == 0);
  }).toList();
  if (notesEarlierThisYear.isNotEmpty) {
    groupedData['Earlier this year'] = notesEarlierThisYear;
    notesData.removeWhere((noteData) => notesEarlierThisYear
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  int year = now.year;
  while (notesData.isNotEmpty) {
    final groupYear = --year;
    final notesOfYear = notesData.where((noteData) {
      return (groupYear == noteData.note.modified.toLocal().year);
    }).toList();
    if (notesOfYear.isNotEmpty) {
      groupedData['In ${groupYear.toString()}'] = notesOfYear;
      notesData.removeWhere((noteData) => notesOfYear
          .any((element) => element.note.isarId == noteData.note.isarId));
    }
  }

  if (inAscending) {
    Map<String, List<PresentableNoteData>> groupedDataReversed = {};
    for (String key in groupedData.keys.reversed) {
      groupedDataReversed[key] = groupedData[key]!;
    }
    return groupedDataReversed;
  } else {
    return groupedData;
  }
}

Map<String, List<PresentableNoteData>> groupByCreated({
  required List<PresentableNoteData> notesData,
  required bool inAscending,
}) {
  Map<String, List<PresentableNoteData>> groupedData = {};

  final now = DateTime.now();

  final notesToday = notesData
      .where((noteData) => noteData.note.created.toLocal().isToday)
      .toList();
  if (notesToday.isNotEmpty) {
    groupedData['Today'] = notesToday;
    notesData.removeWhere((noteData) => notesToday
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesYesterday = notesData
      .where((noteData) => noteData.note.created.toLocal().wasYesterday)
      .toList();
  if (notesYesterday.isNotEmpty) {
    groupedData['Yesterday'] = notesYesterday;
    notesData.removeWhere((noteData) => notesYesterday
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesThisWeek = notesData.where((noteData) {
    final startOfThisWeek = (now.weekday + 1).days.ago;
    final isSameWeek =
        noteData.note.created.toLocal().between(startOfThisWeek, now);
    return isSameWeek;
  }).toList();
  if (notesThisWeek.isNotEmpty) {
    groupedData['Earlier this Week'] = notesThisWeek;
    notesData.removeWhere((noteData) => notesThisWeek
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesLastWeek = notesData.where((noteData) {
    final endOfLastWeek = now.weekday.days.ago;
    final startOfLastWeek = (now.weekday + 6).days.ago;
    final isSameWeek = (noteData.note.created
        .toLocal()
        .between(startOfLastWeek, endOfLastWeek));
    return isSameWeek;
  }).toList();
  if (notesLastWeek.isNotEmpty) {
    groupedData['Last Week'] = notesLastWeek;
    notesData.removeWhere((noteData) => notesLastWeek
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesThisMonth = notesData.where((noteData) {
    final monthDiff = now.month - noteData.note.created.toLocal().month;
    final yearDiff = now.year - noteData.note.created.toLocal().year;
    return (monthDiff == 0) && (yearDiff == 0);
  }).toList();
  if (notesThisMonth.isNotEmpty) {
    groupedData['Earlier this month'] = notesThisMonth;
    notesData.removeWhere((noteData) => notesThisMonth
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesLastMonth = notesData.where((noteData) {
    final yearDiff = now.year - noteData.note.created.toLocal().year;
    final monthDiff = now.month - noteData.note.created.toLocal().month;
    final wasLastMonth = ((yearDiff * 12 + monthDiff) == 1);
    return wasLastMonth;
  }).toList();
  if (notesLastMonth.isNotEmpty) {
    groupedData['Last month'] = notesLastMonth;
    notesData.removeWhere((noteData) => notesLastMonth
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  final notesEarlierThisYear = notesData.where((noteData) {
    final yearDiff = now.year - noteData.note.created.toLocal().year;
    return (yearDiff == 0);
  }).toList();
  if (notesEarlierThisYear.isNotEmpty) {
    groupedData['Earlier this year'] = notesEarlierThisYear;
    notesData.removeWhere((noteData) => notesEarlierThisYear
        .any((element) => element.note.isarId == noteData.note.isarId));
  }

  int year = now.year;
  while (notesData.isNotEmpty) {
    final groupYear = --year;
    final notesOfYear = notesData.where((noteData) {
      return (groupYear == noteData.note.created.toLocal().year);
    }).toList();
    if (notesOfYear.isNotEmpty) {
      groupedData['In ${groupYear.toString()}'] = notesOfYear;
      notesData.removeWhere((noteData) => notesOfYear
          .any((element) => element.note.isarId == noteData.note.isarId));
    }
  }

  if (inAscending) {
    Map<String, List<PresentableNoteData>> groupedDataReversed = {};
    for (String key in groupedData.keys.reversed) {
      groupedDataReversed[key] = groupedData[key]!;
    }
    return groupedDataReversed;
  } else {
    return groupedData;
  }
}

Map<String, List<PresentableNoteData>> groupByTag({
  required List<PresentableNoteData> notesData,
  required TagGroupLogic tagGroupLogic,
}) {
  Map<String, List<PresentableNoteData>> groupedData = {};
  switch (tagGroupLogic) {
    case TagGroupLogic.separateCombinations:
      for (var noteData in notesData) {
        String groupName = noteData.noteTags.joinToString(
          transform: (tag) => tag.name,
          separator: ', ',
        );
        if (groupName.isEmpty) groupName = 'No tags';
        groupedData[groupName] ??= [];
        groupedData[groupName]!.add(noteData);
      }
    case TagGroupLogic.showInAll:
      for (var noteData in notesData) {
        if (noteData.noteTags.isEmpty) {
          groupedData['No tags'] ??= [];
          groupedData['No tags']!.add(noteData);
          continue;
        }
        for (final tag in noteData.noteTags) {
          groupedData[tag.name] ??= [];
          groupedData[tag.name]!.add(noteData);
        }
      }
    case TagGroupLogic.showInOne:
      for (var noteData in notesData) {
        if (noteData.noteTags.isEmpty) {
          groupedData['No tags'] ??= [];
          groupedData['No tags']!.add(noteData);
          continue;
        }
        groupedData[noteData.noteTags.first.name] ??= [];
        groupedData[noteData.noteTags.first.name]!.add(noteData);
      }
  }
  return groupedData;
}
