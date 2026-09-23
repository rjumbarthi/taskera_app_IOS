import 'package:flutter/material.dart' show Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/taskera_colors.dart';
import '../database.dart';
import 'calendar_provider.dart';
import 'tasks_provider.dart';

/// A single time-scheduled item (task or calendar event) on the timeline.
class ScheduledItem {
  final String title;
  final DateTime start;
  final DateTime end;
  final Color color;
  final String meta;
  final int? taskId; // non-null ⇒ movable (a task we can reschedule)
  const ScheduledItem({
    required this.title,
    required this.start,
    required this.end,
    required this.color,
    required this.meta,
    this.taskId,
  });
}

/// A detected clash between two adjacent scheduled items.
class TaskConflict {
  final ScheduledItem a; // earlier
  final ScheduledItem b; // later
  final bool overlap; // true = overlap (red), false = back-to-back (amber)
  final int minutes; // overlap minutes (overlap) or gap minutes (back-to-back)
  const TaskConflict(this.a, this.b, this.overlap, this.minutes);

  String get key => '${a.title}|${a.start.millisecondsSinceEpoch}|'
      '${b.title}|${b.start.millisecondsSinceEpoch}';
}

String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '$h:${d.minute.toString().padLeft(2, '0')} $ampm';
}

Color _quadColor(int q) {
  switch (q) {
    case 1: return TaskEraColors.q1;
    case 2: return TaskEraColors.q2;
    case 3: return TaskEraColors.q3;
    case 4: return TaskEraColors.q4;
    default: return TaskEraColors.acc2;
  }
}

/// Parse a calendar `timeSlot` ("9 AM", "2 PM", "9:30 AM") into a DateTime on [day].
DateTime? _parseSlot(String slot, DateTime day) {
  final m = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(AM|PM)', caseSensitive: false)
      .firstMatch(slot);
  if (m == null) return null;
  var h = int.parse(m.group(1)!);
  final min = m.group(2) != null ? int.parse(m.group(2)!) : 0;
  final pm = m.group(3)!.toUpperCase() == 'PM';
  if (h == 12) h = 0;
  if (pm) h += 12;
  return DateTime(day.year, day.month, day.day, h, min);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Build the unified timeline from tasks (with a real time-of-day on their due
/// date) and calendar events (with a parseable time slot).
List<ScheduledItem> buildSchedule(List<Task> tasks, List<CalendarEvent> events) {
  final now = DateTime.now();
  final out = <ScheduledItem>[];

  for (final t in tasks) {
    if (t.isDone) continue;
    final due = t.dueDate;
    if (due == null) continue;
    if (due.hour == 0 && due.minute == 0) continue; // date-only → no time block
    final dur = (t.timeAllocatedMin ?? 60).clamp(5, 1440);
    final end = due.add(Duration(minutes: dur));
    out.add(ScheduledItem(
      title: t.title,
      start: due,
      end: end,
      color: _quadColor(t.quadrant),
      meta: '${fmtTime(due)}–${fmtTime(end)} · Q${t.quadrant}',
      taskId: t.id,
    ));
  }

  for (final e in events) {
    if (e.isOverdue) continue;
    final day = e.eventDate ?? now;
    final start = _parseSlot(e.timeSlot, day);
    if (start == null) continue;
    final end = start.add(const Duration(minutes: 60));
    out.add(ScheduledItem(
      title: e.title,
      start: start,
      end: end,
      color: Color(e.colorValue),
      meta: '${fmtTime(start)}–${fmtTime(end)} · ${e.isInvite ? 'Invite' : 'Calendar'}',
    ));
  }

  return out;
}

/// Detect overlaps (intervals intersect) and back-to-backs (gap < 10 min)
/// between adjacent same-day items.
List<TaskConflict> detectConflicts(List<ScheduledItem> items) {
  final scheds = [...items]..sort((x, y) => x.start.compareTo(y.start));
  final out = <TaskConflict>[];
  for (var i = 0; i < scheds.length - 1; i++) {
    final a = scheds[i];
    final b = scheds[i + 1];
    if (!_sameDay(a.start, b.start)) continue;
    if (b.start.isBefore(a.end)) {
      out.add(TaskConflict(a, b, true, a.end.difference(b.start).inMinutes));
    } else {
      final gap = b.start.difference(a.end).inMinutes;
      if (gap >= 0 && gap < 10) out.add(TaskConflict(a, b, false, gap));
    }
  }
  return out;
}

/// All time-scheduled items (tasks + events) on the unified timeline.
final scheduledItemsProvider = Provider<List<ScheduledItem>>((ref) {
  final tasks = ref.watch(allTasksProvider).value ?? [];
  final events = ref.watch(calendarEventsProvider).value ?? [];
  return buildSchedule(tasks, events);
});

/// Live list of scheduling conflicts across all tasks + calendar events.
/// Drives both the conflicts screen and the calendar's conflict chip so the
/// count shown always matches the screen.
final conflictsProvider = Provider<List<TaskConflict>>((ref) {
  return detectConflicts(ref.watch(scheduledItemsProvider));
});
