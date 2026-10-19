import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/tasks_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  static const _cols = [
    (quad: 1, label: 'Q1 · Do Now',    color: TaskEraColors.q1),
    (quad: 2, label: 'Q2 · Schedule',  color: TaskEraColors.q2),
    (quad: 3, label: 'Q3 · Delegate',  color: TaskEraColors.q3),
    (quad: 4, label: 'Q4 · Eliminate', color: TaskEraColors.q4),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final tasksByQuad = [
      ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [],
      ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [],
      ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [],
      ref.watch(quadrantTasksProvider(4)).valueOrNull ?? [],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n.of(context).board, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text(AppL10n.of(context).kanbanView, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Kanban columns (horizontally scrollable)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _cols.length; i++)
                  _BoardColumn(
                    label: _cols[i].label,
                    color: _cols[i].color,
                    tasks: tasksByQuad[i],
                    colors: colors,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Board column ──────────────────────────────────────────────────────────────

class _BoardColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<Task> tasks;
  final TaskEraColors colors;
  const _BoardColumn({required this.label, required this.color, required this.tasks, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: color.withAlpha(0x1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(width: 0.5, color: color.withAlpha(0x33)),
            ),
            child: Row(
              children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: colors.textOrPlain(color)), overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: color.withAlpha(0x33), borderRadius: BorderRadius.circular(4)),
                  child: Text('${tasks.length}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: colors.textOrPlain(color))),
                ),
              ],
            ),
          ),

          // Task cards
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                left: BorderSide(width: 0.5, color: colors.bdr),
                right: BorderSide(width: 0.5, color: colors.bdr),
              ),
            ),
            child: tasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                    child: Text(AppL10n.of(context).noTasks, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3), textAlign: TextAlign.center),
                  )
                : Column(
                    children: tasks.map((task) => _BoardTaskCard(task: task, quadColor: color, colors: colors)).toList(),
                  ),
          ),

          // + Add button
          GestureDetector(
            onTap: () => context.push('/tasks/quickadd'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                border: Border.all(width: 0.5, color: colors.bdr),
              ),
              alignment: Alignment.center,
              child: Text('+ Add', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Board task card ───────────────────────────────────────────────────────────

class _BoardTaskCard extends StatelessWidget {
  final Task task;
  final Color quadColor;
  final TaskEraColors colors;
  const _BoardTaskCard({required this.task, required this.quadColor, required this.colors});

  String get _meta {
    final parts = <String>[];
    if (task.isOverdue) {
      parts.add('Overdue');
    } else if (task.dueLabel != null) {
      parts.add(task.dueLabel!);
    }
    if (task.priority != null) parts.add(task.priority!);
    return parts.isEmpty ? 'No date' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tasks/taskdetail/${task.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            left: BorderSide(width: 0.5, color: colors.bdr),
            right: BorderSide(width: 0.5, color: colors.bdr),
            bottom: BorderSide(width: 0.5, color: colors.bdr),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: colors.textOrPlain(quadColor), height: 1.3)),
            const SizedBox(height: 3),
            Text(_meta, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3)),
          ],
        ),
      ),
    );
  }
}
