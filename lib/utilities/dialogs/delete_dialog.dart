import 'package:flutter/material.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog({
  required BuildContext context,
  required String content,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    icon: const Icon(
      Icons.delete_rounded,
      size: 40,
    ),
    content: content,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
