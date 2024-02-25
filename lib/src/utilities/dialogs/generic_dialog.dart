import 'package:dartx/dartx.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/curves/material_3.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String? title,
  required Icon? icon,
  String? content,
  Widget? body,
  required DialogOptionBuilder optionsBuilder,
}) {
  if (body == null && content == null) throw Exception();
  final options = optionsBuilder();
  return showDialog(
    barrierColor: context.themeColors.scrim.withAlpha(120),
    context: context,
    builder: (context) {
      var optionIndex = -1;
      final optionsCount = options.length;
      return Entry.all(
        duration: 450.milliseconds,
        yOffset: 0,
        scale: 0.65,
        opacity: 0,
        curve: M3Easings.emphasizedDecelerate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          icon: icon,
          title: title != null
              ? Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
          content: (content != null)
              ? Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              )
              : body,
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
                        bottomRight: Radius.circular((optionIndex == optionsCount - 1) ? 24 : 4),
                        bottomLeft: Radius.circular((optionIndex == optionsCount - 1) ? 24 : 4),
                      ),
                    ),
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: (value == null || value == false)
                        ? context.theme.colorScheme.surfaceTint.withAlpha(25)
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
        ),
      );
    },
  );
}
