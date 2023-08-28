import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

/// Returns:
/// *  [null] if the color is reset.
/// *  [currentColor] if another color is not picked.
/// *  [newColor] if another color is picked.
Future<Color?> showColorPickerModalBottomSheet({
  required BuildContext context,
  required Color? currentColor,
  ColorScheme? colorScheme,
}) async {
  Color? pickedColor = currentColor;
  colorScheme ??= context.theme.colorScheme;

  // Get the GridView column count
  final availableWidth = min(640, MediaQuery.of(context).size.width - 56);
  final columnCount = availableWidth ~/ 70;

  await showModalBottomSheet(
    backgroundColor: Color.alphaBlend(
      colorScheme.surfaceTint.withAlpha(50),
      colorScheme.background,
    ),
    showDragHandle: false,
    elevation: 0.0,
    // barrierColor: colorScheme.background.withAlpha(200),
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // shrinkWrap: true,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                  child: Ink(
                    height: 6.0,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: colorScheme!.onSurfaceVariant.withAlpha(90),
                    ),
                  ),
                ),
                Text(
                  context.loc.pick_color_for_note,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color.alphaBlend(
                      colorScheme.surfaceTint.withAlpha(60),
                      colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
              ],
            ),
            Ink(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(70),
                  colorScheme.background,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                crossAxisCount: columnCount,
                children: kNoteColors.values.toList().map((color) {
                  final colorName = kNoteColors.keys
                      .toList()[kNoteColors.values.toList().indexOf(color)];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      pickedColor = color;
                    },
                    splashColor: color,
                    highlightColor: color,
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    child: Tooltip(
                      message: colorName,
                      child: Stack(
                        children: [
                          (color == currentColor)
                              ? Ink(
                                  height: 66,
                                  width: 66,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignOutside,
                                      color: Color.alphaBlend(
                                        colorScheme!.onBackground.withAlpha(120),
                                        color,
                                      ),
                                      width: 2.0,
                                    ),
                                    // shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 40,
                                    color: Color.alphaBlend(
                                      colorScheme.onBackground.withAlpha(150),
                                      color,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
                          Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: kElevationToShadow[1],
                              color: color.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(70),
                  colorScheme.background,
                ),
                foregroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(70),
                  colorScheme.onBackground,
                ),
                disabledBackgroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(60),
                  colorScheme.background,
                ),
                disabledForegroundColor: colorScheme.onBackground.withAlpha(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 16.0,
                ),
              ),
              onPressed: (currentColor == null)
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      pickedColor = null;
                    },
              label: const Text('Reset color'),
              icon: const Icon(Icons.settings_backup_restore_rounded),
            ),
          ],
        ),
      );
    },
  );
  return pickedColor;
}

const Map<String, Color> kNoteColors = {
  'Moss Green': Color(0xFF8FBF67),
  'Forest Green': Color(0xFF228B22),
  'Sky Blue': Color(0xFF87CEEB),
  'Ocean Blue': Color(0xFF0077be),
  'Sunset Orange': Color(0xFFFFA07A),
  'Coral Pink': Color(0xFFFF7F50),
  'Lavender Purple': Color(0xFF967bb6),
  'Sandy Brown': Color(0xFFf4a460),
  'Galactic Blue': Color(0xFF1F75FE),
  'Nebula Pink': Color(0xFFD4578C),
  'Aurora Green': Color(0xFF7FFFD4),
  'Barn Red': Color(0xFF801100),
  'Engineering International Orange': Color(0xFFB62203),
  'Sinopia': Color(0xFFD73502),
  'Philippine Orange': Color(0xFFFF7500),
  'Golden Poppy': Color(0xFFFAC000),
  'Baltic Blue': Color(0xFF32307B),
  'Liberty Blue': Color(0xFF61609A),
  'Lilac Tiptoe': Color(0xFFE2B5F8),
  'Mediterranean Blue': Color(0xFF027EBC),
  'Begonia': Color(0xFFFF747A),
  'Calamansi': Color(0xFFFFF4A6),
  'Topaz': Color(0xFFFFCC70),
  'NCS Green': Color(0xFF009670),
};
