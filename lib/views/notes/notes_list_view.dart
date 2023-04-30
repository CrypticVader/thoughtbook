import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thoughtbook/constants/preferences.dart';
import 'package:thoughtbook/constants/routes.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/crud/local_note.dart';
import 'package:thoughtbook/utilities/dialogs/error_dialog.dart';
import 'package:thoughtbook/views/notes/create_update_note_view.dart';

typedef NoteCallback = void Function(LocalNote note);

class NotesListView extends StatefulWidget {
  final String layoutPreference;
  final List<LocalNote> notes;
  final List<LocalNote> selectedNotes;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;

  const NotesListView({
    Key? key,
    required this.layoutPreference,
    required this.notes,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  int _getLayoutColumnCount(context) {
    if (widget.layoutPreference == listLayoutPref) {
      return 1;
    } else if (widget.layoutPreference == gridLayoutPref) {
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

  Future<bool> onDismissNote(LocalNote note) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    bool confirmDelete = true;

    final snackBar = SnackBar(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ),
      backgroundColor: context.theme.colorScheme.tertiary,
      duration: const Duration(seconds: 4),
      content: Row(
        children: [
          Text(
            context.loc.note_deleted,
            style: TextStyle(
              color: context.theme.colorScheme.onTertiary,
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24.0),
            onTap: () {
              confirmDelete = false;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restore_rounded,
                    color: context.theme.colorScheme.onTertiary,
                    size: 22,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    context.loc.undo,
                    style: TextStyle(
                      color: context.theme.colorScheme.onTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      dismissDirection: DismissDirection.startToEnd,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(4.0),
    );
    await ScaffoldMessenger.of(context)
        .showSnackBar(snackBar)
        .closed
        .then((value) => confirmDelete);
    return confirmDelete;
  }

  void onDeleteNote(LocalNote note) {
    widget.onDeleteNote(note);
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
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        crossAxisCount: _getLayoutColumnCount(context),
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
        itemBuilder: (BuildContext context, int index) {
          final note = widget.notes.elementAt(index);
          return NoteItem(
            note: note,
            isSelected: widget.selectedNotes.contains(note),
            onTap: (note, openContainer) => widget.onTap(note, openContainer),
            onLongPress: (note) => widget.onLongPress(note),
            onDismissNote: (note) => onDismissNote(note),
            onDeleteNote: (note) => onDeleteNote(note),
          );
        },
      );
    }
  }
}

class NoteItem extends StatefulWidget {
  const NoteItem({
    Key? key,
    required this.note,
    required this.isSelected,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.onDismissNote,
  }) : super(key: key);

  final LocalNote note;
  final bool isSelected;
  final NoteCallback onDeleteNote;
  final Future<bool> Function(LocalNote note) onDismissNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  late bool _isDarkMode;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;

  Color _getNoteColor(BuildContext context, LocalNote note) {
    if (note.color != null) {
      return Color(note.color!);
    }
    return context.theme.colorScheme.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Dismissible(
        key: ValueKey(widget.note),
        onUpdate: (details) {
          setState(() {
            _noteOpacity = 1 - details.progress;
          });
        },
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.25,
          DismissDirection.endToStart: 0.25,
        },
        confirmDismiss: (direction) async {
          final shouldDelete = await widget.onDismissNote(widget.note);
          if (!shouldDelete) {
            setState(() {
              _noteOpacity = 1.0;
            });
          }
          return shouldDelete;
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
            borderRadius: BorderRadius.circular(18),
            onLongPress: () => widget.onLongPress(widget.note),
            onTap: () => widget.onTap(widget.note, _openContainer),
            splashColor: _getNoteColor(context, widget.note).withAlpha(120),
            child: OpenContainer(
              tappable: false,
              transitionType: ContainerTransitionType.fade,
              transitionDuration: const Duration(milliseconds: 350),
              routeSettings: RouteSettings(
                arguments: {
                  'note': widget.note,
                  'shouldAutofocus': false,
                },
                name: createOrUpdateNoteRoute,
              ),
              closedElevation: 0,
              openElevation: 0,
              closedColor: _getNoteColor(context, widget.note).withAlpha(90),
              middleColor: _getNoteColor(context, widget.note).withAlpha(90),
              openColor: _getNoteColor(context, widget.note).withAlpha(90),
              useRootNavigator: true,
              closedShape: RoundedRectangleBorder(
                side: widget.isSelected
                    ? BorderSide(
                        width: 3,
                        color: context.theme.colorScheme.primary,
                      )
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              closedBuilder: (context, openContainer) {
                _openContainer = openContainer;

                return Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.note.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
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
                return const CreateUpdateNoteView();
              },
            ),
          ),
        ),
      ),
    );
  }
}
