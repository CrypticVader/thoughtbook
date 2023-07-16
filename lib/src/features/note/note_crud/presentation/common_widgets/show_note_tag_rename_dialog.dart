import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/note_tag_editor_modal.dart';

Future<void> showNoteTagRenameDialog({
  required BuildContext context,
  required LocalNoteTag tag,
  required NoteTagEditCallback onEditTag,
}) async {
  final nameFieldController = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        icon: const Icon(
          Icons.drive_file_rename_outline_rounded,
          size: 40,
        ),
        title: const Text(
          'Rename tag',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameFieldController,
              autofocus: true,
              maxLines: 1,
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    context.theme.colorScheme.secondaryContainer.withAlpha(200),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.colorScheme.secondaryContainer,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.theme.colorScheme.secondary.withAlpha(150),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                hintText: 'Create a new tag',
                prefixIcon: Icon(
                  Icons.new_label_rounded,
                  color: context.theme.colorScheme.onSecondaryContainer,
                ),
              ),
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(
              height: 16.0,
            ),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel_rounded),
              label: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4.0,
            ),
            FilledButton.icon(
              onPressed: () {
                onEditTag(tag, nameFieldController.text);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'Rename',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(24),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
