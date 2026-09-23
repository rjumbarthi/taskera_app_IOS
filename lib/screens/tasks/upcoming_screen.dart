import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

Color _qColor(int quad) => switch (quad) {
      1 => TaskEraColors.q1,
      2 => TaskEraColors.q2,
      3 => TaskEraColors.q3,
      _ => TaskEraColors.q4,
    };

class _DayData {
  final String day, date;
  final List<Task> tasks;
  final bool today;
  const _DayData({
    required this.day,
    required this.date,
    required this.tasks,
    required this.today,
  });
}

class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({super.key});

  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  int _selectedDay = 0;

  List<_DayData> _buildDays(List<Task> allActive) {
    const dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.add(Duration(days: i));
      final dayStart = DateTime(d.year, d.month, d.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final tasks = allActive.where((t) {
        final due = t.dueDate;
        if (due == null) return false; // undated tasks excluded — they have no specific day
        if (i == 0) {
          // Today: overdue tasks + tasks due today
          return due.isBefore(dayEnd);
        }
        return !due.isBefore(dayStart) && due.isBefore(dayEnd);
      }).toList()
        ..sort((a, b) => (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999)));
      return _DayData(
        day: dayNames[d.weekday - 1],
        date: '${d.day}',
        tasks: tasks,
        today: i == 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final all = ref.watch(allTasksProvider).valueOrNull ?? [];
    final allActive = all.where((t) => !t.isDone).toList();
    final days = _buildDays(allActive);
    final totalCount = days.fold<int>(0, (sum, d) => sum + d.tasks.length);
    final undatedCount = allActive.where((t) => t.dueDate == null).length;
    final selectedDay = _selectedDay.clamp(0, days.length - 1);
    final selectedTasks = days[selectedDay].tasks;

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
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 600)],
                        fontSize: 19,
                        letterSpacing: -0.5,
                        color: colors.ink,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Next 7 days · $totalCount scheduled${undatedCount > 0 ? ' · $undatedCount undated' : ''}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: colors.ink3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Week strip
        SizedBox(
          height: 58,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final d = days[i];
              final sel = selectedDay == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: Container(
                  width: 44,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: sel ? TaskEraColors.acc : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 0.5,
                      color: sel ? TaskEraColors.acc : colors.bdr,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        d.day,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : colors.ink3,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        d.date,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : colors.ink,
                          height: 1.2,
                        ),
                      ),
                      if (d.tasks.isNotEmpty)
                        Text(
                          '${d.tasks.length}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: sel
                                ? Colors.white.withAlpha(0xCC)
                                : TaskEraColors.acc2,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Task list for the selected day
        Expanded(
          child: selectedTasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks for this day',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.ink3,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: selectedTasks.length,
                  itemBuilder: (_, i) => _UpTaskRow(
                    task: selectedTasks[i],
                    colors: colors,
                    onTap: () => context
                        .push('/tasks/taskdetail/${selectedTasks[i].id}'),
                  ),
                ),
        ),
      ],
    );
  }
}

class _UpTaskRow extends ConsumerWidget {
  final Task task;
  final TaskEraColors colors;
  final VoidCallback? onTap;
  const _UpTaskRow({required this.task, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qc = _qColor(task.quadrant);
    final isOverdue = task.isOverdue;
    final timeLabel =
        task.dueLabel ?? (isOverdue ? 'Overdue' : 'No time set');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: qc),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: qc,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: isOverdue
                          ? const Color(0xFFFF6B6B)
                          : colors.ink3,
                    ),
                  ),
                ],
              ),
            ),
            if (task.priority != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                decoration: BoxDecoration(
                  color: const Color(0x24FF6B6B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, !task.isDone),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: task.isDone ? qc : qc.withAlpha(0x1A),
                  shape: BoxShape.circle,
                  border: Border.all(width: 0.5, color: qc.withAlpha(0x99)),
                ),
                child: Center(
                  child: Icon(Icons.check_rounded, size: 14,
                      color: task.isDone ? Colors.white : qc.withAlpha(0x80)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
