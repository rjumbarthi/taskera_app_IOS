import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import '../data/providers/database_provider.dart';

/// Bidirectional sync between the local Drift DB and Supabase.
///
/// Strategy: local-first. Every write goes to Drift immediately, then pushes
/// to Supabase in the background. On sign-in we pull from Supabase and upsert
/// into Drift; a realtime subscription then keeps the local DB in step with
/// changes made on other devices.
///
/// ID scheme: Drift's auto-increment IDs are the canonical IDs and are reused
/// as the Supabase `id bigint PRIMARY KEY`, so the same row has the same id
/// everywhere. Pull/realtime use `insertOnConflictUpdate` keyed on that id, so
/// repeated syncs are idempotent (no duplicate rows). Conflict resolution is
/// last-write-wins via upsert.
class SyncService {
  SyncService(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;
  bool get _can => _uid != null;

  static const _tables = ['tasks', 'habits', 'goals', 'notes', 'calendar_events'];

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
    // Push BEFORE pull. This is a local-first store: a pull that runs first would
    // overwrite un-pushed local edits with stale server rows (e.g. an invite the
    // user just accepted reverts to pending, a declined event reappears). Pushing
    // first makes the server reflect local intent, so the subsequent pull is a
    // no-op for those rows instead of clobbering them.
    await pushAll();
    await pullAll();
  }

  // ── Targeted write-through — keep the server in step the instant a local edit
  // happens, so a background pull (or realtime echo) can't resurrect old state.

  /// Mirror one calendar event to the server immediately (used right after a
  /// local invite *accept*, which flips is_invite → false).
  Future<void> pushCalendarEvent(CalendarEvent e) async {
    if (!_can) return;
    try {
      await _client.from('calendar_events').upsert({
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
      }, onConflict: 'id');
    } catch (_) {/* offline — the next full push reconciles it */}
  }

  /// Delete one calendar event on the server immediately (used right after a
  /// local invite *decline*, which deletes the row). Without this the next pull
  /// re-adds the declined event, since a plain push never propagates deletes.
  Future<void> deleteCalendarEventRemote(int id) async {
    if (!_can) return;
    try {
      await _client.from('calendar_events').delete().eq('id', id).eq('user_id', _uid!);
    } catch (_) {/* offline — realtime/manual cleanup reconciles it */}
  }

  // ── Realtime ────────────────────────────────────────────────────────────────

  RealtimeChannel? _channel;

  /// Subscribe to Postgres changes for the signed-in user so edits made on
  /// another device land here within ~a second. Safe to call when realtime is
  /// not enabled server-side — it simply never fires.
  void startRealtime() {
    if (!_can || _channel != null) return;
    final uid = _uid!;
    final ch = _client.channel('kaal_sync_$uid');
    for (final table in _tables) {
      ch.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, column: 'user_id', value: uid),
        callback: (payload) => _onChange(table, payload),
      );
    }
    ch.subscribe((status, [error]) {
      if (kDebugMode) {
        debugPrint('[Kaal sync] realtime $status'
            '${error != null ? ' · error=$error' : ''}');
      }
    });
    _channel = ch;
  }

  Future<void> stopRealtime() async {
    final ch = _channel;
    _channel = null;
    if (ch != null) await _client.removeChannel(ch);
  }

  Future<void> _onChange(String table, PostgresChangePayload payload) async {
    try {
      if (kDebugMode) {
        final id = payload.newRecord['id'] ?? payload.oldRecord['id'];
        debugPrint('[Kaal sync] $table ${payload.eventType.name} id=$id');
      }
      if (payload.eventType == PostgresChangeEvent.delete) {
        final id = payload.oldRecord['id'];
        if (id is! int) return;
        switch (table) {
          case 'tasks':
            await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
          case 'habits':
            await (_db.delete(_db.habits)..where((h) => h.id.equals(id))).go();
          case 'goals':
            await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
          case 'notes':
            await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
          case 'calendar_events':
            await (_db.delete(_db.calendarEvents)..where((e) => e.id.equals(id))).go();
        }
        return;
      }
      final r = payload.newRecord;
      switch (table) {
        case 'tasks':
          await _db.into(_db.tasks).insertOnConflictUpdate(_taskRow(r));
        case 'habits':
          await _db.into(_db.habits).insertOnConflictUpdate(_habitRow(r));
        case 'goals':
          await _db.into(_db.goals).insertOnConflictUpdate(_goalRow(r));
        case 'notes':
          await _db.into(_db.notes).insertOnConflictUpdate(_noteRow(r));
        case 'calendar_events':
          await _db.into(_db.calendarEvents).insertOnConflictUpdate(_calendarRow(r));
      }
    } catch (_) {/* tolerate malformed payloads */}
  }

  // ── Tasks ──────────────────────────────────────────────────────────────────

  // Optimistic: include `labels` until the server tells us the column is
  // missing, then drop it so task sync keeps working before the migration is
  // applied. Reset to true each app session, so it self-heals after the
  // `labels` column is added and the app restarts.
  bool _tasksHaveLabels = true;
  bool _habitsHaveNotes = true;
  bool _goalsHaveNotes  = true;

  Future<void> _pushTasks() async {
    final all = <Task>[];
    for (int q = 1; q <= 4; q++) {
      all.addAll(await _db.tasksDao.watchByQuadrant(q).first);
    }
    all.addAll(await _db.tasksDao.watchDone().first);
    if (all.isEmpty) return;

    Map<String, dynamic> row(Task t, {required bool withLabels}) => {
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
          if (withLabels) 'labels': t.labels,
        };

    Future<void> push(bool withLabels) => _client.from('tasks').upsert(
          all.map((t) => row(t, withLabels: withLabels)).toList(),
          onConflict: 'id',
        );

    try {
      await push(_tasksHaveLabels);
    } on PostgrestException catch (e) {
      // The `labels` column isn't there yet (migration not applied) — drop it
      // and retry so the rest of the task data still syncs.
      if (_tasksHaveLabels && _isMissingLabelsColumn(e)) {
        _tasksHaveLabels = false;
        await push(false);
      } else {
        rethrow;
      }
    }
  }

  static bool _isMissingLabelsColumn(PostgrestException e) =>
      _isMissingColumn(e, 'labels');

  // True when the error means [col] doesn't exist on the remote table yet
  // (migration not applied) — lets a push drop that field and retry.
  static bool _isMissingColumn(PostgrestException e, String col) {
    final msg = e.message.toLowerCase();
    return e.code == 'PGRST204' || e.code == '42703' || msg.contains(col);
  }

  TasksCompanion _taskRow(Map<String, dynamic> r) => TasksCompanion(
        id: Value(r['id'] as int),
        title: Value(r['title'] as String),
        quadrant: Value(r['quadrant'] as int),
        dueDate: Value(r['due_date'] != null ? DateTime.parse(r['due_date'] as String) : null),
        dueLabel: Value(r['due_label'] as String?),
        isOverdue: Value((r['is_overdue'] as bool?) ?? false),
        hasAi: Value((r['has_ai'] as bool?) ?? false),
        urgencyScore: Value((r['urgency_score'] as num?)?.toDouble()),
        recurrenceLabel: Value(r['recurrence_label'] as String?),
        hasPomodoro: Value((r['has_pomodoro'] as bool?) ?? false),
        isDone: Value((r['is_done'] as bool?) ?? false),
        doneAt: Value(r['done_at'] != null ? DateTime.parse(r['done_at'] as String) : null),
        sortOrder: Value((r['sort_order'] as int?) ?? 0),
        labels: Value(r['labels'] as String?),
      );

  Future<void> _pullTasks() async {
    final rows = await _client.from('tasks').select().eq('user_id', _uid!).order('sort_order')
        as List<dynamic>;
    for (final r in rows) {
      await _db.into(_db.tasks).insertOnConflictUpdate(_taskRow(r as Map<String, dynamic>));
    }
  }

  // ── Habits ─────────────────────────────────────────────────────────────────

  Future<void> _pushHabits() async {
    final all = await _db.habitsDao.watchAll().first;
    if (all.isEmpty) return;

    Map<String, dynamic> row(Habit h, {required bool withNotes}) => {
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
          if (withNotes) 'notes': h.notes,
        };

    Future<void> push(bool withNotes) => _client.from('habits').upsert(
          all.map((h) => row(h, withNotes: withNotes)).toList(),
          onConflict: 'id',
        );

    try {
      await push(_habitsHaveNotes);
    } on PostgrestException catch (e) {
      if (_habitsHaveNotes && _isMissingColumn(e, 'notes')) {
        _habitsHaveNotes = false;
        await push(false);
      } else {
        rethrow;
      }
    }
  }

  HabitsCompanion _habitRow(Map<String, dynamic> r) => HabitsCompanion(
        id: Value(r['id'] as int),
        emoji: Value(r['emoji'] as String),
        name: Value(r['name'] as String),
        frequencyLabel: Value(r['frequency_label'] as String),
        durationMinutes: Value(r['duration_minutes'] as int?),
        quadrant: Value((r['quadrant'] as int?) ?? 2),
        streakLabel: Value(r['streak_label'] as String),
        streakColorValue: Value(r['streak_color_value'] as int),
        accentColorValue: Value(r['accent_color_value'] as int),
        weeklyFilledCount: Value((r['weekly_filled_count'] as int?) ?? 0),
        subLabel: Value(r['sub_label'] as String?),
        notes: Value(r['notes'] as String?),
      );

  Future<void> _pullHabits() async {
    final rows = await _client.from('habits').select().eq('user_id', _uid!) as List<dynamic>;
    for (final r in rows) {
      await _db.into(_db.habits).insertOnConflictUpdate(_habitRow(r as Map<String, dynamic>));
    }
  }

  // ── Goals ──────────────────────────────────────────────────────────────────

  Future<void> _pushGoals() async {
    final all = await _db.goalsDao.watchAll().first;
    if (all.isEmpty) return;

    Map<String, dynamic> row(Goal g, {required bool withNotes}) => {
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
          if (withNotes) 'notes': g.notes,
        };

    Future<void> push(bool withNotes) => _client.from('goals').upsert(
          all.map((g) => row(g, withNotes: withNotes)).toList(),
          onConflict: 'id',
        );

    try {
      await push(_goalsHaveNotes);
    } on PostgrestException catch (e) {
      if (_goalsHaveNotes && _isMissingColumn(e, 'notes')) {
        _goalsHaveNotes = false;
        await push(false);
      } else {
        rethrow;
      }
    }
  }

  GoalsCompanion _goalRow(Map<String, dynamic> r) => GoalsCompanion(
        id: Value(r['id'] as int),
        emoji: Value(r['emoji'] as String),
        emojiBg: Value(r['emoji_bg'] as String),
        title: Value(r['title'] as String),
        subtitle: Value(r['subtitle'] as String),
        progressPct: Value((r['progress_pct'] as num?)?.toDouble() ?? 0.0),
        accentColorValue: Value(r['accent_color_value'] as int),
        barColorValue: Value(r['bar_color_value'] as int),
        borderColorValue: Value(r['border_color_value'] as int),
        linkedLabel: Value(r['linked_label'] as String),
        linkType: Value((r['link_type'] as String?) ?? 'task'),
        dotColorValue: Value(r['dot_color_value'] as int),
        notes: Value(r['notes'] as String?),
      );

  Future<void> _pullGoals() async {
    final rows = await _client.from('goals').select().eq('user_id', _uid!) as List<dynamic>;
    for (final r in rows) {
      await _db.into(_db.goals).insertOnConflictUpdate(_goalRow(r as Map<String, dynamic>));
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

  NotesCompanion _noteRow(Map<String, dynamic> r) => NotesCompanion(
        id: Value(r['id'] as int),
        title: Value(r['title'] as String),
        body: Value((r['body'] as String?) ?? ''),
        isPinned: Value((r['is_pinned'] as bool?) ?? false),
        aiLabel: Value(r['ai_label'] as String?),
        timeLabel: Value(r['time_label'] as String),
      );

  Future<void> _pullNotes() async {
    final rows = await _client
        .from('notes')
        .select()
        .eq('user_id', _uid!)
        .order('created_at', ascending: false) as List<dynamic>;
    for (final r in rows) {
      await _db.into(_db.notes).insertOnConflictUpdate(_noteRow(r as Map<String, dynamic>));
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

  CalendarEventsCompanion _calendarRow(Map<String, dynamic> r) => CalendarEventsCompanion(
        id: Value(r['id'] as int),
        title: Value(r['title'] as String),
        subtitle: Value((r['subtitle'] as String?) ?? ''),
        timeSlot: Value(r['time_slot'] as String),
        colorValue: Value(r['color_value'] as int),
        isOverdue: Value((r['is_overdue'] as bool?) ?? false),
        isInvite: Value((r['is_invite'] as bool?) ?? false),
        eventDate: Value(r['event_date'] != null ? DateTime.parse(r['event_date'] as String) : null),
      );

  Future<void> _pullCalendarEvents() async {
    final rows = await _client
        .from('calendar_events')
        .select()
        .eq('user_id', _uid!)
        .order('created_at') as List<dynamic>;
    for (final r in rows) {
      await _db.into(_db.calendarEvents).insertOnConflictUpdate(_calendarRow(r as Map<String, dynamic>));
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
