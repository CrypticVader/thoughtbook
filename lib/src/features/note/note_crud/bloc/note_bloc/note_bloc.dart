import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_sync_service/note_sync_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  Stream<List<LocalNote>> get allNotes => LocalNoteService().allNotes;

  Stream<List<NoteTag>> get allNoteTags => LocalNoteService().allNoteTags;

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
      (event, emit) {
        if (user == null) {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: null,
              notes: () => allNotes,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
            ),
          );
        } else {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              notes: () => allNotes,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
            ),
          );

          // Start local to cloud sync service
          unawaited(NoteSyncService().setup());
        }
      },
    );

    // Delete note
    on<NoteDeleteEvent>(
      (event, emit) async {
        for (LocalNote note in event.notes) {
          await LocalNoteService().deleteNote(isarId: note.isarId);
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: user,
            notes: () => allNotes,
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
              notes: () => allNotes,
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
              notes: () => allNotes,
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
              notes: () => allNotes,
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
              notes: () => allNotes,
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
            notes: () => allNotes,
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
        final List<LocalNote> notes = await LocalNoteService().getAllNotes();
        emit(
          NoteInitializedState(
            isLoading: false,
            user: user,
            notes: () => allNotes,
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
          await LocalNoteService().updateNote(
            isarId: event.note.isarId,
            title: event.note.title,
            content: event.note.content,
            tags: event.note.tags,
            color: newColor,
            isSyncedWithCloud: false,
          );
        }
        emit(
          NoteInitializedState(
            isLoading: false,
            user: user,
            notes: () => allNotes,
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
            notes: () => allNotes,
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
            notes: () => allNotes,
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
            notes: () => allNotes,
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
          final newNote = await LocalNoteService().createNote();
          await LocalNoteService().updateNote(
            isarId: newNote.isarId,
            title: note.title,
            content: note.content,
            tags: note.tags,
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
            notes: () => allNotes,
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
        await LocalNoteService().createNoteTag(name: event.name);
      },
    );

    // On cediting an existing note tag
    on<NoteEditTagEvent>(
      (event, emit) async {
        try {
          await LocalNoteService().updateNoteTag(
            id: event.tag.id,
            name: event.tag.name,
          );
        } on CouldNotFindNoteTagException {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              notes: () => allNotes,
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
              notes: () => allNotes,
              noteTags: () => allNoteTags,
              selectedNotes: const [],
              layoutPreference: layoutPreference,
              snackBarText: 'Oops. Could not update tag',
            ),
          );
        }
      },
    );

    // On deleting an existing note tag
    on<NoteDeleteTagEvent>(
      (event, emit) async {
        try {
          await LocalNoteService().deleteNoteTag(id: event.tag.id);
        } on CouldNotFindNoteTagException {
          emit(
            NoteInitializedState(
              isLoading: false,
              user: user,
              notes: () => allNotes,
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
              notes: () => allNotes,
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
