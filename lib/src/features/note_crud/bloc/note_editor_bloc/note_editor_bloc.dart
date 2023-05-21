import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/local_note_service.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  late final int noteIsarId;

  Future<Stream<LocalNote>> get noteStream async =>
      await LocalNoteService().getNoteAsStream(isarId: noteIsarId);

  Future<LocalNote?> get note async {
    LocalNote note;
    try {
      note = await LocalNoteService().getNote(id: noteIsarId);
      return note;
    } on CouldNotFindNote {
      log(
        name: "NoteEditorBloc",
        "LocalNote does not exist to handle NoteEditorEvent",
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
          NoteEditorInitializedState(noteStream: await noteStream),
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
        if (note == null) {
          return;
        }
        if (note.title.isEmpty && note.content.isEmpty) {
          await LocalNoteService().deleteNote(isarId: note.isarId);
        }
      },
    );

    // Update note shown by editor
    on<NoteEditorUpdateEvent>(
          (event, emit) async {
        final note = await this.note;
        if (note == null) {
          return;
        }

        if (note.content != event.newContent || note.title != event.newTitle) {
          await LocalNoteService().updateNote(
            isarId: note.isarId,
            title: event.newTitle,
            content: event.newContent,
            color: note.color,
            isSyncedWithCloud: false,
          );
        }
      },
    );

    // Share note
    on<NoteEditorShareEvent>(
          (event, emit) async {
        final note = await this.note;
        if (note == null) {
          return;
        }

        if (note.content.isEmpty && note.title.isEmpty) {
          emit(
            const NoteEditorWithSnackbarState(
              snackBarText: 'Cannot share empty note',
            ),
          );
        } else {
          Share.share('${note.title}\n${note.content}');
        }
      },
    );

    // Update the color of the note
    on<NoteEditorUpdateColorEvent>(
          (event, emit) async {
        final note = await this.note;
        if (note == null) {
          return;
        }

        final newColor = event.newColor;
        await LocalNoteService().updateNote(
          isarId: note.isarId,
          title: note.title,
          content: note.content,
          color: (newColor != null) ? newColor.value : null,
          isSyncedWithCloud: false,
        );
      },
    );

    // Copy note
    on<NoteEditorCopyEvent>(
          (event, emit) async {
        final note = await this.note;
        if (note == null) {
          return;
        }

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
          NoteEditorWithSnackbarState(
            snackBarText: snackBarText,
          ),
        );
      },
    );

    // Delete note
    on<NoteEditorDeleteEvent>(
          (event, emit) async {
        final note = await this.note;
        if (note == null) {
          return;
        }

        // await LocalNoteService().deleteNote(
        //   isarId: note.isarId,
        // );

        // The actual delete operation is delegated to the NoteBloc.
        // This facilitates showing a SnackBar to undo the deletion.
        emit(NoteEditorDeletedState(deletedNote: note));
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
