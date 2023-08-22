import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';

@immutable
abstract class NoteState {
  final bool isLoading;
  final String loadingText;
  final AuthUser? user;

  const NoteState({
    required this.isLoading,
    required this.user,
    this.loadingText = 'Please wait a moment',
  });
}

class NoteUninitializedState extends NoteState {
  const NoteUninitializedState({
    required bool isLoading,
    required AuthUser? user,
  }) : super(
          isLoading: isLoading,
          user: user,
        );
}

class NoteInitializedState extends NoteState with EquatableMixin {
  // final ValueStream<List<LocalNote>> Function() notes;

  final ValueStream<List<PresentableNoteData>> Function() noteData;

  final ValueStream<List<LocalNoteTag>> Function() noteTags;

  final List<LocalNote> selectedNotes;

  /// Store the deleted note in case it need to be restored
  final List<LocalNote>? deletedNotes;

  /// The text to be shown for any generic SnackBar if necessary
  final String? snackBarText;

  final String layoutPreference;

  const NoteInitializedState({
    // required this.notes,
    required this.noteData,
    required this.noteTags,
    required this.selectedNotes,
    this.deletedNotes,
    this.snackBarText,
    required bool isLoading,
    required AuthUser? user,
    required this.layoutPreference,
  }) : super(
          isLoading: isLoading,
          user: user,
        );

  @override
  List<Object?> get props => [
        // notes,
        noteData,
        noteTags,
        selectedNotes,
        deletedNotes,
        snackBarText,
        layoutPreference,
        isLoading,
        user,
      ];
}
