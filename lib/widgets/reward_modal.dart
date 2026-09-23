import 'package:flutter/material.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

/// F4 — Reward modal. Solid dim scrim (rgba 0,0,0,0.55), no blur.
Future<T?> showRewardModal<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0x8C000000),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: _ModalContent(child: child),
    ),
  );
}

class _ModalContent extends StatelessWidget {
  final Widget child;
  const _ModalContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: TaskEraShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: child,
    );
  }
}
