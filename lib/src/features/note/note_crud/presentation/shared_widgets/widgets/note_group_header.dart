import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

class NoteGroupHeader extends StatefulWidget {
  final String groupHeader;
  final bool isCollapsed;
  final bool isSelected;
  final void Function() onTapHeader;
  final void Function() onSelectGroup;
  final void Function() onUnselectGroup;

  const NoteGroupHeader({
    super.key,
    required this.groupHeader,
    required this.isCollapsed,
    required this.isSelected,
    required this.onTapHeader,
    required this.onSelectGroup,
    required this.onUnselectGroup,
  });

  @override
  State<NoteGroupHeader> createState() => _NoteGroupHeaderState();
}

class _NoteGroupHeaderState extends State<NoteGroupHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: -0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () {
          widget.onTapHeader();
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        splashColor: context.themeColors.inversePrimary.withAlpha(170),
        highlightColor: context.themeColors.inversePrimary,
        borderRadius: widget.isCollapsed
            ? BorderRadius.circular(26)
            : const BorderRadius.only(
          topRight: Radius.circular(26),
          topLeft: Radius.circular(26),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        child: AnimatedContainer(
          duration: 250.milliseconds,
          curve: Curves.ease,
          padding: const EdgeInsets.fromLTRB(16, 4, 5, 4),
          decoration: BoxDecoration(
            color: context.themeColors.primaryContainer.withAlpha(widget.isSelected ? 220 : 120),
            border: Border.all(
              color: context.themeColors.primary.withAlpha(widget.isSelected ? 100 : 35),
              width: 0.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            borderRadius: widget.isCollapsed
                ? BorderRadius.circular(26)
                : const BorderRadius.only(
              topRight: Radius.circular(26),
              topLeft: Radius.circular(26),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    RotationTransition(
                      turns: _animation,
                      child: Icon(
                        FluentIcons.chevron_down_24_filled,
                        size: 20,
                        color: context.themeColors.onSecondaryContainer.withAlpha(120),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.groupHeader,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.themeColors.onSecondaryContainer,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  if (widget.isSelected) {
                    widget.onUnselectGroup();
                  } else {
                    widget.onSelectGroup();
                  }
                },
                icon: const Icon(
                  Icons.check_rounded,
                  size: 24,
                ),
                visualDensity: VisualDensity.comfortable,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.isCollapsed
                        ? const BorderRadius.only(
                      topRight: Radius.circular(24),
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(24),
                    )
                        : const BorderRadius.only(
                      topRight: Radius.circular(22),
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  backgroundColor: widget.isSelected
                      ? context.themeColors.primary
                      : context.themeColors.primaryContainer,
                  foregroundColor: widget.isSelected
                      ? context.themeColors.onPrimary
                      : context.themeColors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
