import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/utilities/dialogs/delete_dialog.dart';
import 'package:thoughtbook/views/notes/notes_list_view.dart';

Future<void> showNoteItemModalBottomSheet({
  required BuildContext context,
  required CloudNote note,
  required NoteCallback onDeleteNote,
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
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              leading: const Icon(Icons.delete_rounded),
              title: const Text('Delete'),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Share.share(note.text);
              },
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await Clipboard.setData(
                  ClipboardData(text: note.text),
                ).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        'Note copied to clipboard',
                      ),
                      dismissDirection: DismissDirection.startToEnd,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                });
              },
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy text'),
            ),
          ],
        ),
      );
    },
  );
}
