import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    icon: const Icon(
      Icons.error_outline_rounded,
      size: 40,
    ),
    content: text,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
