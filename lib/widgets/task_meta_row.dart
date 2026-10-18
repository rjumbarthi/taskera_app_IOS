import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/tasks_provider.dart';
import '../l10n/app_l10n.dart';
import '../routing/routes.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_theme.dart';

/// Today / Active / Done / Overdue stat row — shared by Focus and Tasks screens.
class TaskMetaRow extends ConsumerWidget {
  const TaskMetaRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final l = AppL10n.of(context);

    final q1   = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [];
    final q2   = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [];
    final q3   = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [];
    final q4   = ref.watch(quadrantTasksProvider(4)).valueOrNull ?? [];
    final done = ref.watch(doneTasksProvider).valueOrNull ?? [];

    final allActive    = [...q1, ...q2, ...q3, ...q4];
    final overdueCount = allActive.where((t) => t.isOverdue).length;
    final now           = DateTime.now();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    final todayCount   = allActive.where((t) {
      final d = t.dueDate;
      return d != null && d.isBefore(tomorrowStart);
    }).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.tasks.toUpperCase(),
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
                color: colors.ink3, height: 1),
          ),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _Col(
                  label: l.today,   value: '$todayCount',
                  color: const Color(0xFFFF9F0A), colors: colors,
                  onTap: () => context.go('${TaskEraRoutes.focusList}?f=today'),
                )),
                VerticalDivider(width: 1, thickness: 0.5, color: colors.bdr),
                Expanded(child: _Col(
                  label: l.active,  value: '${allActive.length}',
                  color: TaskEraColors.acc2, colors: colors,
                  onTap: () => context.go('${TaskEraRoutes.focusList}?f=active'),
                )),
                VerticalDivider(width: 1, thickness: 0.5, color: colors.bdr),
                Expanded(child: _Col(
                  label: l.done,    value: '${done.length}',
                  color: TaskEraColors.success, colors: colors,
                  onTap: () => context.go('${TaskEraRoutes.focusList}?f=done'),
                )),
                VerticalDivider(width: 1, thickness: 0.5, color: colors.bdr),
                Expanded(child: _Col(
                  label: l.overdue, value: '$overdueCount',
                  color: TaskEraColors.warn, colors: colors,
                  onTap: () => context.go('${TaskEraRoutes.focusList}?f=overdue'),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Col extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final TaskEraColors colors;
  final VoidCallback? onTap;
  const _Col({required this.label, required this.value,
      required this.color, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                fontVariations: const [FontVariation('wght', 700)],
                fontSize: 15, color: color, height: 1)),
          const SizedBox(height: 2),
          Text(label,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                color: colors.ink3, height: 1.2)),
        ],
      ),
    );
  }
}

