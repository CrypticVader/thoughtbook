import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/sort_props.dart';
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

class NoteUninitialized extends NoteState {
  const NoteUninitialized({
    required bool isLoading,
    required AuthUser? user,
  }) : super(
          isLoading: isLoading,
          user: user,
        );
}

class NoteInitialized extends NoteState with EquatableMixin {
  final ValueStream<Map<String, List<PresentableNoteData>>> Function() notesData;

  final ValueStream<List<LocalNoteTag>> Function() noteTags;

  final bool hasSelectedNotes;

  final ValueStream<Set<LocalNote>> Function() selectedNotes;

  final FilterProps filterProps;

  final SortProps sortProps;

  final GroupProps groupProps;

  /// Store the deleted note in case it need to be restored
  final Set<LocalNote>? deletedNotes;

  /// The text to be shown for any generic SnackBar if necessary
  final String? snackBarText;

  final String layoutPreference;

  const NoteInitialized({
    required this.notesData,
    required this.noteTags,
    required this.filterProps,
    required this.sortProps,
    required this.groupProps,
    required this.hasSelectedNotes,
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
        notesData,
        noteTags,
        selectedNotes,
        deletedNotes,
        snackBarText,
        layoutPreference,
        isLoading,
        user,
      ];
}
