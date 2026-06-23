import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

/// F5 — Streak protect dialog.
/// tokens.json blur_usage.modal_streak_protect = blur(4px), barrierColor 0.65 alpha.
Future<T?> showStreakProtectDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: const Color(0xA6000000), // 0.65 alpha
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _DialogContent(child: child),
      ),
    ),
  );
}

class _DialogContent extends StatelessWidget {
  final Widget child;
  const _DialogContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: KaalShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: child,
    );
  }
}
