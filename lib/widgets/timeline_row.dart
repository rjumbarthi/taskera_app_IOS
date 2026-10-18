import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';

class TimelineRow extends StatelessWidget {
  final String time;
  final Widget content;
  final Color accentColor;

  const TimelineRow({
    super.key,
    required this.time,
    required this.content,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            time,
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 11,
              color: colors.ink2,
              height: 1.4,
            ),
          ),
        ),
        Container(
          width: 3,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: content),
      ],
    );
  }
}
