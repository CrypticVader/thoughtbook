import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/utilities/dialogs/delete_dialog.dart';
import 'package:thoughtbook/views/notes/notes_list_view.dart';

Future<void> showNoteItemModalBottomSheet({
  required BuildContext context,
  required CloudNote note,
  required NoteCallback onDeleteNote,
  required NoteCallback onCopyNote,
}) async {
  showModalBottomSheet<void>(
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final shouldDelete = await showDeleteDialog(
                  context: context,
                  content: context.loc.delete_note_prompt,
                );
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              leading: const Icon(Icons.delete_rounded),
              title: Text(context.loc.delete),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Share.share(note.content);
              },
              leading: const Icon(Icons.share_rounded),
              title: Text(context.loc.share_note),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                onCopyNote(note);
              },
              leading: const Icon(Icons.copy_rounded),
              title: Text(context.loc.copy_text),
            ),
          ],
        ),
      );
    },
  );
}
