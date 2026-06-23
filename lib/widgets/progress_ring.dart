import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 4,
    this.color,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          trackColor: colors.surf3,
          progressColor: color ?? KaalColors.acc,
        ),
        child: center != null ? Center(child: center) : null,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  const _RingPainter({
    required this.value,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi, false, trackPaint);
    if (value > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.progressColor != progressColor;
}
