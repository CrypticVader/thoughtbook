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
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/synchronizer.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  ValueStream<List<LocalNote>> get allNotes => LocalStore.note.allItemStream;

  ValueStream<List<LocalNoteTag>> get allNoteTags =>
      LocalStore.noteTag.allItemStream;

  ValueStream<List<PresentableNoteData>> get allNoteData => Rx.combineLatest2<
          List<LocalNote>,
          List<LocalNoteTag>,
          List<PresentableNoteData>>(allNotes, allNoteTags, (notes, tags) {
        List<PresentableNoteData> noteData = [];
        for (final note in notes) {
          final noteTags = tags
              .where(
                (tag) => note.tagIds.contains(tag.isarId),
              )
              .toList();
          noteData.add(PresentableNoteData(
            note: note,
            noteTags: noteTags,
          ));
        }
        return noteData;
      }).shareValue();

  AuthUser? get user => AuthService.firebase().currentUser;

  String get layoutPreference =>
      AppPreferenceService().getPreference(PreferenceKey.layout) as String;

  NoteBloc()
      : super(const NoteUninitializedState(
          isLoading: true,
          user: null,
        )) {
    // Initialize
    on<NoteInitializeEvent>(
      (event, emit) async {
        if (user == null) {
          await LocalStore.open(
              // noteChange: false,
              // noteTagChange: false,
              );
          log('Isar opened in NoteBloc, no user');
          emit(
            NoteInitializedState(
              isLoading: false,
              user: null,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
            ),
          );
        } else {
          CloudStore.open();
          await LocalStore.open();
          log('Isar opened in NoteBloc, user logged in');
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
            ),
          );

          // Start local to cloud sync service
          unawaited(Synchronizer.note.startSync());
          unawaited(Synchronizer.noteTag.startSync());
        }
        log('NoteBloc initialized');
      },
    );

    // Delete note
    on<NoteDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.notes) {
          await LocalStore.note.deleteItem(id: note.isarId);
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            deletedNotes: event.notes,
            layoutPreference: layoutPreference,
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
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: newSelectedNotes,
              layoutPreference: layoutPreference,
            ),
          );
        } else {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: event.selectedNotes + [event.note],
              layoutPreference: layoutPreference,
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
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: newSelectedNotes,
              layoutPreference: layoutPreference,
            ),
          );
        } else {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: event.selectedNotes + [event.note],
              layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: notes,
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            snackBarText: 'Note copied to clipboard',
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            layoutPreference: layoutPreference,
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
            user: user,
            // notes: () => allNotes,
              noteData: () => allNoteData,
            noteTags: () => allNoteTags,
            selectedNotes: const [],
            layoutPreference: layoutPreference,
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
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
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
                user: user,
                // notes: () => allNotes,
              noteData: () => allNoteData,
                noteTags: () => allNoteTags,
                selectedNotes: const [],
                layoutPreference: layoutPreference,
                snackBarText: 'A tag with the given name already exists.',
              ),
            );
          } on CouldNotUpdateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: user,
                // notes: () => allNotes,
              noteData: () => allNoteData,
                noteTags: () => allNoteTags,
                selectedNotes: const [],
                layoutPreference: layoutPreference,
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
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
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
                user: user,
                // notes: () => allNotes,
              noteData: () => allNoteData,
                noteTags: () => allNoteTags,
                selectedNotes: const [],
                layoutPreference: layoutPreference,
                snackBarText: 'Could not find the tag to update.',
              ),
            );
          } on CouldNotUpdateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: user,
                // notes: () => allNotes,
              noteData: () => allNoteData,
                noteTags: () => allNoteTags,
                selectedNotes: const [],
                layoutPreference: layoutPreference,
                snackBarText: 'Oops. Could not update tag',
              ),
            );
          } on DuplicateNoteTagException {
            emit(
              NoteInitializedState(
                isLoading: false,
                user: user,
                // notes: () => allNotes,
              noteData: () => allNoteData,
                noteTags: () => allNoteTags,
                selectedNotes: const [],
                layoutPreference: layoutPreference,
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
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
              snackBarText: 'Could not find the tag to delete.',
            ),
          );
        } on CouldNotDeleteNoteTagException {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              // notes: () => allNotes,
              noteData: () => allNoteData,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
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
