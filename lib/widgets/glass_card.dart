import 'package:flutter/material.dart';
import '../theme/kaal_theme.dart';
import '../theme/kaal_shape.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: borderRadius ?? KaalShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: child,
    );
  }
}
