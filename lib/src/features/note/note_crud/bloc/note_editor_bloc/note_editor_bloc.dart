import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/local_note_service.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  late final int noteIsarId;

  Future<Stream<LocalNote>> get noteStream async =>
      await LocalNoteService().getNoteAsStream(isarId: noteIsarId);

  Future<LocalNote> get note async {
    LocalNote note;
    try {
      note = await LocalNoteService().getNote(isarId: noteIsarId);
      return note;
    } on CouldNotFindNoteException {
      log(
        name: 'NoteEditorBloc',
        'LocalNote does not exist to handle NoteEditorEvent',
      );
      rethrow;
    }
  }

  NoteEditorBloc() : super(const NoteEditorUninitializedState()) {
    // Initialize editor state
    on<NoteEditorInitializeEvent>(
      (event, emit) async {
        if (state is NoteEditorInitializedState) {
          throw NoteEditorBlocAlreadyInitializedException();
        }

        if (event.note == null) {
          LocalNote note = await LocalNoteService().createNote();
          noteIsarId = note.isarId;
        } else {
          noteIsarId = event.note!.isarId;
        }

        emit(
          NoteEditorInitializedState(
            noteStream: await noteStream,
            snackBarText: '',
            isEditable: false,
          ),
        );
      },
    );

    // Close note editor
    on<NoteEditorCloseEvent>(
      (event, emit) async {
        if (state is NoteEditorDeletedState) {
          return;
        }

        final note = await this.note;
        if (note.title.isEmpty && note.content.isEmpty) {
          await LocalNoteService().deleteNote(isarId: note.isarId);
        }
      },
    );

    // Change Editor view type (Preview/Edit)
    on<NoteEditorChangeViewTypeEvent>(
      (event, emit) async {
        emit(NoteEditorInitializedState(
          snackBarText: '',
          isEditable: !event.wasEditable,
          noteStream: await noteStream,
        ));
      },
    );

    // Update note shown by editor
    on<NoteEditorUpdateEvent>(
      (event, emit) async {
        final note = await this.note;
        if (note.content != event.newContent || note.title != event.newTitle) {
          await LocalNoteService().updateNote(
            isarId: note.isarId,
            title: event.newTitle,
            content: event.newContent,
            tags: note.tags,
            color: note.color,
            isSyncedWithCloud: false,
            debounceChangeFeedEvent: true,
          );
        }
      },
    );

    // Share note
    on<NoteEditorShareEvent>(
      (event, emit) async {
        if (state is NoteEditorInitializedState) {
          final NoteEditorInitializedState currentState =
              state as NoteEditorInitializedState;
          final note = await this.note;
          if (note.content.isEmpty && note.title.isEmpty) {
            emit(
              NoteEditorInitializedState(
                snackBarText: 'Cannot share empty note',
                isEditable: currentState.isEditable,
                noteStream: currentState.noteStream,
              ),
            );
          } else {
            await Share.share('${note.title}\n${note.content}');
          }
        }
      },
    );

    // Update the tags of the note
    on<NoteEditorUpdateTagsEvent>(
      (event, emit) async {
        final note = await this.note;
        await LocalNoteService().updateNote(
          isarId: note.isarId,
          title: note.title,
          content: note.content,
          tags: event.tags,
          color: note.color,
          isSyncedWithCloud: false,
        );
      },
    );

    // Update the color of the note
    on<NoteEditorUpdateColorEvent>(
      (event, emit) async {
        final note = await this.note;
        final newColor = event.newColor;
        await LocalNoteService().updateNote(
          isarId: note.isarId,
          title: note.title,
          content: note.content,
          tags: note.tags,
          color: (newColor != null) ? newColor.value : null,
          isSyncedWithCloud: false,
        );
      },
    );

    // Copy note
    on<NoteEditorCopyEvent>(
      (event, emit) async {
        if (state is NoteEditorInitializedState) {
          final NoteEditorInitializedState currentState =
              state as NoteEditorInitializedState;
          final note = await this.note;
          String snackBarText;
          if (note.content.isEmpty && note.title.isEmpty) {
            snackBarText = 'Cannot copy empty note.';
          } else {
            await Clipboard.setData(
              ClipboardData(
                text: '${note.title}\n${note.content}',
              ),
            );
            snackBarText = 'Note copied to clipboard.';
          }
          emit(
            NoteEditorInitializedState(
              snackBarText: snackBarText,
              isEditable: currentState.isEditable,
              noteStream: currentState.noteStream,
            ),
          );
        }
      },
    );

    // Delete note
    on<NoteEditorDeleteEvent>(
      (event, emit) async {
        final note = await this.note;
        // The actual delete operation is delegated to the NoteBloc by the presentation layer.
        // This facilitates showing a SnackBar to undo the deletion.
        emit(NoteEditorDeletedState(
          deletedNote: note,
          snackBarText: '',
        ));
      },
    );
  }

  @override
  void onTransition(Transition<NoteEditorEvent, NoteEditorState> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }
}

class NoteEditorBlocAlreadyInitializedException implements Exception {}
