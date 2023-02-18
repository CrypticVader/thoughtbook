import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/utilities/dialogs/delete_dialog.dart';
import 'package:thoughtbook/utilities/modals/show_note_item_modal_bottom_sheet.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.notes.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 100,
            color: theme.colorScheme.onBackground,
          ),
          const Center(
            child: Text(
              'Create a new note to see it here',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      );
    } else {
      return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: widget.notes.length,
        itemBuilder: (context, index) {
          final note = widget.notes.elementAt(index);
          return Slidable(
            key: ValueKey(index),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                const SizedBox(
                  width: 8,
                ),
                SlidableAction(
                  flex: 1,
                  onPressed: (context) async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      widget.onDeleteNote(note);
                    }
                  },
                  borderRadius: BorderRadius.circular(64),
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListTile(
                onTap: () {
                  widget.onTap(note);
                },
                tileColor:
                    theme.colorScheme.secondaryContainer.withOpacity(0.55),
                contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.4,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'More options',
                  onPressed: () async {
                    showNoteItemModalBottomSheet(
                      context: context,
                      note: note,
                      onDeleteNote: widget.onDeleteNote,
                    );
                  },
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            height: 8,
          );
        },
      );
    }
  }
}
