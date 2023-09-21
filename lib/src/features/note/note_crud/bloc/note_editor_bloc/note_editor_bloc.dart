import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  int? _noteIsarId;

  ValueStream<LocalNote> noteStream() =>
      LocalStore.note.itemStream(id: _noteIsarId!);

  ValueStream<PresentableNoteData> presentableNote() =>
      Rx.combineLatest2<LocalNote, List<LocalNoteTag>, PresentableNoteData>(
        noteStream(),
        allNoteTags(),
        (note, allTags) {
          List<LocalNoteTag> noteTags =
              allTags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
          return PresentableNoteData(
            note: note,
            noteTags: noteTags,
          );
        },
      ).shareValue();

  ValueStream<List<LocalNoteTag>> allNoteTags() =>
      LocalStore.noteTag.allItemStream;

  Future<LocalNote> get note async {
    LocalNote note;
    try {
      note = await LocalStore.note.getItem(id: _noteIsarId);
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

        if (event.note == null && _noteIsarId == null) {
          LocalNote note = await LocalStore.note.createItem();
          _noteIsarId = note.isarId;
          emit(
            NoteEditorInitializedState(
              noteStream: noteStream,
              noteData: presentableNote,
              allNoteTags: allNoteTags,
              snackBarText: '',
              isEditable: true,
            ),
          );
        } else {
          _noteIsarId = event.note!.isarId;
          emit(
            NoteEditorInitializedState(
              noteStream: noteStream,
              noteData: presentableNote,
              allNoteTags: allNoteTags,
              snackBarText: '',
              isEditable: false,
            ),
          );
        }
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
          await LocalStore.note.deleteItem(id: note.isarId);
        }
        await close();
      },
    );

    // Change Editor view type (Preview/Edit)
    on<NoteEditorChangeViewTypeEvent>(
      (event, emit) {
        emit(NoteEditorInitializedState(
          noteData: presentableNote,
          snackBarText: '',
          isEditable: !event.wasEditable,
          noteStream: noteStream,
          allNoteTags: allNoteTags,
        ));
      },
    );

    // Update note shown by editor
    on<NoteEditorUpdateEvent>(
      (event, emit) async {
        final note = await this.note;
        if (note.content != event.newContent || note.title != event.newTitle) {
          await LocalStore.note.updateItem(
            id: note.isarId,
            title: event.newTitle,
            content: event.newContent,
            tags: note.tagIds,
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
                noteData: presentableNote,
                snackBarText: 'Cannot share empty note',
                allNoteTags: allNoteTags,
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
        await LocalStore.note.updateItem(
          id: note.isarId,
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
        final newColor = event.newColor?.value;
        if (newColor != note.color) {
          await LocalStore.note.updateItem(
            id: note.isarId,
            title: note.title,
            content: note.content,
            tags: note.tagIds,
            color: newColor,
            isSyncedWithCloud: false,
          );
        }
      },
    );

    // Update the color of the note
    on<NoteEditorUpdateTagEvent>(
      (event, emit) async {
        final note = await this.note;
        var tagIds = note.tagIds;
        final selectedTagId = event.selectedTag.isarId;
        final shouldRemoveTag = tagIds.contains(selectedTagId);
        if (shouldRemoveTag) {
          tagIds.removeWhere((tagId) => tagId == selectedTagId);
          await LocalStore.note.updateItem(
            id: note.isarId,
            tags: tagIds,
          );
        } else {
          tagIds.add(selectedTagId);
          await LocalStore.note.updateItem(
            id: note.isarId,
            tags: tagIds,
            modified: note.modified,
          );
        }
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
              noteData: presentableNote,
              snackBarText: snackBarText,
              isEditable: currentState.isEditable,
              noteStream: currentState.noteStream,
              allNoteTags: allNoteTags,
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
