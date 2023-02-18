import 'package:flutter/material.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: context.loc.sharing,
    icon: const Icon(
      Icons.short_text_rounded,
      size: 40,
    ),
    content: context.loc.cannot_share_empty_note_prompt,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
