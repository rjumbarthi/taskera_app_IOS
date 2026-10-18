import 'package:flutter/material.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class AiNudgeCard extends StatelessWidget {
  final String message;
  final String ctaLabel;
  final VoidCallback? onCta;
  final VoidCallback? onDismiss;

  const AiNudgeCard({
    super.key,
    required this.message,
    required this.ctaLabel,
    this.onCta,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: TaskEraShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '✨ TASKERA AI',
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: TaskEraColors.acc2,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close, size: 16, color: colors.ink3),
                ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 13,
              color: colors.ink2,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: onCta,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TaskEraColors.accBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 0.5,
                  color: const Color(0x330A84FF),
                ),
              ),
              child: Text(
                ctaLabel,
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: TaskEraColors.acc,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
