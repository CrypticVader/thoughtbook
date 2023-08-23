import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

class TonalChip extends StatefulWidget {
  final Function() onTap;
  final String label;
  final IconData iconData;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Used to determine the `borderRadius` of the [TonalChip].
  final TonalChipPosition position;

  const TonalChip({
    super.key,
    required this.onTap,
    required this.label,
    required this.iconData,
    this.backgroundColor,
    this.foregroundColor,
    this.position = TonalChipPosition.disjoint,
  });

  @override
  State<TonalChip> createState() => _TonalChipState();
}

class _TonalChipState extends State<TonalChip> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = switch (widget.position) {
      TonalChipPosition.disjoint => BorderRadius.circular(14),
      TonalChipPosition.beginning => const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      TonalChipPosition.surrounded => BorderRadius.circular(4),
      TonalChipPosition.end => const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
    };
    return InkWell(
      onTap: () => widget.onTap(),
      splashColor: context.themeColors.inversePrimary.withAlpha(150),
      highlightColor: context.themeColors.inversePrimary.withAlpha(200),
      borderRadius: borderRadius,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ??
              context.themeColors.secondaryContainer.withAlpha(100),
          borderRadius: borderRadius,
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignInside,
            color: context.themeColors.onSecondaryContainer.withAlpha(40),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.iconData,
              size: 22,
              color: widget.foregroundColor ??
                  context.themeColors.onSecondaryContainer.withAlpha(225),
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.foregroundColor ??
                    context.themeColors.onSecondaryContainer.withAlpha(225),
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum TonalChipPosition { disjoint, beginning, surrounded, end }
