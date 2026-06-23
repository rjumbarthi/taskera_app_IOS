import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task, Habit, CalendarEvent;
import '../../data/providers/calendar_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

enum FocusFilter { today, active, done, overdue }

class FocusListScreen extends ConsumerStatefulWidget {
  final FocusFilter initialFilter;
  const FocusListScreen({super.key, this.initialFilter = FocusFilter.today});

  @override
  ConsumerState<FocusListScreen> createState() => _FocusListScreenState();
}

class _FocusListScreenState extends ConsumerState<FocusListScreen> {
  late FocusFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    // Merge all active quadrant tasks
    final q1 = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [];
    final q2 = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [];
    final q3 = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [];
    final q4 = ref.watch(quadrantTasksProvider(4)).valueOrNull ?? [];
    final doneTasks = ref.watch(doneTasksProvider).valueOrNull ?? [];

    final allActive = [...q1, ...q2, ...q3, ...q4];
    allActive.sort((a, b) => (b.urgencyScore ?? 0).compareTo(a.urgencyScore ?? 0));
    doneTasks.sort((a, b) => (b.urgencyScore ?? 0).compareTo(a.urgencyScore ?? 0));

    final overdueTasks = allActive.where((t) => t.isOverdue).toList();

    // Today = tasks with a due date set that falls on today or earlier
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    final todayTasks = allActive.where((t) {
      final d = t.dueDate;
      return d != null && d.isBefore(tomorrowStart);
    }).toList();

    // Habits and calendar invites shown alongside today's tasks
    final habits = ref.watch(habitsProvider).valueOrNull ?? <Habit>[];
    final todayInvites = ref
        .watch(calendarEventsForDayProvider(today))
        .where((e) => e.isInvite)
        .toList();

    final counts = (
      today: todayTasks.length,
      active: allActive.length,
      done: doneTasks.length,
      overdue: overdueTasks.length,
    );

    final displayTasks = switch (_filter) {
      FocusFilter.today   => todayTasks,
      FocusFilter.active  => allActive,
      FocusFilter.done    => doneTasks,
      FocusFilter.overdue => overdueTasks,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubHeader(filter: _filter),
        _FilterRow(filter: _filter, counts: counts, onChanged: (f) => setState(() => _filter = f)),
        Expanded(
        child: _filter == FocusFilter.today
            ? _TodayList(tasks: displayTasks, habits: habits, invites: todayInvites, colors: colors)
            : _TaskList(tasks: displayTasks, filter: _filter, colors: colors),
      ),
      ],
    );
  }
}

// ── Sub-header ────────────────────────────────────────────────────────────────

class _SubHeader extends StatelessWidget {
  final FocusFilter filter;
  const _SubHeader({required this.filter});

  String get _title => switch (filter) {
        FocusFilter.today   => "Today's Plan",
        FocusFilter.active  => 'Active Tasks',
        FocusFilter.done    => 'Done',
        FocusFilter.overdue => 'Overdue',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
      child: Row(
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 2),
          Text(
            _title,
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontVariations: [FontVariation('wght', 600)],
              fontSize: 19,
              letterSpacing: -0.5,
              color: Color(0xFFF2F2F7),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter pills ──────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final FocusFilter filter;
  final ({int today, int active, int done, int overdue}) counts;
  final ValueChanged<FocusFilter> onChanged;
  const _FilterRow({required this.filter, required this.counts, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          _Pill(label: 'Today',   count: counts.today,   value: FocusFilter.today,   current: filter, onTap: onChanged),
          const SizedBox(width: 5),
          _Pill(label: 'Active',  count: counts.active,  value: FocusFilter.active,  current: filter, onTap: onChanged),
          const SizedBox(width: 5),
          _Pill(label: 'Done',    count: counts.done,    value: FocusFilter.done,    current: filter, onTap: onChanged),
          const SizedBox(width: 5),
          _Pill(label: 'Overdue', count: counts.overdue, value: FocusFilter.overdue, current: filter, onTap: onChanged),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final int count;
  final FocusFilter value;
  final FocusFilter current;
  final ValueChanged<FocusFilter> onTap;
  const _Pill({
    required this.label,
    required this.count,
    required this.value,
    required this.current,
    required this.onTap,
  });

  bool get _active => value == current;

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _active ? const Color(0x1F0A84FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: _active
              ? Border.all(width: 0.5, color: const Color(0x330A84FF))
              : null,
        ),
        child: Text(
          '$label · $count',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _active ? KaalColors.acc2 : colors.ink3,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Today's combined list (tasks + habits + invites) ─────────────────────────

class _TodayList extends StatelessWidget {
  final List<Task> tasks;
  final List<Habit> habits;
  final List<CalendarEvent> invites;
  final KaalColors colors;
  const _TodayList({
    required this.tasks,
    required this.habits,
    required this.invites,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty && habits.isEmpty && invites.isEmpty) {
      return Center(
        child: Text(
          'Nothing for today',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      children: [
        if (tasks.isNotEmpty) ...[
          _SectionHdr('Tasks · ${tasks.length}'),
          for (int i = 0; i < tasks.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 0.5, color: colors.bdr),
            _TaskRow(task: tasks[i], colors: colors),
          ],
        ],
        if (habits.isNotEmpty) ...[
          _SectionHdr('Habits · ${habits.length}'),
          for (int i = 0; i < habits.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 0.5, color: colors.bdr),
            _HabitRow(habits[i]),
          ],
        ],
        if (invites.isNotEmpty) ...[
          _SectionHdr('Invites · ${invites.length}'),
          for (int i = 0; i < invites.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 0.5, color: colors.bdr),
            _InviteRow(invites[i]),
          ],
        ],
      ],
    );
  }
}

class _SectionHdr extends StatelessWidget {
  final String label;
  const _SectionHdr(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: colors.ink3,
          height: 1,
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  const _HabitRow(this.habit);

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(habit.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.ink,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  habit.frequencyLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: colors.ink3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (habit.streakLabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              habit.streakLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  final CalendarEvent event;
  const _InviteRow(this.event);

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final accent = Color(event.colorValue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              event.timeSlot,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.ink,
                    height: 1.35,
                  ),
                ),
                if (event.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withAlpha(0x1A),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 0.5, color: accent.withAlpha(0x66)),
            ),
            child: Text(
              'Invite',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final FocusFilter filter;
  final KaalColors colors;
  const _TaskList({required this.tasks, required this.filter, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks',
          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      itemCount: tasks.length,
      separatorBuilder: (context, _) => Divider(
        height: 1,
        thickness: 0.5,
        color: colors.bdr,
      ),
      itemBuilder: (context, i) => _TaskRow(task: tasks[i], colors: colors),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final Task task;
  final KaalColors colors;
  const _TaskRow({required this.task, required this.colors});

  Color get _quadColor => switch (task.quadrant) {
        1 => KaalColors.q1,
        2 => KaalColors.q2,
        3 => KaalColors.q3,
        _ => KaalColors.q4,
      };

  String get _quadLabel => switch (task.quadrant) {
        1 => 'Q1',
        2 => 'Q2',
        3 => 'Q3',
        _ => 'Q4',
      };

  String get _subtitle {
    final score = task.urgencyScore;
    final parts = <String>['TASK', _quadLabel];
    if (task.isOverdue) parts.add('Overdue');
    if (task.isDone) parts.add('Done');
    if (score != null) parts.add('Score ${score.toStringAsFixed(1)}');
    if (task.dueLabel != null && !task.isDone && !task.isOverdue) parts.add(task.dueLabel!);
    return parts.join(' · ');
  }

  String get _timeDisplay {
    final d = task.dueDate;
    if (d == null) return '—';
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qc = _quadColor;
    return GestureDetector(
      onTap: () => context.push('/tasks/taskdetail/${task.id}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Time
            SizedBox(
              width: 58,
              child: Text(
                _timeDisplay,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: colors.ink3,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isDone ? colors.ink3 : colors.ink,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: colors.ink3,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: task.isOverdue ? KaalColors.warn : colors.ink3,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                final nowDone = !task.isDone;
                ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, nowDone);
                if (nowDone) {
                  final navBottom = MediaQuery.viewPaddingOf(context).bottom + 50 + 8;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        '✓  ${task.title}',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      backgroundColor: const Color(0xFF1C1C1E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.fromLTRB(12, 0, 12, navBottom),
                      duration: const Duration(milliseconds: 2000),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: KaalColors.acc2,
                        onPressed: () {
                          ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, false);
                        },
                      ),
                    ));
                }
              },
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
