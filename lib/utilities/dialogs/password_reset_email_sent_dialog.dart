import 'package:flutter/material.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: context.loc.reset_password,
    content: context.loc.password_reset_dialog_prompt,
    icon: const Icon(
      Icons.lock_reset_rounded,
      size: 40,
    ),
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
