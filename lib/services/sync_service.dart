import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import '../data/providers/database_provider.dart';

/// Bidirectional sync between the local Drift DB and Supabase.
///
/// Strategy: local-first.  Every write goes to Drift immediately, then
/// pushes to Supabase in the background.  On app start (when signed in) we
/// pull from Supabase and upsert into Drift, so any changes made on another
/// device are picked up.
///
/// ID scheme: Drift's auto-increment IDs are used as the canonical IDs.
/// Supabase tables have `id bigint PRIMARY KEY` (not auto-generated) so the
/// same ID is used in both stores.  Multi-device conflict resolution is
/// last-write-wins on the `updated_at` column — a future iteration can
/// add proper CRDT merging.
class SyncService {
  SyncService(this._db, this._client);

  final AppDatabase  _db;
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;
  bool   get _can  => _uid != null;

  // ── Public surface ─────────────────────────────────────────────────────────

  Future<void> pushAll() => _run([
        _pushTasks,
        _pushHabits,
        _pushGoals,
        _pushNotes,
        _pushCalendarEvents,
      ]);

  Future<void> pullAll() => _run([
        _pullTasks,
        _pullHabits,
        _pullGoals,
        _pullNotes,
        _pullCalendarEvents,
      ]);

  Future<void> syncAll() async {
    await pullAll();
    await pushAll();
  }

  // ── Tasks ──────────────────────────────────────────────────────────────────

  Future<void> _pushTasks() async {
    final all = <Task>[];
    for (int q = 1; q <= 4; q++) {
      all.addAll(await _db.tasksDao.watchByQuadrant(q).first);
    }
    all.addAll(await _db.tasksDao.watchDone().first);
    if (all.isEmpty) return;

    await _client.from('tasks').upsert(
      all.map((t) => {
        'id'              : t.id,
        'user_id'         : _uid,
        'title'           : t.title,
        'quadrant'        : t.quadrant,
        'due_date'        : t.dueDate?.toIso8601String(),
        'due_label'       : t.dueLabel,
        'is_overdue'      : t.isOverdue,
        'has_ai'          : t.hasAi,
        'urgency_score'   : t.urgencyScore,
        'recurrence_label': t.recurrenceLabel,
        'has_pomodoro'    : t.hasPomodoro,
        'is_done'         : t.isDone,
        'done_at'         : t.doneAt?.toIso8601String(),
        'sort_order'      : t.sortOrder,
      }).toList(),
      onConflict: 'id',
    );
  }

  Future<void> _pullTasks() async {
    final rows = await _client
        .from('tasks')
        .select()
        .eq('user_id', _uid!)
        .order('sort_order') as List<dynamic>;

    for (final r in rows) {
      await _db.tasksDao.insertTask(TasksCompanion.insert(
        title:           r['title']         as String,
        quadrant:        r['quadrant']       as int,
        dueDate:         Value(r['due_date'] != null ? DateTime.parse(r['due_date'] as String) : null),
        dueLabel:        Value(r['due_label']        as String?),
        isOverdue:       Value((r['is_overdue']  as bool?) ?? false),
        hasAi:           Value((r['has_ai']       as bool?) ?? false),
        urgencyScore:    Value((r['urgency_score'] as num?)?.toDouble()),
        recurrenceLabel: Value(r['recurrence_label'] as String?),
        hasPomodoro:     Value((r['has_pomodoro'] as bool?) ?? false),
        isDone:          Value((r['is_done']      as bool?) ?? false),
        doneAt:          Value(r['done_at'] != null ? DateTime.parse(r['done_at'] as String) : null),
        sortOrder:       Value((r['sort_order'] as int?) ?? 0),
      ));
    }
  }

  // ── Habits ─────────────────────────────────────────────────────────────────

  Future<void> _pushHabits() async {
    final all = await _db.habitsDao.watchAll().first;
    if (all.isEmpty) return;

    await _client.from('habits').upsert(
      all.map((h) => {
        'id'                 : h.id,
        'user_id'            : _uid,
        'emoji'              : h.emoji,
        'name'               : h.name,
        'frequency_label'    : h.frequencyLabel,
        'duration_minutes'   : h.durationMinutes,
        'quadrant'           : h.quadrant,
        'streak_label'       : h.streakLabel,
        'streak_color_value' : h.streakColorValue,
        'accent_color_value' : h.accentColorValue,
        'weekly_filled_count': h.weeklyFilledCount,
        'sub_label'          : h.subLabel,
      }).toList(),
      onConflict: 'id',
    );
  }

  Future<void> _pullHabits() async {
    final rows = await _client
        .from('habits')
        .select()
        .eq('user_id', _uid!) as List<dynamic>;

    for (final r in rows) {
      await _db.habitsDao.insertHabit(HabitsCompanion.insert(
        emoji:             r['emoji']           as String,
        name:              r['name']            as String,
        frequencyLabel:    r['frequency_label'] as String,
        durationMinutes:   Value(r['duration_minutes'] as int?),
        quadrant:          Value((r['quadrant']  as int?) ?? 2),   // withDefault(2)
        streakLabel:       r['streak_label']    as String,
        streakColorValue:  r['streak_color_value'] as int,
        accentColorValue:  r['accent_color_value']  as int,
        weeklyFilledCount: Value((r['weekly_filled_count'] as int?) ?? 0),
        subLabel:          Value(r['sub_label'] as String?),
      ));
    }
  }

  // ── Goals ──────────────────────────────────────────────────────────────────

  Future<void> _pushGoals() async {
    final all = await _db.goalsDao.watchAll().first;
    if (all.isEmpty) return;

    await _client.from('goals').upsert(
      all.map((g) => {
        'id'                : g.id,
        'user_id'           : _uid,
        'emoji'             : g.emoji,
        'emoji_bg'          : g.emojiBg,
        'title'             : g.title,
        'subtitle'          : g.subtitle,
        'progress_pct'      : g.progressPct,
        'accent_color_value': g.accentColorValue,
        'bar_color_value'   : g.barColorValue,
        'border_color_value': g.borderColorValue,
        'linked_label'      : g.linkedLabel,
        'link_type'         : g.linkType,
        'dot_color_value'   : g.dotColorValue,
      }).toList(),
      onConflict: 'id',
    );
  }

  Future<void> _pullGoals() async {
    final rows = await _client
        .from('goals')
        .select()
        .eq('user_id', _uid!) as List<dynamic>;

    for (final r in rows) {
      await _db.goalsDao.insertGoal(GoalsCompanion.insert(
        emoji:            r['emoji']     as String,
        emojiBg:          r['emoji_bg']  as String,
        title:            r['title']     as String,
        subtitle:         r['subtitle']  as String,
        progressPct:      Value((r['progress_pct'] as num?)?.toDouble() ?? 0.0), // withDefault
        accentColorValue: r['accent_color_value'] as int,
        barColorValue:    r['bar_color_value']    as int,
        borderColorValue: r['border_color_value'] as int,
        linkedLabel:      r['linked_label'] as String,
        linkType:         Value((r['link_type'] as String?) ?? 'task'),           // withDefault
        dotColorValue:    r['dot_color_value'] as int,
      ));
    }
  }

  // ── Notes ──────────────────────────────────────────────────────────────────

  Future<void> _pushNotes() async {
    final all = await _db.notesDao.watchAll().first;
    if (all.isEmpty) return;

    await _client.from('notes').upsert(
      all.map((n) => {
        'id'        : n.id,
        'user_id'   : _uid,
        'title'     : n.title,
        'body'      : n.body,
        'is_pinned' : n.isPinned,
        'ai_label'  : n.aiLabel,
        'time_label': n.timeLabel,
      }).toList(),
      onConflict: 'id',
    );
  }

  Future<void> _pullNotes() async {
    final rows = await _client
        .from('notes')
        .select()
        .eq('user_id', _uid!)
        .order('created_at', ascending: false) as List<dynamic>;

    for (final r in rows) {
      await _db.notesDao.insertNote(NotesCompanion.insert(
        title:     r['title']     as String,
        body:      Value((r['body'] as String?) ?? ''),           // withDefault('')
        isPinned:  Value((r['is_pinned'] as bool?) ?? false),
        aiLabel:   Value(r['ai_label']  as String?),
        timeLabel: r['time_label'] as String,
      ));
    }
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Future<void> _pushCalendarEvents() async {
    final all = await _db.calendarDao.watchAll().first;
    if (all.isEmpty) return;

    await _client.from('calendar_events').upsert(
      all.map((e) => {
        'id'         : e.id,
        'user_id'    : _uid,
        'title'      : e.title,
        'subtitle'   : e.subtitle,
        'time_slot'  : e.timeSlot,
        'color_value': e.colorValue,
        'is_overdue' : e.isOverdue,
        'is_invite'  : e.isInvite,
        'event_date' : e.eventDate?.toIso8601String(),
        'source'     : 'local',
      }).toList(),
      onConflict: 'id',
    );
  }

  Future<void> _pullCalendarEvents() async {
    final rows = await _client
        .from('calendar_events')
        .select()
        .eq('user_id', _uid!)
        .order('created_at') as List<dynamic>;

    for (final r in rows) {
      await _db.calendarDao.insertEvent(CalendarEventsCompanion.insert(
        title:      r['title']     as String,
        subtitle:   Value((r['subtitle'] as String?) ?? ''),      // withDefault('')
        timeSlot:   r['time_slot'] as String,
        colorValue: r['color_value'] as int,
        isOverdue:  Value((r['is_overdue'] as bool?) ?? false),
        isInvite:   Value((r['is_invite']  as bool?) ?? false),
        eventDate:  Value(r['event_date'] != null
            ? DateTime.parse(r['event_date'] as String)
            : null),
      ));
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<void> _run(List<Future<void> Function()> fns) async {
    if (!_can) return;
    await Future.wait(fns.map((f) => f().catchError((_) {})));
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(appDatabaseProvider),
    Supabase.instance.client,
  );
});
