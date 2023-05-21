import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitDoubleBounce(
          color: context.theme.colorScheme.primary,
          size: 60,
        ),
        const SizedBox(height: 10),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}
