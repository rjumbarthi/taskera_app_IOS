import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';

class TrendLine extends StatelessWidget {
  final List<double> values; // normalized 0.0–1.0
  final double width;
  final double height;
  final Color? color;

  const TrendLine({
    super.key,
    required this.values,
    this.width = 120,
    this.height = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TrendPainter(
          values: values,
          color: color ?? KaalColors.acc,
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _TrendPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final dx = size.width / (values.length - 1);

    Offset point(int i) => Offset(
          i * dx,
          size.height * (1 - values[i].clamp(0.0, 1.0)),
        );

    path.moveTo(point(0).dx, point(0).dy);
    for (int i = 0; i < values.length - 1; i++) {
      final p0 = point(i);
      final p1 = point(i + 1);
      final cp1 = Offset(p0.dx + dx / 3, p0.dy);
      final cp2 = Offset(p1.dx - dx / 3, p1.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.values != values || old.color != color;
}
