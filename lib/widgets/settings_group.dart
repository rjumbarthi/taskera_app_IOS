import 'package:flutter/material.dart';
import '../theme/taskera_shape.dart';
import '../theme/taskera_theme.dart';

/// B5 — Collapsible settings group with icon, title, chevron, AnimatedSize body.
class SettingsGroup extends StatefulWidget {
  final Widget icon;
  final Color iconBg;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const SettingsGroup({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<SettingsGroup> createState() => _SettingsGroupState();
}

class _SettingsGroupState extends State<SettingsGroup> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: TaskEraShape.card,
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: ClipRRect(
        borderRadius: TaskEraShape.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        borderRadius: TaskEraShape.sgrpIcon,
                      ),
                      child: widget.icon,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.chevron_right, size: 18, color: colors.ink3),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 0, thickness: 0.5, color: colors.bdr),
                        ...widget.children,
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
