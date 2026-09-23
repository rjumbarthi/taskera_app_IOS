import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';

/// Full-screen overlay shown when a task/habit is marked complete.
/// Push via [CompletedPanel.push] — do not use as a named route.
class CompletedPanel extends StatelessWidget {
  final Widget body;
  final String title;

  const CompletedPanel({
    super.key,
    required this.title,
    required this.body,
  });

  static Future<T?> push<T>(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) =>
            CompletedPanel(title: title, body: body),
        transitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (_, animation, a2, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final safeTop = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: colors.appBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12 + safeTop, 16, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.chevron_left, size: 28, color: colors.ink2),
                ),
                const SizedBox(width: 8),
                Text(
                  '✓ $title',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontVariations: const [FontVariation('wght', 600)],
                    fontSize: 23,
                    color: colors.ink,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
