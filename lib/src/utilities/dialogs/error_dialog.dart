import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
  bool showTitle = true,
}) {
  return showGenericDialog<void>(
    context: context,
    title: showTitle?context.loc.generic_error_prompt:null,
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
