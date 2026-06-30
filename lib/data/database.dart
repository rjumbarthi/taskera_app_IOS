import 'package:drift/drift.dart';

import 'db_connection.dart';
import 'tables/tasks_table.dart';
import 'tables/habits_table.dart';
import 'tables/goals_table.dart';
import 'tables/notes_table.dart';
import 'tables/calendar_table.dart';
import 'tables/lists_table.dart';
import 'tables/focus_sessions_table.dart';

export 'tables/tasks_table.dart';
export 'tables/habits_table.dart';
export 'tables/goals_table.dart';
export 'tables/notes_table.dart';
export 'tables/calendar_table.dart';
export 'tables/lists_table.dart';
export 'tables/focus_sessions_table.dart';

part 'database.g.dart';

// ── DAOs ──────────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [Tasks, Subtasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<Task>> watchByQuadrant(int quadrant) => (select(tasks)
        ..where((t) => t.quadrant.equals(quadrant) & t.isDone.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch();

  Stream<List<Task>> watchInbox() => (select(tasks)
        ..where((t) => t.quadrant.equals(0) & t.isDone.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();

  Stream<List<Task>> watchDone() => (select(tasks)
        ..where((t) => t.isDone.equals(true))
        ..orderBy([
          (t) => OrderingTerm(
              expression: t.doneAt, mode: OrderingMode.desc)
        ]))
      .watch();

  Stream<List<Task>> watchAll() =>
      (select(tasks)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Stream<List<Subtask>> watchSubtasks(int taskId) => (select(subtasks)
        ..where((s) => s.taskId.equals(taskId))
        ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
      .watch();

  Future<int> insertTask(TasksCompanion entry) => into(tasks).insert(entry);

  Future<int> insertSubtask(SubtasksCompanion entry) =>
      into(subtasks).insert(entry);

  Future<void> toggleDone(int id, bool done) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(TasksCompanion(
      isDone: Value(done),
      doneAt: Value(done ? DateTime.now() : null),
    ));
    await db.recomputeGoalForTask(id);
  }

  Future<void> toggleSubtaskDone(int id, bool done) =>
      (update(subtasks)..where((s) => s.id.equals(id)))
          .write(SubtasksCompanion(isDone: Value(done)));

  Stream<Task?> watchTask(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<Task?> getTask(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateTask(int id, TasksCompanion companion) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(companion);

  Future<void> deleteTask(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  // Accumulate focus time onto a task (called when a focus session is logged).
  Future<void> addFocusSeconds(int taskId, int seconds) async {
    final t = await getTask(taskId);
    if (t == null) return;
    await (update(tasks)..where((x) => x.id.equals(taskId))).write(
      TasksCompanion(totalFocusSeconds: Value(t.totalFocusSeconds + seconds)),
    );
  }
}

@DriftAccessor(tables: [FocusSessions])
class FocusDao extends DatabaseAccessor<AppDatabase> with _$FocusDaoMixin {
  FocusDao(super.db);

  Future<int> insertSession(FocusSessionsCompanion entry) =>
      into(focusSessions).insert(entry);

  // Sessions started within [from, to) — newest first.
  Stream<List<FocusSession>> watchSessionsInRange(DateTime from, DateTime to) =>
      (select(focusSessions)
            ..where((s) =>
                s.startedAt.isBiggerOrEqualValue(from) &
                s.startedAt.isSmallerThanValue(to))
            ..orderBy([(s) => OrderingTerm(expression: s.startedAt, mode: OrderingMode.desc)]))
          .watch();
}

@DriftAccessor(tables: [Habits, SubHabits, HabitLogs])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  Stream<List<Habit>> watchAll() =>
      (select(habits)..orderBy([(h) => OrderingTerm(expression: h.id)]))
          .watch();

  Stream<List<SubHabit>> watchSubHabits(int habitId) => (select(subHabits)
        ..where((s) => s.habitId.equals(habitId))
        ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
      .watch();

  Future<int> insertHabit(HabitsCompanion entry) => into(habits).insert(entry);

  Future<int> insertSubHabit(SubHabitsCompanion entry) =>
      into(subHabits).insert(entry);

  Future<void> toggleSubHabitDone(int id, bool done) =>
      (update(subHabits)..where((s) => s.id.equals(id)))
          .write(SubHabitsCompanion(isDone: Value(done)));

  // One-shot read of a habit's sub-habits (ordered) — used by the edit screen.
  Future<List<SubHabit>> getSubHabits(int habitId) => (select(subHabits)
        ..where((s) => s.habitId.equals(habitId))
        ..orderBy([(s) => OrderingTerm(expression: s.sortOrder)]))
      .get();

  Future<void> deleteSubHabit(int id) =>
      (delete(subHabits)..where((s) => s.id.equals(id))).go();

  Future<void> deleteSubHabitsForHabit(int habitId) =>
      (delete(subHabits)..where((s) => s.habitId.equals(habitId))).go();

  Stream<Habit?> watchHabit(int id) =>
      (select(habits)..where((h) => h.id.equals(id))).watchSingleOrNull();

  Future<Habit?> getHabit(int id) =>
      (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<void> updateHabit(int id, HabitsCompanion companion) =>
      (update(habits)..where((h) => h.id.equals(id))).write(companion);

  Future<int> _computeStreak(int habitId) async {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // All logs (done AND skipped). Skipped days protect the streak: they bridge
    // a gap without breaking it and without counting toward the number.
    final logs  = await (select(habitLogs)
          ..where((l) => l.habitId.equals(habitId)))
        .get();
    if (logs.isEmpty) return 0;

    // Map each logged day → isDone (true) / isSkipped (false). Prefer 'done' if a
    // day somehow has both.
    final byDay = <DateTime, bool>{};
    for (final l in logs) {
      final d = DateTime(l.logDate.year, l.logDate.month, l.logDate.day);
      byDay[d] = (byDay[d] ?? false) || !l.isSkipped;
    }

    // A streak stays alive until the current day ends, so start at today if it's
    // logged, otherwise at yesterday (grace). If neither is logged → broken.
    // Walking back: a done day increments, a skipped day bridges, a day with no
    // log (a real miss) ends the streak. This is why un-checking today restores
    // the prior-day streak instead of wiping it, and why a skip never breaks it.
    var cursor = today;
    if (!byDay.containsKey(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
      if (!byDay.containsKey(cursor)) return 0;
    }

    int streak = 0;
    while (byDay.containsKey(cursor)) {
      if (byDay[cursor]!) streak++; // done → count; skip → bridge (no increment)
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> _saveStreak(int id) async {
    final n     = await _computeStreak(id);
    final label = n > 0 ? '🔥 ${n}d' : '';
    await (update(habits)..where((h) => h.id.equals(id)))
        .write(HabitsCompanion(streakLabel: Value(label)));
  }

  Future<void> toggleCheckedToday(int id, bool check, int newCount) async {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    await transaction(() async {
      await (update(habits)..where((h) => h.id.equals(id))).write(HabitsCompanion(
        weeklyFilledCount: Value(newCount),
        lastCheckedDate: Value(check ? now : null),
      ));
      if (check) {
        // Upsert on (habit_id, log_date); if a skip log exists for today, flip
        // it back to a completion (is_skipped = false).
        await into(habitLogs).insert(
          HabitLogsCompanion(habitId: Value(id), logDate: Value(dateOnly)),
          onConflict: DoUpdate(
            (_) => const HabitLogsCompanion(isSkipped: Value(false)),
            target: [habitLogs.habitId, habitLogs.logDate],
          ),
        );
      } else {
        await (delete(habitLogs)
              ..where((l) => l.habitId.equals(id) & l.logDate.equals(dateOnly)))
            .go();
      }
    });
    await _saveStreak(id);
  }

  // All non-skipped log entries across ALL habits for a given date range [start, end).
  Stream<List<HabitLog>> watchWeekLogs(DateTime start, DateTime end) {
    return (select(habitLogs)
          ..where((l) =>
              l.logDate.isBiggerOrEqualValue(start) &
              l.logDate.isSmallerThanValue(end) &
              l.isSkipped.equals(false)))
        .watch();
  }

  // All log entries for a given habit in the given calendar month.
  Stream<List<HabitLog>> watchMonthLogs(int habitId, int year, int month) {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 1);
    return (select(habitLogs)
          ..where((l) =>
              l.habitId.equals(habitId) &
              l.logDate.isBiggerOrEqualValue(start) &
              l.logDate.isSmallerThanValue(end)))
        .watch();
  }

  Future<void> skipToday(int habitId) async {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    // Upsert on the (habit_id, log_date) unique key — NOT the primary key — so an
    // existing log for today (e.g. a check) is flipped to skipped instead of
    // hitting a UNIQUE constraint failure.
    await into(habitLogs).insert(
      HabitLogsCompanion(
        habitId: Value(habitId),
        logDate: Value(dateOnly),
        isSkipped: const Value(true),
      ),
      onConflict: DoUpdate(
        (_) => const HabitLogsCompanion(isSkipped: Value(true)),
        target: [habitLogs.habitId, habitLogs.logDate],
      ),
    );
    await _saveStreak(habitId);
  }

  Stream<List<HabitLog>> watchHabitAllLogs(int habitId) =>
      (select(habitLogs)
            ..where((l) => l.habitId.equals(habitId))
            ..orderBy([(l) => OrderingTerm(expression: l.logDate)]))
          .watch();

  Stream<List<HabitLog>> watchAllLogsInRange(DateTime from, DateTime to) =>
      (select(habitLogs)
            ..where((l) =>
                l.logDate.isBiggerOrEqualValue(from) &
                l.logDate.isSmallerThanValue(to))
            ..orderBy([(l) => OrderingTerm(expression: l.logDate)]))
          .watch();

  Future<void> deleteHabit(int id) =>
      (delete(habits)..where((h) => h.id.equals(id))).go();
}

@DriftAccessor(tables: [Goals, GoalTaskLinks, GoalHabitLinks])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  Stream<List<Goal>> watchAll() =>
      (select(goals)..orderBy([(g) => OrderingTerm(expression: g.id)]))
          .watch();

  Future<List<GoalTaskLink>> getTaskLinks(int goalId) =>
      (select(goalTaskLinks)..where((l) => l.goalId.equals(goalId))).get();

  Future<List<GoalHabitLink>> getHabitLinks(int goalId) =>
      (select(goalHabitLinks)..where((l) => l.goalId.equals(goalId))).get();

  Stream<Goal?> watchGoal(int id) =>
      (select(goals)..where((g) => g.id.equals(id))).watchSingleOrNull();

  Future<Goal?> getGoal(int id) =>
      (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<void> updateGoal(int id, GoalsCompanion companion) =>
      (update(goals)..where((g) => g.id.equals(id))).write(companion);

  Future<int> insertGoal(GoalsCompanion entry) => into(goals).insert(entry);

  Future<void> insertTaskLink(GoalTaskLinksCompanion entry) =>
      into(goalTaskLinks).insert(entry);

  Future<void> insertHabitLink(GoalHabitLinksCompanion entry) =>
      into(goalHabitLinks).insert(entry);

  Stream<List<GoalTaskLink>> watchTaskLinks(int goalId) =>
      (select(goalTaskLinks)..where((l) => l.goalId.equals(goalId))).watch();

  Future<void> linkTask(int goalId, int taskId) async {
    await into(goalTaskLinks).insertOnConflictUpdate(
      GoalTaskLinksCompanion(goalId: Value(goalId), taskId: Value(taskId)),
    );
    await db.recomputeGoalProgress(goalId);
  }

  Future<void> unlinkTask(int goalId, int taskId) async {
    await (delete(goalTaskLinks)
          ..where((l) => l.goalId.equals(goalId) & l.taskId.equals(taskId)))
        .go();
    await db.recomputeGoalProgress(goalId);
  }

  Stream<List<GoalHabitLink>> watchHabitLinks(int goalId) =>
      (select(goalHabitLinks)..where((l) => l.goalId.equals(goalId))).watch();

  Future<void> linkHabit(int goalId, int habitId) =>
      into(goalHabitLinks).insertOnConflictUpdate(
        GoalHabitLinksCompanion(goalId: Value(goalId), habitId: Value(habitId)),
      );

  Future<void> unlinkHabit(int goalId, int habitId) =>
      (delete(goalHabitLinks)
            ..where((l) => l.goalId.equals(goalId) & l.habitId.equals(habitId)))
          .go();

  Future<void> deleteGoal(int id) =>
      (delete(goals)..where((g) => g.id.equals(id))).go();
}

@DriftAccessor(tables: [Notes, NoteTags, NoteTaskLinks])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchAll() => (select(notes)
        ..orderBy([
          (n) =>
              OrderingTerm(expression: n.isPinned, mode: OrderingMode.desc),
          (n) => OrderingTerm(expression: n.updatedAt, mode: OrderingMode.desc),
        ]))
      .watch();

  Stream<List<NoteTag>> watchTags(int noteId) => (select(noteTags)
        ..where((t) => t.noteId.equals(noteId))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .watch();

  Future<List<NoteTag>> getTagsOnce(int noteId) =>
      (select(noteTags)..where((t) => t.noteId.equals(noteId))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<Note?> getNote(int id) =>
      (select(notes)..where((n) => n.id.equals(id))).getSingleOrNull();

  Future<int> insertNote(NotesCompanion entry) => into(notes).insert(entry);

  Future<void> updateNote(int id, NotesCompanion companion) =>
      (update(notes)..where((n) => n.id.equals(id))).write(companion);

  Future<int> insertTag(NoteTagsCompanion entry) =>
      into(noteTags).insert(entry);

  Future<void> deleteNote(int id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();

  // ── Linked tasks ──────────────────────────────────────────────────────────

  Stream<List<NoteTaskLink>> watchTaskLinks(int noteId) =>
      (select(noteTaskLinks)..where((l) => l.noteId.equals(noteId))).watch();

  Future<List<NoteTaskLink>> getTaskLinks(int noteId) =>
      (select(noteTaskLinks)..where((l) => l.noteId.equals(noteId))).get();

  Future<void> linkTask(int noteId, int taskId) =>
      into(noteTaskLinks).insertOnConflictUpdate(
        NoteTaskLinksCompanion(noteId: Value(noteId), taskId: Value(taskId)),
      );

  Future<void> unlinkTask(int noteId, int taskId) =>
      (delete(noteTaskLinks)
            ..where((l) => l.noteId.equals(noteId) & l.taskId.equals(taskId)))
          .go();

  /// Replaces a note's linked-task set in one pass (used on save).
  Future<void> setTaskLinks(int noteId, Set<int> taskIds) async {
    final current = (await getTaskLinks(noteId)).map((l) => l.taskId).toSet();
    for (final id in taskIds.difference(current)) { await linkTask(noteId, id); }
    for (final id in current.difference(taskIds)) { await unlinkTask(noteId, id); }
  }
}

@DriftAccessor(tables: [CalendarEvents])
class CalendarDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarDaoMixin {
  CalendarDao(super.db);

  Stream<List<CalendarEvent>> watchAll() => (select(calendarEvents)
        ..orderBy([
          (e) => OrderingTerm(expression: e.timeSlot),
          (e) => OrderingTerm(expression: e.id),
        ]))
      .watch();

  Future<int> insertEvent(CalendarEventsCompanion entry) =>
      into(calendarEvents).insert(entry);

  Future<void> acceptInvite(int id) =>
      (update(calendarEvents)..where((e) => e.id.equals(id)))
          .write(const CalendarEventsCompanion(isInvite: Value(false)));

  Future<CalendarEvent?> getEvent(int id) =>
      (select(calendarEvents)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> updateEvent(int id, CalendarEventsCompanion companion) =>
      (update(calendarEvents)..where((e) => e.id.equals(id))).write(companion);

  Future<void> deleteEvent(int id) =>
      (delete(calendarEvents)..where((e) => e.id.equals(id))).go();
}

@DriftAccessor(tables: [CustomLists, CustomListItems])
class ListsDao extends DatabaseAccessor<AppDatabase> with _$ListsDaoMixin {
  ListsDao(super.db);

  Stream<List<CustomList>> watchAll() =>
      (select(customLists)
        ..orderBy([(l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Stream<List<CustomListItem>> watchItems(int listId) =>
      (select(customListItems)
        ..where((i) => i.listId.equals(listId))
        ..orderBy([(i) => OrderingTerm(expression: i.sortOrder)]))
          .watch();

  Future<int> createList(CustomListsCompanion entry) =>
      into(customLists).insert(entry);

  Future<int> addItem(CustomListItemsCompanion entry) =>
      into(customListItems).insert(entry);

  Future<void> toggleItem(int id, bool done) =>
      (update(customListItems)..where((i) => i.id.equals(id)))
          .write(CustomListItemsCompanion(isDone: Value(done)));

  Future<void> deleteList(int id) =>
      (delete(customLists)..where((l) => l.id.equals(id))).go();

  Future<void> deleteItem(int id) =>
      (delete(customListItems)..where((i) => i.id.equals(id))).go();

  Future<void> updateListTitle(int id, String title) =>
      (update(customLists)..where((l) => l.id.equals(id)))
          .write(CustomListsCompanion(title: Value(title)));

  Future<void> updateList(int id, CustomListsCompanion data) =>
      (update(customLists)..where((l) => l.id.equals(id))).write(data);

  Future<bool> isEmpty() async =>
      (await (select(customLists)..limit(1)).get()).isEmpty;

  Future<void> seedDefaults() async {
    final seeds = [
      ('🛒', 'Grocery Shopping', ['Milk', 'Eggs', 'Bread', 'Fruits', 'Vegetables', 'Cooking oil']),
      ('💳', 'Pay Bills',        ['Electricity', 'Internet', 'Rent', 'Phone bill', 'Insurance']),
      ('🛍️', 'Wish List',        ['Wireless earbuds', 'New book', 'Running shoes']),
      ('📦', 'Packing List',     ['Passport / ID', 'Phone charger', 'Clothes', 'Toiletries', 'Laptop']),
      ('🧹', 'Chores',           ['Vacuum floors', 'Do laundry', 'Clean kitchen', 'Take out trash']),
      ('💊', 'Medications',      <String>[]),
      ('📚', 'Books to Read',    <String>[]),
      ('🎁', 'Gift Ideas',       <String>[]),
    ];
    for (final (emoji, title, items) in seeds) {
      final id = await createList(CustomListsCompanion(
        emoji: Value(emoji),
        title: Value(title),
      ));
      for (int i = 0; i < items.length; i++) {
        await addItem(CustomListItemsCompanion(
          listId:    Value(id),
          content:   Value(items[i]),
          sortOrder: Value(i),
        ));
      }
    }
  }
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Tasks,
    Subtasks,
    Habits,
    SubHabits,
    HabitLogs,
    Goals,
    GoalTaskLinks,
    GoalHabitLinks,
    Notes,
    NoteTags,
    NoteTaskLinks,
    CalendarEvents,
    CustomLists,
    CustomListItems,
    FocusSessions,
  ],
  daos: [TasksDao, HabitsDao, GoalsDao, NotesDao, CalendarDao, ListsDao, FocusDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openDatabaseConnection());

  // Returns a live stream of Task rows linked to a goal.
  Stream<List<Task>> watchLinkedTasks(int goalId) {
    final q = select(tasks).join([
      innerJoin(goalTaskLinks, goalTaskLinks.taskId.equalsExp(tasks.id)),
    ])..where(goalTaskLinks.goalId.equals(goalId));
    return q.watch().map((rows) => rows.map((r) => r.readTable(tasks)).toList());
  }

  // Returns a live stream of Task rows linked to a note.
  Stream<List<Task>> watchNoteLinkedTasks(int noteId) {
    final q = select(tasks).join([
      innerJoin(noteTaskLinks, noteTaskLinks.taskId.equalsExp(tasks.id)),
    ])..where(noteTaskLinks.noteId.equals(noteId));
    return q.watch().map((rows) => rows.map((r) => r.readTable(tasks)).toList());
  }

  // Recomputes progressPct and linkedLabel for a goal from its linked task completion.
  Future<void> recomputeGoalProgress(int goalId) async {
    final links = await (select(goalTaskLinks)..where((l) => l.goalId.equals(goalId))).get();
    if (links.isEmpty) return;
    final taskIds  = links.map((l) => l.taskId).toList();
    final taskRows = await (select(tasks)..where((t) => t.id.isIn(taskIds))).get();
    final done     = taskRows.where((t) => t.isDone).length;
    final total    = links.length;
    await (update(goals)..where((g) => g.id.equals(goalId))).write(GoalsCompanion(
      progressPct:  Value(total > 0 ? done / total : 0.0),
      linkedLabel:  Value('Linked tasks · $done/$total'),
    ));
  }

  // Called from TasksDao.toggleDone — finds every goal linked to this task and recomputes.
  Future<void> recomputeGoalForTask(int taskId) async {
    final links = await (select(goalTaskLinks)..where((l) => l.taskId.equals(taskId))).get();
    for (final link in links) {
      await recomputeGoalProgress(link.goalId);
    }
  }

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Fresh install: create all tables at current schema, skip onUpgrade entirely.
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(tasks, tasks.priority);
        await m.addColumn(tasks, tasks.notes);
      }
      if (from < 3) {
        await m.addColumn(habits, habits.lastCheckedDate);
      }
      if (from < 4) {
        // createTable uses the current Dart schema, which already includes
        // isSkipped — so the v4→v5 addColumn must be guarded.
        await m.createTable(habitLogs);
      }
      if (from < 5) {
        // Guard: if the table was created at v4 with isSkipped already in the
        // Dart schema, the column exists and ALTER TABLE would crash.
        final cols = await customSelect('PRAGMA table_info(habit_logs)').get();
        final hasCol = cols.any((r) => r.read<String>('name') == 'is_skipped');
        if (!hasCol) {
          await m.addColumn(habitLogs, habitLogs.isSkipped);
        }
      }
      if (from < 6) {
        await m.createTable(customLists);
        await m.createTable(customListItems);
      }
      if (from < 7) {
        await m.addColumn(tasks, tasks.timeAllocatedMin);
        await m.addColumn(tasks, tasks.goalWeight);
        await m.addColumn(tasks, tasks.urgency);
        await m.addColumn(tasks, tasks.impact);
        await m.addColumn(tasks, tasks.focusFit);
      }
      if (from < 8) {
        await m.addColumn(goals, goals.deadline);
        await m.addColumn(goals, goals.milestones);
        await m.addColumn(customLists, customLists.parentId);
      }
      if (from < 9) {
        await m.addColumn(customLists, customLists.dueDate);
      }
      if (from < 10) {
        await m.addColumn(customLists, customLists.recurrenceLabel);
      }
      if (from < 11) {
        await m.createTable(focusSessions);
        await m.addColumn(tasks, tasks.totalFocusSeconds);
      }
      if (from < 12) {
        await m.addColumn(habits, habits.scheduledTime);
      }
      if (from < 13) {
        await m.createTable(noteTaskLinks);
      }
      if (from < 14) {
        await m.addColumn(tasks, tasks.labels);
      }
      if (from < 15) {
        await m.addColumn(habits, habits.notes);
        await m.addColumn(goals, goals.notes);
      }
    },
  );
}

