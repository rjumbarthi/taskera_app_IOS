import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../focus/focus_session_modal.dart';

// Floating "✓ task done" toast with Undo. Force-closes after ~2s so it never
// lingers if a rebuild/disposal interferes with the SnackBar's own timer.
void _showTaskDoneSnack(BuildContext context, WidgetRef ref, int taskId, String title) {
  final navBottom = MediaQuery.viewPaddingOf(context).bottom + 50 + 8;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  final controller = messenger.showSnackBar(SnackBar(
    content: Text('✓  $title',
        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
        overflow: TextOverflow.ellipsis),
    backgroundColor: const Color(0xFF1C1C1E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: EdgeInsets.fromLTRB(12, 0, 12, navBottom),
    duration: const Duration(milliseconds: 2000),
    action: SnackBarAction(
      label: 'Undo',
      textColor: TaskEraColors.acc2,
      onPressed: () => ref.read(appDatabaseProvider).tasksDao.toggleDone(taskId, false),
    ),
  ));
  Timer(const Duration(milliseconds: 2100), () {
    try { controller.close(); } catch (_) {}
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

int _quadInt(String q) => switch (q) { 'q1' => 1, 'q2' => 2, 'q3' => 3, _ => 4 };

String _quadLabel(String q) => switch (q) {
      'q1' => 'Q1 · Do Now',
      'q2' => 'Q2 · Schedule',
      'q3' => 'Q3 · Delegate',
      _ => 'Q4 · Eliminate',
    };

Color _quadColor(String q) => switch (q) {
      'q1' => TaskEraColors.q1,
      'q2' => TaskEraColors.q2,
      'q3' => TaskEraColors.q3,
      _ => TaskEraColors.q4,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class QuadScreen extends ConsumerWidget {
  final String quad; // 'q1'|'q2'|'q3'|'q4'
  const QuadScreen({super.key, required this.quad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final qi = _quadInt(quad);
    final color = _quadColor(quad);
    final label = _quadLabel(quad);

    final tasks = ref.watch(quadrantTasksProvider(qi)).valueOrNull ?? [];

    // Featured task: highest urgency score, else first
    final featured = tasks.isEmpty
        ? null
        : tasks.reduce((a, b) => (a.urgencyScore ?? 0) >= (b.urgencyScore ?? 0) ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-bar
          Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 19,
                        letterSpacing: -0.5,
                        color: color)),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                decoration: BoxDecoration(
                    color: TaskEraColors.accBg,
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('✦ TaskEra AI',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: TaskEraColors.acc2)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (featured != null) ...[
            _FeaturedCard(task: featured, color: color, colors: colors),
            const SizedBox(height: 16),
          ] else ...[
            _EmptyFeaturedCard(color: color, colors: colors),
            const SizedBox(height: 16),
          ],

          // Tasks section header
          Text(
            '${tasks.length} TASKS',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: colors.ink3),
          ),
          const SizedBox(height: 6),

          for (final task in tasks) ...[
            _QuadTaskRow(task: task, qColor: color, colors: colors),
            const SizedBox(height: 4),
          ],

          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No tasks yet',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
              ),
            ),

          const SizedBox(height: 4),
          // Add task row
          GestureDetector(
            onTap: () => context.push('/tasks/edittask?quad=$qi'),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 0.5, color: color.withAlpha(0x60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text('Add task',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured AI card ──────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Task task;
  final Color color;
  final TaskEraColors colors;
  const _FeaturedCard(
      {required this.task, required this.color, required this.colors});

  @override
  Widget build(BuildContext context) {
    final hasScore = task.urgencyScore != null;
    final score = task.urgencyScore ?? 0;
    final scoreStr = score.toStringAsFixed(1);
    final qLabel = _quadLabel(switch (task.quadrant) {
      1 => 'q1',
      2 => 'q2',
      3 => 'q3',
      _ => 'q4',
    });
    final meta = hasScore ? '$qLabel · Score $scoreStr/10' : qLabel;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(0x12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: color.withAlpha(0x40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUGGESTED FOCUS',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: TaskEraColors.acc2),
          ),
          const SizedBox(height: 6),
          Text(
            task.title,
            style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.ink,
                height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(meta,
              style:
                  TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          if (hasScore) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Priority',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                const Spacer(),
                Text(scoreStr,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 3,
                child: Row(
                  children: [
                    Expanded(
                        flex: (score * 10).round(),
                        child: Container(color: color)),
                    Expanded(
                        flex: (100 - (score * 10).round()).clamp(0, 100),
                        child: Container(color: colors.surf3)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showFocusSession(context, taskId: task.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const Text('Start This Task',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeaturedCard extends StatelessWidget {
  final Color color;
  final TaskEraColors colors;
  const _EmptyFeaturedCard({required this.color, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(0x0C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: color.withAlpha(0x33)),
      ),
      alignment: Alignment.center,
      child: Text('Add your first task to get AI recommendations',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
    );
  }
}

// ── Task row ──────────────────────────────────────────────────────────────────

class _QuadTaskRow extends ConsumerWidget {
  final Task task;
  final Color qColor;
  final TaskEraColors colors;
  const _QuadTaskRow(
      {required this.task, required this.qColor, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/tasks/taskdetail/${task.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(task.title,
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: colors.ink))),
            if (task.dueLabel != null) ...[
              const SizedBox(width: 6),
              Text(task.dueLabel!,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: task.isOverdue ? TaskEraColors.warn : colors.ink3)),
            ],
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final nowDone = !task.isDone;
                ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, nowDone);
                if (nowDone) _showTaskDoneSnack(context, ref, task.id, task.title);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.isDone ? qColor : qColor.withAlpha(0x1A),
                  shape: BoxShape.circle,
                  border: Border.all(width: 0.5, color: qColor.withAlpha(0x99)),
                ),
                child: Center(
                  child: Icon(Icons.check_rounded, size: 14,
                      color: task.isDone ? Colors.white : qColor.withAlpha(0x80)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
