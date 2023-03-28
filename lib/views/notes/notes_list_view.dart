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

  void onNoteDismissed(CloudNote note, int index) {
    setState(() {
      widget.notes.remove(note);
    });

    bool shouldDelete = true;

    final snackBar = SnackBar(
      content: Text(context.loc.note_deleted),
      dismissDirection: DismissDirection.startToEnd,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(4.0),
      action: SnackBarAction(
        label: context.loc.undo,
        onPressed: () {
          shouldDelete = false;
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((value) {
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

class NoteItem extends StatelessWidget {
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

  Color _getTileColor(BuildContext context) {
    if (isSelected) {
      return context.theme.colorScheme.primaryContainer;
    } else {
      return context.theme.colorScheme.primaryContainer.withAlpha(140);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction) => onDismissNote(note),
      key: ValueKey(note),
      child: Card(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          onTap: () => onTap(note),
          onLongPress: () => onLongPress(note),
          tileColor: _getTileColor(context),
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide(
                    width: 3,
                    color: context.theme.colorScheme.primary,
                  )
                : BorderSide.none,
            borderRadius: BorderRadius.circular(18),
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
            child: Text('Title',
                maxLines: 10,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.theme.colorScheme.onSecondaryContainer,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                )),
          ),
          subtitle: Text(
            note.text,
            maxLines: 10,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.theme.colorScheme.onSecondaryContainer,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
