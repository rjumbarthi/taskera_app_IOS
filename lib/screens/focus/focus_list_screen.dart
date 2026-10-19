import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task, Habit, CalendarEvent;
import '../../data/providers/calendar_provider.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
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
    final colors = TaskEraTheme.of(context).colors;

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

    // Agenda window: today + tomorrow (calendar days).
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrowStart = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));
    final todayTasks = allActive.where((t) {
      final d = t.dueDate;
      return d != null && d.isBefore(tomorrowStart);
    }).toList();
    final tomorrowTasks = allActive.where((t) {
      final d = t.dueDate;
      return d != null && !d.isBefore(tomorrowStart) && d.isBefore(dayAfter);
    }).toList();

    // Habits (today's routine) + calendar invites for today and tomorrow.
    final habits = ref.watch(habitsProvider).valueOrNull ?? <Habit>[];
    final todayInvites = ref
        .watch(calendarEventsForDayProvider(today))
        .where((e) => e.isInvite)
        .toList();
    final tomorrowInvites = ref
        .watch(calendarEventsForDayProvider(tomorrowStart))
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
            ? _TodayList(
                todayTasks: todayTasks,
                tomorrowTasks: tomorrowTasks,
                habits: habits,
                todayInvites: todayInvites,
                tomorrowInvites: tomorrowInvites,
                colors: colors,
              )
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
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
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
    final colors = TaskEraTheme.of(context).colors;
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
            fontFamily: TaskEraTheme.of(context).fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _active ? colors.textOrPlain(TaskEraColors.acc2) : colors.ink3,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Shared agenda helpers ─────────────────────────────────────────────────────

const int _kUntimed = 100000; // sort key for items with no specific time

/// Format minute-of-day (0–1439) as "6:30 AM"; null/untimed → "—".
String _fmtMinutes(int? min) {
  if (min == null) return '—';
  final h = min ~/ 60;
  final m = min % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final hr = h % 12 == 0 ? 12 : h % 12;
  return '$hr:${m.toString().padLeft(2, '0')} $period';
}

/// Parse a calendar timeSlot like "9 AM", "2:30 PM" → minute-of-day, or null.
int? _parseSlot(String s) {
  final m = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(AM|PM)', caseSensitive: false).firstMatch(s);
  if (m == null) return null;
  var h = int.parse(m.group(1)!);
  final min = m.group(2) != null ? int.parse(m.group(2)!) : 0;
  final pm = m.group(3)!.toUpperCase() == 'PM';
  if (h == 12) h = 0;
  if (pm) h += 12;
  return h * 60 + min;
}

// ── Today's plan: one time-ordered list, grouped by calendar day ──────────────

class _TodayList extends StatelessWidget {
  final List<Task> todayTasks;
  final List<Task> tomorrowTasks;
  final List<Habit> habits;
  final List<CalendarEvent> todayInvites;
  final List<CalendarEvent> tomorrowInvites;
  final TaskEraColors colors;
  const _TodayList({
    required this.todayTasks,
    required this.tomorrowTasks,
    required this.habits,
    required this.todayInvites,
    required this.tomorrowInvites,
    required this.colors,
  });

  // Merge tasks + habits + invites into a single time-sorted list of rows.
  List<Widget> _dayRows(List<Task> tasks, List<Habit> habits, List<CalendarEvent> invites) {
    final entries = <(int, Widget)>[];
    for (final t in tasks) {
      final d = t.dueDate;
      final timed = d != null && !(d.hour == 0 && d.minute == 0);
      entries.add((timed ? d.hour * 60 + d.minute : _kUntimed, _TaskRow(task: t, colors: colors)));
    }
    for (final h in habits) {
      entries.add((h.scheduledTime ?? _kUntimed, _HabitRow(h)));
    }
    for (final e in invites) {
      entries.add((_parseSlot(e.timeSlot) ?? _kUntimed, _InviteRow(e)));
    }
    entries.sort((a, b) => a.$1.compareTo(b.$1));

    final rows = <Widget>[];
    for (int i = 0; i < entries.length; i++) {
      if (i > 0) rows.add(Divider(height: 1, thickness: 0.5, color: colors.bdr));
      rows.add(entries[i].$2);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final todayRows    = _dayRows(todayTasks, habits, todayInvites);
    final tomorrowRows = _dayRows(tomorrowTasks, const [], tomorrowInvites);

    if (todayRows.isEmpty && tomorrowRows.isEmpty) {
      return Center(
        child: Text(
          'Nothing planned',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        if (todayRows.isNotEmpty) ...[
          const _DayHeader('Today'),
          ...todayRows,
        ],
        if (tomorrowRows.isNotEmpty) ...[
          const _DayHeader('Tomorrow'),
          ...tomorrowRows,
        ],
      ],
    );
  }
}

// Calendar-day separator/header ("TODAY", "TOMORROW").
class _DayHeader extends StatelessWidget {
  final String label;
  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: TaskEraTheme.of(context).fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: colors.ink2,
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
    final colors = TaskEraTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          SizedBox(
            width: 54,
            child: Text(
              _fmtMinutes(habit.scheduledTime),
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          // Type indicator (emoji)
          SizedBox(width: 22, child: Center(child: Text(habit.emoji, style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontFamily: TaskEraTheme.of(context).fontFamily,
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
                    fontFamily: TaskEraTheme.of(context).fontFamily,
                    fontSize: 11,
                    color: colors.ink3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Trailing: streak
          if (habit.streakLabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              habit.streakLabel,
              style: TextStyle(
                fontFamily: TaskEraTheme.of(context).fontFamily,
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
    final colors = TaskEraTheme.of(context).colors;
    final accent = Color(event.colorValue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              event.timeSlot,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          // Type indicator (colored bar)
          SizedBox(
            width: 22,
            child: Center(
              child: Container(
                width: 3,
                height: 34,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontFamily: TaskEraTheme.of(context).fontFamily,
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
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.3),
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
                fontFamily: TaskEraTheme.of(context).fontFamily,
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
  final TaskEraColors colors;
  const _TaskList({required this.tasks, required this.filter, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
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
  final TaskEraColors colors;
  const _TaskRow({required this.task, required this.colors});

  Color get _quadColor => switch (task.quadrant) {
        1 => TaskEraColors.q1,
        2 => TaskEraColors.q2,
        3 => TaskEraColors.q3,
        _ => TaskEraColors.q4,
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
    if (d == null || (d.hour == 0 && d.minute == 0)) return '—';
    return _fmtMinutes(d.hour * 60 + d.minute);
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
              width: 54,
              child: Text(
                _timeDisplay,
                style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 11,
                  color: colors.ink3,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Type indicator (quadrant dot)
            SizedBox(
              width: 22,
              child: Center(
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(color: qc, shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily,
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
                      fontFamily: TaskEraTheme.of(context).fontFamily,
                      fontSize: 11,
                      color: task.isOverdue ? colors.textOrPlain(TaskEraColors.warn) : colors.ink3,
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
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      backgroundColor: const Color(0xFF1C1C1E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.fromLTRB(12, 0, 12, navBottom),
                      duration: const Duration(milliseconds: 2000),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: colors.textOrPlain(TaskEraColors.acc2),
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
