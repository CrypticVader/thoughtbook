import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required Icon icon,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: icon,
        title: Text(title),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: options.keys.map(
          (optionTitle) {
            final T value = options[optionTitle];
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
              ),
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withAlpha(150),
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(optionTitle),
              ),
            );
          },
        ).toList(),
      );
    },
  );
}
