import 'package:flutter/material.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/services/cloud/cloud_storage_constants.dart';

Future<Color?> showColorPickerModalBottomSheet(BuildContext context) async {
  await showModalBottomSheet<Color?>(
    isDismissible: true,
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.loc.pick_color_for_note,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                IconButton(
                  tooltip: context.loc.close,
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            GridView.count(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              crossAxisCount: 6,
              children: colorFieldValues.values.toList().map((color) {
                return InkWell(
                  splashColor: color,
                  onTap: () => Navigator.of(context).pop(color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
  return null;
}
