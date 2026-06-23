import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';

class DonutSegment {
  final double value; // raw hours / minutes / any unit
  final Color color;
  final String? label;

  const DonutSegment({required this.value, required this.color, this.label});
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final String centerText;
  final String? centerLabel;
  final double size;
  final double strokeWidth;

  const DonutChart({
    super.key,
    required this.segments,
    required this.centerText,
    this.centerLabel,
    this.size = 120,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          strokeWidth: strokeWidth,
          trackColor: colors.surf3,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontVariations: const [FontVariation('wght', 700)],
                  fontSize: 19,
                  color: colors.ink,
                  height: 1,
                ),
              ),
              if (centerLabel != null)
                Text(
                  centerLabel!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: colors.ink3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;
  final Color trackColor;

  const _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = segments.fold<double>(0, (s, e) => s + e.value);

    // Track
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (total <= 0) return;

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = 2 * pi * (seg.value / total);
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments || old.trackColor != trackColor;
}

/// Convenience factory matching the Q1/Q2/Q3 + Unplanned donut on the Focus screen.
class KaalQuadrantDonut extends StatelessWidget {
  final double q1Hours;
  final double q2Hours;
  final double q3Hours;
  final double unplannedHours;
  final String centerText;

  const KaalQuadrantDonut({
    super.key,
    required this.q1Hours,
    required this.q2Hours,
    required this.q3Hours,
    required this.unplannedHours,
    required this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    return DonutChart(
      centerText: centerText,
      centerLabel: 'hrs focus',
      segments: [
        DonutSegment(value: q1Hours, color: KaalColors.q1),
        DonutSegment(value: q2Hours, color: KaalColors.q2),
        DonutSegment(value: q3Hours, color: KaalColors.q3),
        DonutSegment(value: unplannedHours, color: const Color(0x4DFFFFFF)),
      ],
    );
  }
}
