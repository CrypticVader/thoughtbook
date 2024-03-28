import 'package:entry/entry.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/curves/material_3.dart';

class NotesEmptyCard extends StatelessWidget {
  const NotesEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Entry(
        scale: 0.85,
        opacity: 0,
        curve: M3Easings.emphasizedDecelerate,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.themeColors.secondaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(48),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FluentIcons.notebook_24_filled,
                size: 150,
                color: context.theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
              const SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 228,
                ),
                child: Text(
                  'We did not find any notes.',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.theme.colorScheme.onSecondaryContainer.withAlpha(220),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}