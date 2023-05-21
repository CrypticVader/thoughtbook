import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';

typedef NoteCallback = void Function(LocalNote note);

class NotesListView extends StatefulWidget {
  final String layoutPreference;
  final List<LocalNote> notes;
  final List<LocalNote> selectedNotes;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final NoteCallback onEditorNoteDelete;

  const NotesListView({
    Key? key,
    required this.layoutPreference,
    required this.notes,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.onEditorNoteDelete,
  }) : super(key: key);

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  int _getLayoutColumnCount(context) {
    if (widget.layoutPreference == LayoutPreference.list.value) {
      return 1;
    } else if (widget.layoutPreference == LayoutPreference.grid.value) {
      final width = MediaQuery.of(context).size.width;
      if (width < 150) {
        return 1;
      }
      int count = (width / 280).round();
      if (count < 2) {
        return 2;
      } else {
        return count;
      }
    } else {
      showErrorDialog(
        context,
        context.loc.notes_list_view_invalid_layout_error,
      );
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 140,
            color: context.theme.colorScheme.primary,
          ),
          Center(
            child: Text(
              context.loc.notes_view_create_note_to_see_here,
              style: TextStyle(
                fontSize: 15,
                color: context.theme.colorScheme.onBackground,
              ),
            ),
          ),
        ],
      );
    } else {
      return MasonryGridView.count(
        primary: true,
        itemCount: widget.notes.length,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        crossAxisCount: _getLayoutColumnCount(context),
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
        itemBuilder: (BuildContext context, int index) {
          final note = widget.notes.elementAt(index);
          return NoteItem(
            note: note,
            isSelected: widget.selectedNotes.contains(note),
            onTap: (note, openContainer) => widget.onTap(note, openContainer),
            onLongPress: (note) => widget.onLongPress(note),
            onDeleteNote: (note) {
              setState(() {
                widget.notes.remove(note);
              });
              widget.onDeleteNote(note);
            },
            enableDismissible: widget.selectedNotes.isEmpty,
            onEditorNoteDeleted: (note) => widget.onEditorNoteDelete(note),
          );
        },
      );
    }
  }
}

class NoteItem extends StatefulWidget {
  final LocalNote note;
  final bool isSelected;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final bool enableDismissible;
  final NoteCallback onEditorNoteDeleted;

  const NoteItem({
    Key? key,
    required this.note,
    required this.isSelected,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.enableDismissible,
    required this.onEditorNoteDeleted,
  }) : super(key: key);

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;

  Color _getNoteColor(BuildContext context, LocalNote note) {
    if (note.color != null) {
      return Color(note.color!);
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<LocalNote>(widget.note),
      onUpdate: (details) async {
        if (details.progress > 0.34 && details.progress < 0.36) {
          HapticFeedback.lightImpact();
        }
        setState(() {
          _noteOpacity = 1 - details.progress;
        });
      },
      direction: widget.enableDismissible
          ? DismissDirection.horizontal
          : DismissDirection.none,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.35,
        DismissDirection.endToStart: 0.35,
      },
      onDismissed: (direction) {
        widget.onDeleteNote(widget.note);
        setState(() {
          _noteOpacity = 1.0;
        });
      },
      child: Opacity(
        opacity: _noteOpacity,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onLongPress: () => widget.onLongPress(widget.note),
          onTap: () => widget.onTap(widget.note, _openContainer),
          splashColor: _getNoteColor(context, widget.note).withAlpha(120),
          child: OpenContainer(
            tappable: false,
            transitionDuration: const Duration(milliseconds: 250),
            closedElevation: 0,
            openElevation: 0,
            closedColor: _getNoteColor(context, widget.note).withAlpha(80),
            middleColor: _getNoteColor(context, widget.note).withAlpha(80),
            openColor: _getNoteColor(context, widget.note).withAlpha(255),
            useRootNavigator: true,
            closedShape: RoundedRectangleBorder(
              side: widget.isSelected
                  ? BorderSide(
                      width: 3,
                      color: context.theme.colorScheme.primary,
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            closedBuilder: (context, openContainer) {
              _openContainer = openContainer;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.note.title.isNotEmpty)
                      Padding(
                        padding: widget.note.content.isNotEmpty
                            ? const EdgeInsets.fromLTRB(0, 0, 0, 8.0)
                            : EdgeInsets.zero,
                        child: Text(
                          widget.note.title,
                          maxLines: 10,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.white.withAlpha(220)
                                : Colors.black.withAlpha(220),
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (widget.note.content.isNotEmpty)
                      Text(
                        widget.note.content,
                        maxLines: 10,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _isDarkMode
                              ? Colors.white.withAlpha(220)
                              : Colors.black.withAlpha(220),
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              );
            },
            openBuilder: (context, closeContainer) {
              return BlocProvider<NoteEditorBloc>(
                create: (context) => NoteEditorBloc(),
                child: NoteEditorView(
                  note: widget.note,
                  shouldAutoFocusContent: false,
                  onNoteDelete: (note) => widget.onEditorNoteDeleted(note),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
