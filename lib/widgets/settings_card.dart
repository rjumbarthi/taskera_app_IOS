import 'package:flutter/material.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

/// B4 — Wraps a list of SettingsRows in a glass card with hairline dividers between rows.
class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: KaalShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: ClipRRect(
        borderRadius: KaalShape.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(height: 0, thickness: 0.5, color: colors.bdr),
            ],
          ],
        ),
      ),
    );
  }
}
