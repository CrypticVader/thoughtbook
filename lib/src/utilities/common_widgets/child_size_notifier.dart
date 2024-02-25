import 'package:flutter/material.dart';

class ChildSizeNotifier extends StatefulWidget {
  final Widget Function(BuildContext context, Size size, Widget child) builder;
  final Widget child;
  const ChildSizeNotifier({
    super.key,
    required this.builder,
    required this.child,
  });

  @override
  State<ChildSizeNotifier> createState() => _ChildSizeNotifierState();
}

class _ChildSizeNotifierState extends State<ChildSizeNotifier> {
  final ValueNotifier<Size> _notifier = ValueNotifier(const Size(0, 0));

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        _notifier.value = (context.findRenderObject() as RenderBox).size;
      },
    );
    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (context, value, child) => widget.builder(context, value, child!),
      child: widget.child,
    );
  }
}
