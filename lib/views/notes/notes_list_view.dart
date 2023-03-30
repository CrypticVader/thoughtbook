import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thoughtbook/constants/preferences.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/utilities/dialogs/error_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatefulWidget {
  final String layoutPreference;
  final List<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onCopyNote;
  final NoteCallback onTap;
  final NoteCallback onLongPress;
  final List<CloudNote> selectedNotes;

  const NotesListView({
    Key? key,
    required this.layoutPreference,
    required this.notes,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onCopyNote,
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

  Future<void> onNoteDismissed(CloudNote note, int index) async {
    setState(() {
      widget.notes.remove(note);
    });

    bool shouldDelete = true;

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
              shouldDelete = false;
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
        .then((value) {
      if (shouldDelete) {
        widget.onDeleteNote(note);
      } else {
        setState(() {
          widget.notes.insert(index, note);
        });
      }
    });
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
            onDeleteNote: (note) => widget.onDeleteNote(note),
            onCopyNote: (note) => widget.onCopyNote(note),
            onTap: (note) => widget.onTap(note),
            onLongPress: (note) => widget.onLongPress(note),
            onDismissNote: (note) => onNoteDismissed(note, index),
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
    required this.onDismissNote,
    required this.onCopyNote,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  final CloudNote note;
  final bool isSelected;
  final NoteCallback onDeleteNote;
  final NoteCallback onDismissNote;
  final NoteCallback onCopyNote;
  final NoteCallback onTap;
  final NoteCallback onLongPress;

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.25,
        DismissDirection.endToStart: 0.25,
      },
      onDismissed: (direction) => widget.onDismissNote(widget.note),
      key: ValueKey(widget.note),
      child: Card(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          isThreeLine: true,
          dense: true,
          visualDensity: VisualDensity.compact,
          minVerticalPadding: 0.0,
          onTap: () => widget.onTap(widget.note),
          onLongPress: () => widget.onLongPress(widget.note),
          tileColor: context.theme.colorScheme.surfaceVariant.withAlpha(120),
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            side: widget.isSelected
                ? BorderSide(
                    width: 3,
                    color: context.theme.colorScheme.primary,
                  )
                : BorderSide.none,
            borderRadius: BorderRadius.circular(18),
          ),
          title: widget.note.title.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                  child: Text(
                    widget.note.title,
                    maxLines: 10,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
          subtitle: Text(
            widget.note.content,
            maxLines: 10,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
