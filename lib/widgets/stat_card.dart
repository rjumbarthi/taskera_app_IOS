import 'package:flutter/material.dart';
import '../theme/kaal_shape.dart';
import '../theme/kaal_theme.dart';

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  // Optional tint — when set, applies to both number and label text.
  final Color? accentColor;
  final Color? bgColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.number,
    required this.label,
    this.accentColor,
    this.bgColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors   = KaalTheme.of(context).colors;
    final bg       = bgColor     ?? colors.surf;
    final border   = borderColor ?? colors.bdr;
    final numColor = accentColor ?? colors.ink;
    final lblColor = accentColor ?? colors.ink3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: KaalShape.statCard,
          border: Border.all(width: 0.5, color: border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontVariations: const [FontVariation('wght', 700)],
                fontSize: 15,
                color: numColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: lblColor,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
