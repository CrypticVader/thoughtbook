import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/note_group_header.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/notes_list_view.dart';

class NoteGroup extends StatefulWidget {
  const NoteGroup({
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
  State<NoteGroup> createState() => _NoteGroupState();
}

class _NoteGroupState extends State<NoteGroup> {
  bool isCollapsed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.groupHeader.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: NoteGroupHeader(
              isSelected: (widget.selectedNotes.length == widget.notes.length),
              isCollapsed: isCollapsed,
              groupHeader: widget.groupHeader,
              onTapHeader: () => setState(() {
                isCollapsed = !isCollapsed;
              }),
              onSelectGroup: () => widget.onSelectGroup(widget.notes.map((e) => e.note)),
              onUnselectGroup: () => widget.onUnselectGroup(widget.notes.map((e) => e.note)),
            ),
          ),
        AnimatedSwitcher(
          duration: 650.milliseconds,
          switchInCurve: Curves.fastEaseInToSlowEaseOut,
          switchOutCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                axis: Axis.vertical,
                axisAlignment: -1.0,
                sizeFactor: animation,
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: !isCollapsed
              ? Padding(
            padding: EdgeInsets.fromLTRB(0, widget.groupHeader.isNotEmpty ? 8 : 0, 0, 12),
            child: NotesListView(
              layoutPreference: widget.state.layoutPreference,
              notesData: widget.notes,
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
              onLongPress: (note) =>
                  context.read<NoteBloc>().add(NoteLongPressEvent(note: note)),
            ),
          )
              : const SizedBox(height: 10),
        ),
      ],
    );
  }
}
