import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/sliver_note_group_header.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/sliver_notes_grid.dart';

class SliverNoteGroup extends StatefulWidget {
  const SliverNoteGroup({
    super.key,
    required this.groupHeader,
    required this.state,
    required this.notes,
    required this.selectedNotes,
    required this.onSelectGroup,
    required this.onUnselectGroup,
  });

  final String groupHeader;
  final NoteInitialized state;
  final List<PresentableNoteData> notes;
  final Set<LocalNote> selectedNotes;
  final void Function(Iterable<LocalNote> notes) onSelectGroup;
  final void Function(Iterable<LocalNote> notes) onUnselectGroup;

  @override
  State<SliverNoteGroup> createState() => _SliverNoteGroupState();
}

class _SliverNoteGroupState extends State<SliverNoteGroup> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (widget.groupHeader.isNotEmpty)
          SliverNoteGroupHeader(
            isSelected: (widget.selectedNotes.length == widget.notes.length),
            isCollapsed: isCollapsed,
            groupHeader: widget.groupHeader,
            onTapHeader: () => setState(() {
              isCollapsed = !isCollapsed;
            }),
            onSelectGroup: () => widget.onSelectGroup(widget.notes.map((e) => e.note)),
            onUnselectGroup: () => widget.onUnselectGroup(widget.notes.map((e) => e.note)),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(0, widget.groupHeader.isNotEmpty ? 8 : 0, 0, isCollapsed?0:12),
          sliver: SliverNotesGrid(
            layoutPreference: widget.state.layoutPreference,
            isCollapsed: isCollapsed,
            notesData:
                isCollapsed ? widget.notes.sublist(0, min(10, widget.notes.length)) : widget.notes,
            selectedNotes: widget.selectedNotes,
            onDeleteNote: (LocalNote note) =>
                context.read<NoteBloc>().add(NoteDeleteEvent(notes: {note})),
            onTap: (note, openNote) {
              if (!(widget.state.hasSelectedNotes)) {
                openNote();
              } else {
                context.read<NoteBloc>().add(NoteTapEvent(note: note));
              }
            },
            onLongPress: (note) => context.read<NoteBloc>().add(NoteLongPressEvent(note: note)),
          ),
        ),
      ],
    );
  }
}
