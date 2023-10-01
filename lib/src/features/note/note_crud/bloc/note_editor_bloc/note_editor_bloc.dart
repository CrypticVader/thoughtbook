import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartx/dartx.dart';
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
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  final Debouncer _debouncer = Debouncer(delay: 250.milliseconds);
  int? _noteIsarId;
  late NoteDataNode _currentNoteNode;

  ValueStream<LocalNote> noteStream() =>
      LocalStore.note.itemStream(id: _noteIsarId!);

  ValueStream<PresentableNoteData> presentableNote() => Rx.combineLatest2(
        noteStream(),
        allNoteTags(),
        (note, allTags) {
          List<LocalNoteTag> noteTags =
              allTags.where((tag) => note.tagIds.contains(tag.isarId)).toList();
          return PresentableNoteData(note: note, noteTags: noteTags);
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

  NoteEditorBloc() : super(const NoteEditorUninitialized()) {
    // Initialize editor state
    on<NoteEditorInitializeEvent>(
      (event, emit) async {
        if (state is NoteEditorInitialized) {
          throw NoteEditorBlocAlreadyInitializedException();
        }

        if (event.note == null && _noteIsarId == null) {
          _currentNoteNode = NoteDataNode(
            data: (
              title: '',
              content: '',
            ),
          );
          LocalNote note = await LocalStore.note.createItem();
          _noteIsarId = note.isarId;
          emit(
            NoteEditorInitialized(
              noteStream: noteStream,
              noteData: presentableNote,
              allNoteTags: allNoteTags,
              snackBarText: '',
              canUndo: !(_currentNoteNode.isFirst),
              canRedo: !(_currentNoteNode.isLast),
            ),
          );
        } else {
          _noteIsarId = event.note!.isarId;
          _currentNoteNode = NoteDataNode(
            data: (
              title: event.note!.title,
              content: event.note!.content,
            ),
          );
          emit(
            NoteEditorInitialized(
              noteStream: noteStream,
              noteData: presentableNote,
              allNoteTags: allNoteTags,
              snackBarText: '',
              canUndo: !(_currentNoteNode.isFirst),
              canRedo: !(_currentNoteNode.isLast),
            ),
          );
        }
      },
    );

    // Close note editor
    on<NoteEditorCloseEvent>(
      (event, emit) async {
        if (state is NoteEditorDeleted) {
          return;
        }

        final note = await this.note;
        if (note.title.isBlank && note.content.isBlank) {
          await LocalStore.note.deleteItem(id: note.isarId);
        }
        await close();
      },
    );

    // Update note title & content
    on<NoteEditorUpdateEvent>(
      (event, emit) async {
        if (_currentNoteNode.data.content != event.newContent ||
            _currentNoteNode.data.title != event.newTitle) {
          _currentNoteNode.removeNodesToRight();
          _currentNoteNode.next = NoteDataNode(data: (
            title: event.newTitle,
            content: event.newContent,
          ));
          _currentNoteNode = _currentNoteNode.next!;
          emit(NoteEditorInitialized(
            snackBarText: '',
            canUndo: !(_currentNoteNode.isFirst),
            canRedo: !(_currentNoteNode.isLast),
            noteStream: noteStream,
            noteData: presentableNote,
            allNoteTags: allNoteTags,
          ));
          await LocalStore.note.updateItem(
            id: _noteIsarId!,
            title: event.newTitle,
            content: event.newContent,
            isSyncedWithCloud: false,
            debounceChangeFeedEvent: true,
          );
        }
      },
    );

    // Share note
    on<NoteEditorShareEvent>(
      (event, emit) async {
        if (state is NoteEditorInitialized) {
          final note = await this.note;
          if (note.content.isEmpty && note.title.isEmpty) {
            emit(
              NoteEditorInitialized(
                noteData: presentableNote,
                snackBarText: 'Cannot share empty note',
                allNoteTags: allNoteTags,
                canUndo: !(_currentNoteNode.isFirst),
                canRedo: !(_currentNoteNode.isLast),
                noteStream: noteStream,
              ),
            );
          } else {
            await Share.share('${note.title}\n${note.content}');
          }
        }
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
            color: newColor,
            isSyncedWithCloud: false,
          );
        }
      },
    );

    // Update the tags of the note
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
            modified: note.modified,
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
        if (state is NoteEditorInitialized) {
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
          emit(NoteEditorInitialized(
            noteData: presentableNote,
            snackBarText: snackBarText,
            canUndo: !(_currentNoteNode.isFirst),
            canRedo: !(_currentNoteNode.isLast),
            noteStream: noteStream,
            allNoteTags: allNoteTags,
          ));
        }
      },
    );

    // Delete note
    on<NoteEditorDeleteEvent>(
      (event, emit) async {
        final note = await this.note;
        // The actual delete operation is delegated to the NoteBloc by the presentation layer.
        // This facilitates showing a SnackBar to undo the deletion.
        emit(NoteEditorDeleted(
          deletedNote: note,
          snackBarText: '',
        ));
      },
    );

    // Undo edit
    on<NoteEditorUndoEvent>((event, emit) async {
      if (!(_currentNoteNode.isFirst)) {
        _currentNoteNode = _currentNoteNode.previous!;
        emit(NoteEditorInitialized(
          snackBarText: '',
          textFieldValues: _currentNoteNode.data,
          canUndo: !(_currentNoteNode.isFirst),
          canRedo: !(_currentNoteNode.isLast),
          noteStream: noteStream,
          noteData: presentableNote,
          allNoteTags: allNoteTags,
        ));
        await LocalStore.note.updateItem(
          id: _noteIsarId!,
          title: _currentNoteNode.data.title,
          content: _currentNoteNode.data.content,
        );
      }
    });

    // Redo edit
    on<NoteEditorRedoEvent>((event, emit) async {
      if (!(_currentNoteNode.isLast)) {
        _currentNoteNode = _currentNoteNode.next!;
        emit(NoteEditorInitialized(
          snackBarText: '',
          textFieldValues: _currentNoteNode.data,
          canUndo: !(_currentNoteNode.isFirst),
          canRedo: !(_currentNoteNode.isLast),
          noteStream: noteStream,
          noteData: presentableNote,
          allNoteTags: allNoteTags,
        ));
        await LocalStore.note.updateItem(
          id: _noteIsarId!,
          title: _currentNoteNode.data.title,
          content: _currentNoteNode.data.content,
        );
      }
    });
  }

  @override
  void onTransition(Transition<NoteEditorEvent, NoteEditorState> transition) {
    super.onTransition(transition);
    log(transition.toString());
  }
}

class NoteEditorBlocAlreadyInitializedException implements Exception {}

class NoteDataNode {
  NoteDataNode? _previous;
  NoteDataNode? _next;
  ({String title, String content}) data;

  NoteDataNode({
    required this.data,
    NoteDataNode? next,
    NoteDataNode? previous,
  })  : _previous = previous,
        _next = next;

  NoteDataNode? get previous => _previous;

  set previous(NoteDataNode? node) {
    node?._next = this;
    _previous = node;
  }

  NoteDataNode? get next => _next;

  set next(NoteDataNode? newNode) {
    newNode?._previous = this;
    _next = newNode;
  }

  bool get isFirst => _previous == null;

  bool get isLast => _next == null;

  void removeNodesToRight() {
    _next?.removeNodesToRight();
    _next = null;
  }
}
