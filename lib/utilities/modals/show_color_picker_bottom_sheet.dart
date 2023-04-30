import 'package:flutter/material.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';

// Returns:
// null if the color is reset,
// currentColor if another a color is not picked
// new color if another a color is picked
Future<Color?> showColorPickerModalBottomSheet({
  required BuildContext context,
  required Color? currentColor,
}) async {
  Color? pickedColor = currentColor;

  // Get the GridView column count
  final availableWidth = MediaQuery.of(context).size.width - 56;
  final columnCount = availableWidth ~/ 70;

  await showModalBottomSheet(
    barrierColor: Colors.black.withAlpha(170),
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Icon(
                  Icons.color_lens_rounded,
                  color: context.theme.colorScheme.onBackground,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Text(
                  context.loc.pick_color_for_note,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                IconButton(
                  tooltip: context.loc.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceTint.withAlpha(20),
                borderRadius: BorderRadius.circular(24),
              ),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                crossAxisCount: columnCount,
                children: noteColors.values.toList().map((color) {
                  final colorName = noteColors.keys
                      .toList()[noteColors.values.toList().indexOf(color)];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      pickedColor = color;
                    },
                    splashColor: color,
                    borderRadius: BorderRadius.circular(200),
                    child: Tooltip(
                      message: colorName,
                      child: Stack(
                        children: [
                          (color == currentColor)
                              ? Container(
                                  height: 66,
                                  width: 66,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignInside,
                                      color: context.theme.colorScheme.outline,
                                      width: 2.0,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 40,
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                  width: 0,
                                ),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black45.withAlpha(50),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0.0, 1.0),
                                ),
                              ],
                              color: color.withAlpha(120),
                              shape: BoxShape.circle,
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
              height: 8.0,
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    context.theme.colorScheme.primaryContainer.withAlpha(150),
                disabledBackgroundColor:
                    context.theme.colorScheme.primaryContainer.withAlpha(50),
              ),
              onPressed: (currentColor == null)
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      pickedColor = null;
                    },
              child: Row(
                children: const [
                  Spacer(
                    flex: 1,
                  ),
                  Icon(Icons.settings_backup_restore_rounded),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text('Reset color'),
                  Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  return pickedColor;
}

Map<String, Color> noteColors = {
  'Moss Green': const Color(0xFF8FBF67),
  'Forest Green': const Color(0xFF228B22),
  'Sky Blue': const Color(0xFF87CEEB),
  'Ocean Blue': const Color(0xFF0077be),
  'Sunset Orange': const Color(0xFFFFA07A),
  'Coral Pink': const Color(0xFFFF7F50),
  'Lavender Purple': const Color(0xFF967bb6),
  'Sandy Brown': const Color(0xFFf4a460),
  // 'Cosmic Latte': const Color(0xFFFDF8E7),
  'Galactic Blue': const Color(0xFF1F75FE),
  'Nebula Pink': const Color(0xFFD4578C),
  'Supernova Yellow': const Color(0xFFFFC300),
  'Aurora Green': const Color(0xFF7FFFD4),
  'Meteorite Grey': const Color(0xFF2F4F4F),
  'Barn Red': const Color(0xFF801100),
  'Engineering International Orange': const Color(0xFFB62203),
  'Sinopia': const Color(0xFFD73502),
  'Orange': const Color(0xFFFC6400),
  'Philippine Orange': const Color(0xFFFF7500),
  'Golden Poppy': const Color(0xFFFAC000),
  'Baltic Blue': const Color(0xFF32307B),
  'Liberty Blue': const Color(0xFF61609A),
  'Lilac Tiptoe': const Color(0xFFE2B5F8),
  'Ravishing Coral': const Color(0xFFFF9683),
  // 'Peaceful Leaf': const Color(0xFF95B971),
  'Mediterranean Blue': const Color(0xFF027EBC),
  'Begonia': const Color(0xFFFF747A),
  'Calamansi': const Color(0xFFFFF4A6),
  'Topaz': const Color(0xFFFFCC70),
  'NCS Green': const Color(0xFF009670),
};
