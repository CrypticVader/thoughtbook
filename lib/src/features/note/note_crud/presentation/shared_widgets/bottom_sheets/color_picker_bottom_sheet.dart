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
      colorScheme.surface,
    ),
    showDragHandle: false,
    elevation: 0.0,
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
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
                      colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
              ],
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      colorScheme.surfaceTint.withAlpha(70),
                      colorScheme.surface,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    crossAxisCount: columnCount,
                    children: kNoteColors.values.toList().map((color) {
                      final colorName =
                          kNoteColors.keys.toList()[kNoteColors.values.toList().indexOf(color)];
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
                                            colorScheme!.onSurface.withAlpha(120),
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
                                          colorScheme.onSurface.withAlpha(150),
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
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(70),
                  colorScheme.surface,
                ),
                foregroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(70),
                  colorScheme.onSurface,
                ),
                disabledBackgroundColor: Color.alphaBlend(
                  colorScheme.surfaceTint.withAlpha(60),
                  colorScheme.surface,
                ),
                disabledForegroundColor: colorScheme.onSurface.withAlpha(40),
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

const kNoteColors = {
  // Og
  'Forest Green': Color(0xff228b22),
  'Moss Green': Color(0xff8fbf67),
  'NCS Green': Color(0xff009670),
  'Aurora Green': Color(0xff7fffd4),
  'Sky Blue': Color(0xff87ceeb),
  'Mediterranean Blue': Color(0xff027ebc),
  'Ocean Blue': Color(0xff0077be),
  'Galactic Blue': Color(0xff1f75fe),
  'Baltic Blue': Color(0xff32307b),
  'Lavender Purple': Color(0xff967bb6),
  'Lilac Tiptoe': Color(0xffe2b5f8),
  'nebula': Color(0xFFCC00FF),
  'byzantium': Color(0xFF702963),
  'Nebula Pink': Color(0xffd4578c),
  'Ruby Red': Color(0xffe0115f),
  'Begonia': Color(0xffff747a),
  'Sinopia': Color(0xffd73502),
  'dragon': Color(0xFFCC0000),
  'Philippine Orange': Color(0xffff7500),
  'Sunset Orange': Color(0xffffa07a),
  'Golden Poppy': Color(0xfffac000),
  'Topaz': Color(0xffffcc70),
  'wood': Color(0xFF774422),
};
