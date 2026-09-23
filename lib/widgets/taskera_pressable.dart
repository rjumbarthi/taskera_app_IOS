import 'package:flutter/material.dart';

/// Wraps any widget with a scale-press animation (97% on press, 100% on release).
/// Use for buttons, icon buttons, and any tappable element that needs tactile feedback.
/// For rows that also need a 480ms long-press context menu, use [TaskEraLongPressMenu] instead.
class TaskEraPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final bool enabled;

  const TaskEraPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
    this.enabled = true,
  });

  @override
  State<TaskEraPressable> createState() => _TaskEraPressableState();
}

class _TaskEraPressableState extends State<TaskEraPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:   widget.enabled ? (_) => _setPressed(true)  : null,
      onTapUp:     widget.enabled ? (_) => _setPressed(false) : null,
      onTapCancel: widget.enabled ? ()  => _setPressed(false) : null,
      onTap:       widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleDown : 1.0,
        duration: _pressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }
}
