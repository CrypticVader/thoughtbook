import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/extensions/object/null_check.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/synchronizer.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  String _searchParameter = '';

  final Set<int> _selectedNoteIds = <int>{};

  ValueStream<Set<LocalNote>> get _getSelectedNotes => LocalStore.note.allItemStream
      .map((notes) => notes.where((note) => _selectedNoteIds.contains(note.isarId)).toSet())
      .shareValue();

  SortProps _sortProps = const SortProps(
    mode: SortMode.dateCreated,
    order: SortOrder.descending,
  );

  GroupProps _groupProps = const GroupProps(
    groupParameter: GroupParameter.none,
    groupOrder: GroupOrder.descending,
    tagGroupLogic: TagGroupLogic.separateCombinations,
  );

  final FilterProps _filterProps = FilterProps.noFilters();

  FilterProps get _getFilterProps => FilterProps(
        filterTagIds: Set.from(_filterProps.filterTagIds),
        requireEntireTagFilter: _filterProps.requireEntireTagFilter,
        modifiedRange: _filterProps.modifiedRange,
        createdRange: _filterProps.createdRange,
        filterColors: Set.from(_filterProps.filterColors),
      );

  AuthUser? get _user => AuthService.firebase().currentUser;

  String get _layoutPreference =>
      AppPreferenceService().getPreference(PreferenceKey.layout) as String;

  ValueStream<List<LocalNoteTag>> get _allNoteTags => LocalStore.noteTag.allItemStream;

  NoteInitialized _getInitializedState({
    String? snackBarText,
    Set<LocalNote>? deletedNotes,
  }) =>
      NoteInitialized(
        isLoading: false,
        user: _user,
        notesData: () => _adaptedNotesData,
        filterProps: _getFilterProps,
        sortProps: _sortProps,
        groupProps: _groupProps,
        noteTags: () => _allNoteTags,
        hasSelectedNotes: _selectedNoteIds.isNotEmpty,
        selectedNotes: () => _getSelectedNotes,
        layoutPreference: _layoutPreference,
        snackBarText: snackBarText,
        deletedNotes: deletedNotes,
      );

  ValueStream<Map<String, List<PresentableNoteData>>> get _adaptedNotesData => Rx.combineLatest2(
        LocalStore.note.allItemStream,
        _allNoteTags,
        (allNotes, tags) => (allNotes.where((note) => !note.isTrashed), tags),
      ).transform<Map<String, List<PresentableNoteData>>>(
          StreamTransformer.fromHandlers(handleData: (data, sink) async {
        final adapted = await NoteProcessor.processNotes(
          notes: data.$1,
          tags: data.$2,
          searchQuery: _searchParameter,
          groupProps: _groupProps,
          filterProps: _getFilterProps,
          sortProps: _sortProps,
        );
        sink.add(adapted);
      })).shareValue();

  NoteBloc()
      : super(const NoteUninitialized(
          isLoading: true,
          user: null,
        )) {
    // Initialize
    on<NoteInitializeEvent>(
      (event, emit) async {
        if (_user == null) {
          await LocalStore.open();
          for (var i = 0; i < 200; i++) {
            final note = await LocalStore.note.createItem();
            await LocalStore.note.updateItem(
              id: note.isarId,
              content: DateTime.now().toString(),
              title: DateTime.timestamp().toString(),
            );
          }
          for (var i = 0; i < 200; i++) {
            final note = await LocalStore.note.createItem();
            await LocalStore.note.updateItem(
              id: note.isarId,
              content: DateTime.now().toString(),
              title: DateTime.timestamp().toString(),
              modified: DateTime(2022),
            );
          }
          log('Isar opened in NoteBloc, no user');
          emit(_getInitializedState());
        } else {
          await CloudStore.open();
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
    on<NoteModifyFilterEvent>((event, emit) {
      final newProps = event.props;
      if (_getFilterProps.requireEntireTagFilter != newProps.requireEntireTagFilter) {
        _filterProps.requireEntireTagFilter = newProps.requireEntireTagFilter;
      }
      if (_getFilterProps.filterTagIds != newProps.filterTagIds) {
        _filterProps.filterTagIds = newProps.filterTagIds;
      }
      if (_getFilterProps.modifiedRange != newProps.modifiedRange) {
        _filterProps.modifiedRange = newProps.modifiedRange;
      }
      if (_getFilterProps.createdRange != newProps.createdRange) {
        _filterProps.createdRange = newProps.createdRange;
      }
      if (_getFilterProps.filterColors != newProps.filterColors) {
        _filterProps.filterColors = newProps.filterColors;
        log(_filterProps.filterColors.toString());
      }
      emit(_getInitializedState());
    });

    // Modify sort type
    on<NoteModifySortEvent>((event, emit) {
      _sortProps = SortProps(
        mode: event.sortMode,
        order: event.sortOrder,
      );
      emit(_getInitializedState());
    });

    // Modify grouping props
    on<NoteModifyGroupPropsEvent>((event, emit) {
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
          await LocalStore.note.updateItem(
            id: note.isarId,
            isTrashed: true,
            modified: note.modified,
          );
          _selectedNoteIds.remove(note.isarId);
        }
        emit(
          NoteInitialized(
            isLoading: false,
            user: _user,
            notesData: () => _adaptedNotesData,
            filterProps: _getFilterProps,
            sortProps: _sortProps,
            groupProps: _groupProps,
            noteTags: () => _allNoteTags,
            hasSelectedNotes: _selectedNoteIds.isNotEmpty,
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
        if (_selectedNoteIds.contains(event.note.isarId)) {
          _selectedNoteIds.remove(event.note.isarId);
        } else {
          _selectedNoteIds.add(event.note.isarId);
        }
        emit(_getInitializedState());
      },
    );

    // Long press on a note
    on<NoteLongPressEvent>(
      (event, emit) async {
        if (_selectedNoteIds.contains(event.note.isarId)) {
          _selectedNoteIds.remove(event.note.isarId);
        } else {
          _selectedNoteIds.add(event.note.isarId);
        }
        emit(_getInitializedState());
      },
    );

    // Select notes
    on<NoteSelectEvent>((event, emit) {
      _selectedNoteIds.addAll(event.notes.map<int>((e) => e.isarId));
      emit(_getInitializedState());
    });

    // Unselect notes
    on<NoteUnselectEvent>((event, emit) {
      _selectedNoteIds.removeAll(event.notes.map<int>((e) => e.isarId));
      emit(_getInitializedState());
    });

    // Select all notes
    on<NoteSelectAllEvent>(
      (event, emit) async {
        _selectedNoteIds.clear();
        _selectedNoteIds.addAll((await LocalStore.note.getAllItems)
            .where((note) => !note.isTrashed)
            .map((note) => note.isarId));
        emit(_getInitializedState());
      },
    );

    // Unselect all notes
    on<NoteUnselectAllEvent>(
      (event, emit) {
        _selectedNoteIds.clear();
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
        final currentLayout = AppPreferenceService().getPreference(PreferenceKey.layout) as String;

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
            modified: note.modified,
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
          emit(_getInitializedState(snackBarText: 'Please enter a name for the tag.'));
        } else {
          final tag = await LocalStore.noteTag.createItem();
          try {
            await LocalStore.noteTag.updateItem(
              id: tag.isarId,
              name: event.name,
            );
          } on DuplicateNoteTagException {
            await LocalStore.noteTag.deleteItem(id: tag.isarId);
            emit(_getInitializedState(snackBarText: 'A tag with the given name already exists.'));
          } on CouldNotUpdateNoteTagException {
            emit(_getInitializedState(snackBarText: 'Oops. Could not create the tag.'));
          }
        }
      },
    );

    // On editing an existing note tag
    on<NoteEditTagEvent>(
      (event, emit) async {
        final String tagName = event.newName;
        if (tagName.isEmpty || tagName.replaceAll(' ', '').isEmpty) {
          emit(_getInitializedState(snackBarText: 'Please enter a name for the tag.'));
        } else {
          try {
            await LocalStore.noteTag.updateItem(
              id: event.tag.isarId,
              name: event.newName,
            );
          } on CouldNotFindNoteTagException {
            emit(_getInitializedState(snackBarText: 'Could not find the tag to update.'));
          } on CouldNotUpdateNoteTagException {
            emit(_getInitializedState(snackBarText: 'Oops. Could not update tag'));
          } on DuplicateNoteTagException {
            emit(_getInitializedState(snackBarText: 'A tag with the given name already exists.'));
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
          emit(_getInitializedState(snackBarText: 'Could not find the tag to delete.'));
        } on CouldNotDeleteNoteTagException {
          emit(_getInitializedState(snackBarText: 'Oops. Could not delete tag'));
        }
      },
    );
  }
}

abstract class FilterFunctions {
  static List<PresentableNoteData> usingProps({
    required List<PresentableNoteData> notesData,
    required FilterProps props,
  }) {
    List<PresentableNoteData> filteredData = notesData;
    if (props.filterTagIds.isNotEmpty) {
      filteredData = props.requireEntireTagFilter
          ? getNotesWithAllTags(notesData: notesData, filterTagIds: props.filterTagIds)
          : getNotesWithAnyTag(notesData: notesData, filterTagIds: props.filterTagIds);
    }
    if (props.filterColors.isNotEmpty) {
      filteredData = getNotesWithColor(notesData: filteredData, colorValues: props.filterColors);
    }
    if (props.createdRange.isNotNull) {
      filteredData = getNotesInDateRange(
        notesData: filteredData,
        range: props.createdRange!,
        dateParam: (note) => note.created,
      );
    }
    if (props.modifiedRange.isNotNull) {
      filteredData = getNotesInDateRange(
        notesData: filteredData,
        range: props.modifiedRange!,
        dateParam: (note) => note.modified,
      );
    }

    return filteredData;
  }

  static List<PresentableNoteData> getNotesWithAllTags({
    required List<PresentableNoteData> notesData,
    required Set<int> filterTagIds,
  }) {
    return notesData
        .where((noteData) =>
            filterTagIds.intersection(Set.from(noteData.note.tagIds)).length == filterTagIds.length)
        .toList();
  }

  static List<PresentableNoteData> getNotesWithAnyTag({
    required List<PresentableNoteData> notesData,
    required Set<int> filterTagIds,
  }) {
    return notesData
        .where((noteData) => filterTagIds.intersection(Set.from(noteData.note.tagIds)).isNotEmpty)
        .toList();
  }

  static List<PresentableNoteData> getNotesWithColor({
    required List<PresentableNoteData> notesData,
    required Set<int> colorValues,
  }) {
    return notesData.where((noteData) {
      final colorValue = noteData.note.color;
      if (colorValue.isNotNull && colorValues.contains(colorValue)) {
        return true;
      } else {
        return false;
      }
    }).toList();
  }

  static List<PresentableNoteData> getNotesInDateRange({
    required List<PresentableNoteData> notesData,
    required DateTimeRange range,
    required DateTime Function(LocalNote note) dateParam,
  }) {
    return notesData
        .where(
          (noteData) => dateParam(noteData.note).between(range.start, range.end) ? true : false,
        )
        .toList();
  }

  static List<PresentableNoteData> getNotesWithQuery({
    required List<PresentableNoteData> notesData,
    required String query,
  }) {
    return query.isEmpty
        ? notesData
        : notesData.where((noteData) {
            final tagContainsQuery =
                noteData.noteTags.map((tag) => tag.name).any((tagName) => tagName.contains(query));
            if (tagContainsQuery) return true;
            final contentContainsQuery = noteData.note.content.contains(query);
            if (contentContainsQuery) return true;
            final titleContainsQuery = noteData.note.title.contains(query);
            return titleContainsQuery;
          }).toList();
  }
}

abstract class GroupFunctions {
  static Map<String, List<PresentableNoteData>> usingProps({
    required List<PresentableNoteData> notesData,
    required GroupProps props,
  }) {
    switch (props.groupParameter) {
      case GroupParameter.dateModified:
        return groupByDate(
          notesData: notesData,
          inAscending: props.groupOrder == GroupOrder.ascending,
          dateParam: (note) => note.modified,
        );
      case GroupParameter.dateCreated:
        return groupByDate(
          notesData: notesData,
          inAscending: props.groupOrder == GroupOrder.ascending,
          dateParam: (note) => note.created,
        );
      case GroupParameter.tag:
        return groupByTag(
          notesData: notesData,
          tagGroupLogic: props.tagGroupLogic,
        );
      case GroupParameter.none:
        return notesData.isEmpty ? {} : {'': notesData};
    }
  }

  static Map<String, List<PresentableNoteData>> groupByDate({
    required List<PresentableNoteData> notesData,
    required bool inAscending,
    required DateTime Function(LocalNote note) dateParam,
  }) {
    Map<String, List<PresentableNoteData>> groupedData = {};

    final now = DateTime.now();

    final notesToday =
        notesData.where((noteData) => dateParam(noteData.note).toLocal().isToday).toList();
    if (notesToday.isNotEmpty) {
      groupedData['Today'] = notesToday;
      notesData.removeWhere(
          (noteData) => notesToday.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesYesterday =
        notesData.where((noteData) => dateParam(noteData.note).toLocal().wasYesterday).toList();
    if (notesYesterday.isNotEmpty) {
      groupedData['Yesterday'] = notesYesterday;
      notesData.removeWhere((noteData) =>
          notesYesterday.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesThisWeek = notesData.where((noteData) {
      final startOfThisWeek = (now.weekday + 1).days.ago;
      final isSameWeek = dateParam(noteData.note).toLocal().between(startOfThisWeek, now);
      return isSameWeek;
    }).toList();
    if (notesThisWeek.isNotEmpty) {
      groupedData['Earlier this Week'] = notesThisWeek;
      notesData.removeWhere((noteData) =>
          notesThisWeek.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesLastWeek = notesData.where((noteData) {
      if (now.month != dateParam(noteData.note).month) return false;
      final endOfLastWeek = now.weekday.days.ago;
      final startOfLastWeek = (now.weekday + 6).days.ago;
      final isSameWeek =
      (dateParam(noteData.note).toLocal().between(startOfLastWeek, endOfLastWeek));
      return isSameWeek;
    }).toList();
    if (notesLastWeek.isNotEmpty) {
      groupedData['Last Week'] = notesLastWeek;
      notesData.removeWhere((noteData) =>
          notesLastWeek.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesThisMonth = notesData.where((noteData) {
      final monthDiff = now.month - dateParam(noteData.note).toLocal().month;
      final yearDiff = now.year - dateParam(noteData.note).toLocal().year;
      return (monthDiff == 0) && (yearDiff == 0);
    }).toList();
    if (notesThisMonth.isNotEmpty) {
      groupedData['Earlier this month'] = notesThisMonth;
      notesData.removeWhere((noteData) =>
          notesThisMonth.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesLastMonth = notesData.where((noteData) {
      final yearDiff = now.year - dateParam(noteData.note).toLocal().year;
      final monthDiff = now.month - dateParam(noteData.note).toLocal().month;
      final wasLastMonth = ((yearDiff * 12 + monthDiff) == 1);
      return wasLastMonth;
    }).toList();
    if (notesLastMonth.isNotEmpty) {
      groupedData['Last month'] = notesLastMonth;
      notesData.removeWhere((noteData) =>
          notesLastMonth.any((element) => element.note.isarId == noteData.note.isarId));
    }

    final notesEarlierThisYear = notesData.where((noteData) {
      final yearDiff = now.year - dateParam(noteData.note).toLocal().year;
      return (yearDiff == 0);
    }).toList();
    if (notesEarlierThisYear.isNotEmpty) {
      groupedData['Earlier this year'] = notesEarlierThisYear;
      notesData.removeWhere((noteData) =>
          notesEarlierThisYear.any((element) => element.note.isarId == noteData.note.isarId));
    }

    int year = now.year;
    while (notesData.isNotEmpty) {
      final groupYear = --year;
      final notesOfYear = notesData.where((noteData) {
        return (groupYear == dateParam(noteData.note).toLocal().year);
      }).toList();
      if (notesOfYear.isNotEmpty) {
        groupedData['In ${groupYear.toString()}'] = notesOfYear;
        notesData.removeWhere((noteData) =>
            notesOfYear.any((element) => element.note.isarId == noteData.note.isarId));
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

  static Map<String, List<PresentableNoteData>> groupByTag({
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
}

abstract class SortFunctions {
  static List<PresentableNoteData> usingProps({
    required List<PresentableNoteData> notesData,
    required SortProps props,
  }) {
    return sortByDate(
      notesData: notesData,
      isAscending: props.order == SortOrder.ascending,
      dateParam: (note) => (props.mode == SortMode.dateModified) ? note.modified : note.created,
    );
  }

  static List<PresentableNoteData> sortByDate({
    required List<PresentableNoteData> notesData,
    required bool isAscending,
    required DateTime Function(LocalNote note) dateParam,
  }) {
    isAscending
        ? notesData.sort((a, b) => dateParam(a.note).compareTo(dateParam(b.note)))
        : notesData.sort((a, b) => -dateParam(a.note).compareTo(dateParam(b.note)));
    return notesData;
  }
}

class NoteProcessor {
  static final _processorIsolateManager = IsolateManager.create(
    _processNotes,
    isDebug: false,
    workerName: 'worker',
    workerConverter: (p0) {
      log('worker message');
      return p0;
    },
  )..start();

  @pragma('vm:entry-point')
  static Map<String, List<PresentableNoteData>> _processNotes(
      ({
        Iterable<LocalNote> notes,
        Iterable<LocalNoteTag> tags,
        String searchQuery,
        GroupProps groupProps,
        FilterProps filterProps,
        SortProps sortProps,
      }) params) {
    List<PresentableNoteData> notesData = [];
    for (final note in params.notes) {
      final noteTags = params.tags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
      notesData.add(PresentableNoteData(note: note, noteTags: noteTags));
    }

    // Processing the stream using the search parameter
    notesData = FilterFunctions.getNotesWithQuery(notesData: notesData, query: params.searchQuery);

    // Processing the stream using the filters
    notesData = FilterFunctions.usingProps(notesData: notesData, props: params.filterProps);

    // Processing the stream using the sorting props
    notesData = SortFunctions.usingProps(notesData: notesData, props: params.sortProps);

    // Processing the stream using the grouping props
    return GroupFunctions.usingProps(notesData: notesData, props: params.groupProps);
  }

  /// Runs the computation in a background isolate.
  ///
  /// Not available on the web, where this function runs its synchronous counterpart in the main thread.
  static Future<Map<String, List<PresentableNoteData>>> processNotes({
    required Iterable<LocalNote> notes,
    required Iterable<LocalNoteTag> tags,
    required String searchQuery,
    required GroupProps groupProps,
    required FilterProps filterProps,
    required SortProps sortProps,
  }) async {
    if (kIsWeb) {
      return Future.value(_processNotes((
        notes: notes,
        tags: tags,
        searchQuery: searchQuery,
        groupProps: groupProps,
        filterProps: filterProps,
        sortProps: sortProps,
      )));
    } else {
      final result = await _processorIsolateManager.compute((
        notes: notes,
        tags: tags,
        searchQuery: searchQuery,
        groupProps: groupProps,
        filterProps: filterProps,
        sortProps: sortProps,
      ));
      return result;
    }
  }
}
