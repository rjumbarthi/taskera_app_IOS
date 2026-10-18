import 'package:flutter/material.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

class SettingsRow extends StatelessWidget {
  final Widget? icon;
  final Color? iconBg;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    this.icon,
    this.iconBg,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: TaskEraShape.setIco,
                ),
                child: icon,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colors.ink2,
                  height: 1.3,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 13,
                  color: colors.ink3,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
