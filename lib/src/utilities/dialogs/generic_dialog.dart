import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String? title,
  required Icon? icon,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      var optionIndex = -1;
      final optionsCount = options.length;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        icon: icon,
        title: title!=null?Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ):null,
        content: Text(
          content,
          // textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: options.keys.toList().map<Widget>(
          (optionTitle) {
            optionIndex++;

            final T value = options[optionTitle];
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(optionIndex == 0 ? 24 : 4),
                      topLeft: Radius.circular(optionIndex == 0 ? 24 : 4),
                      bottomRight: Radius.circular(
                          (optionIndex == optionsCount - 1) ? 24 : 4),
                      bottomLeft: Radius.circular(
                          (optionIndex == optionsCount - 1) ? 24 : 4),
                    ),
                  ),
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: (value == null || value == false)
                      ? context.theme.colorScheme.secondaryContainer
                      : context.theme.colorScheme.primary,
                  foregroundColor: (value == null || value == false)
                      ? context.theme.colorScheme.onSecondaryContainer
                      : context.theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  optionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ).toList(),
      );
    },
  );
}
