import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

class NotesEmptyCard extends StatelessWidget {
  const NotesEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: UnconstrainedBox(
        child: Ink(
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