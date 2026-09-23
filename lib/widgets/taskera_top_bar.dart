import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../theme/taskera_theme.dart';
import '../theme/taskera_type.dart';

// Primary top bar. NO BackdropFilter — wallpaper shows through directly.
// Padding: left=16, top=max(12,safeArea), right=4, bottom=4.
// Row1: title (Fraunces 600 23sp) + right-side action icons.
// Row2 (optional): subtitle (Inter 400 11sp). Gap between rows = 2px.
class TaskEraTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;

  // Right-side icons. Wrap each in TopIcoButton before passing.
  final List<Widget> actions;

  // Sub-screens with a parent tab use a smaller title (15sp) and hide actions.
  final bool isSubScreen;

  // Optional left-side widget (e.g. back button). When provided, left padding
  // shrinks from 16 → 4 so the widget sits flush with the screen edge.
  final Widget? leading;

  const TaskEraTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.isSubScreen = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final topPad = max(12.0, safeTop);
    final colors = TaskEraTheme.of(context).colors;

    final titleStyle = isSubScreen
        ? TaskEraType.section.copyWith(color: colors.ink)
        : TaskEraType.topBarTitle.copyWith(color: colors.ink);

    // When a leading widget is present shift left padding to 4 so the 38px
    // hit-area sits flush with the edge (mirrors edit_profile_screen pattern).
    final leftPad = leading != null ? 4.0 : 16.0;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(leftPad, topPad, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 4)],
              Expanded(
                child: Text(title, style: titleStyle, maxLines: 1),
              ),
              if (actions.isNotEmpty && !isSubScreen)
                _ActionsRow(actions: actions),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            // Indent subtitle to align under the title when leading is present.
            Padding(
              padding: EdgeInsets.only(left: leading != null ? 42.0 : 0),
              child: Text(
                subtitle!,
                style: TaskEraType.topBarSubtitle.copyWith(color: colors.ink2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final List<Widget> actions;
  const _ActionsRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 7),
            actions[i],
          ],
          const SizedBox(width: 4), // right padding inside actions row
        ],
      ),
    );
  }
}
