// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
mixin _$TasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $SubtasksTable get subtasks => attachedDatabase.subtasks;
  TasksDaoManager get managers => TasksDaoManager(this);
}

class TasksDaoManager {
  final _$TasksDaoMixin _db;
  TasksDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db.attachedDatabase, _db.subtasks);
}

mixin _$FocusDaoMixin on DatabaseAccessor<AppDatabase> {
  $FocusSessionsTable get focusSessions => attachedDatabase.focusSessions;
  FocusDaoManager get managers => FocusDaoManager(this);
}

class FocusDaoManager {
  final _$FocusDaoMixin _db;
  FocusDaoManager(this._db);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db.attachedDatabase, _db.focusSessions);
}

mixin _$HabitsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $SubHabitsTable get subHabits => attachedDatabase.subHabits;
  $HabitLogsTable get habitLogs => attachedDatabase.habitLogs;
  HabitsDaoManager get managers => HabitsDaoManager(this);
}

class HabitsDaoManager {
  final _$HabitsDaoMixin _db;
  HabitsDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$SubHabitsTableTableManager get subHabits =>
      $$SubHabitsTableTableManager(_db.attachedDatabase, _db.subHabits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db.attachedDatabase, _db.habitLogs);
}

mixin _$GoalsDaoMixin on DatabaseAccessor<AppDatabase> {
  $GoalsTable get goals => attachedDatabase.goals;
  $GoalTaskLinksTable get goalTaskLinks => attachedDatabase.goalTaskLinks;
  $GoalHabitLinksTable get goalHabitLinks => attachedDatabase.goalHabitLinks;
  GoalsDaoManager get managers => GoalsDaoManager(this);
}

class GoalsDaoManager {
  final _$GoalsDaoMixin _db;
  GoalsDaoManager(this._db);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$GoalTaskLinksTableTableManager get goalTaskLinks =>
      $$GoalTaskLinksTableTableManager(_db.attachedDatabase, _db.goalTaskLinks);
  $$GoalHabitLinksTableTableManager get goalHabitLinks =>
      $$GoalHabitLinksTableTableManager(
        _db.attachedDatabase,
        _db.goalHabitLinks,
      );
}

mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotesTable get notes => attachedDatabase.notes;
  $NoteTagsTable get noteTags => attachedDatabase.noteTags;
  $NoteTaskLinksTable get noteTaskLinks => attachedDatabase.noteTaskLinks;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db.attachedDatabase, _db.notes);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db.attachedDatabase, _db.noteTags);
  $$NoteTaskLinksTableTableManager get noteTaskLinks =>
      $$NoteTaskLinksTableTableManager(_db.attachedDatabase, _db.noteTaskLinks);
}

mixin _$CalendarDaoMixin on DatabaseAccessor<AppDatabase> {
  $CalendarEventsTable get calendarEvents => attachedDatabase.calendarEvents;
  CalendarDaoManager get managers => CalendarDaoManager(this);
}

class CalendarDaoManager {
  final _$CalendarDaoMixin _db;
  CalendarDaoManager(this._db);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(
        _db.attachedDatabase,
        _db.calendarEvents,
      );
}

mixin _$ListsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomListsTable get customLists => attachedDatabase.customLists;
  $CustomListItemsTable get customListItems => attachedDatabase.customListItems;
  ListsDaoManager get managers => ListsDaoManager(this);
}

class ListsDaoManager {
  final _$ListsDaoMixin _db;
  ListsDaoManager(this._db);
  $$CustomListsTableTableManager get customLists =>
      $$CustomListsTableTableManager(_db.attachedDatabase, _db.customLists);
  $$CustomListItemsTableTableManager get customListItems =>
      $$CustomListItemsTableTableManager(
        _db.attachedDatabase,
        _db.customListItems,
      );
}

mixin _$DatabasesDaoMixin on DatabaseAccessor<AppDatabase> {
  $KaalDatabasesTable get kaalDatabases => attachedDatabase.kaalDatabases;
  $DbPropertiesTable get dbProperties => attachedDatabase.dbProperties;
  $DbRowsTable get dbRows => attachedDatabase.dbRows;
  DatabasesDaoManager get managers => DatabasesDaoManager(this);
}

class DatabasesDaoManager {
  final _$DatabasesDaoMixin _db;
  DatabasesDaoManager(this._db);
  $$KaalDatabasesTableTableManager get kaalDatabases =>
      $$KaalDatabasesTableTableManager(_db.attachedDatabase, _db.kaalDatabases);
  $$DbPropertiesTableTableManager get dbProperties =>
      $$DbPropertiesTableTableManager(_db.attachedDatabase, _db.dbProperties);
  $$DbRowsTableTableManager get dbRows =>
      $$DbRowsTableTableManager(_db.attachedDatabase, _db.dbRows);
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quadrantMeta = const VerificationMeta(
    'quadrant',
  );
  @override
  late final GeneratedColumn<int> quadrant = GeneratedColumn<int>(
    'quadrant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueLabelMeta = const VerificationMeta(
    'dueLabel',
  );
  @override
  late final GeneratedColumn<String> dueLabel = GeneratedColumn<String>(
    'due_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOverdueMeta = const VerificationMeta(
    'isOverdue',
  );
  @override
  late final GeneratedColumn<bool> isOverdue = GeneratedColumn<bool>(
    'is_overdue',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_overdue" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasAiMeta = const VerificationMeta('hasAi');
  @override
  late final GeneratedColumn<bool> hasAi = GeneratedColumn<bool>(
    'has_ai',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_ai" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _urgencyScoreMeta = const VerificationMeta(
    'urgencyScore',
  );
  @override
  late final GeneratedColumn<double> urgencyScore = GeneratedColumn<double>(
    'urgency_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceLabelMeta = const VerificationMeta(
    'recurrenceLabel',
  );
  @override
  late final GeneratedColumn<String> recurrenceLabel = GeneratedColumn<String>(
    'recurrence_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasPomodoroMeta = const VerificationMeta(
    'hasPomodoro',
  );
  @override
  late final GeneratedColumn<bool> hasPomodoro = GeneratedColumn<bool>(
    'has_pomodoro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pomodoro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeAllocatedMinMeta = const VerificationMeta(
    'timeAllocatedMin',
  );
  @override
  late final GeneratedColumn<int> timeAllocatedMin = GeneratedColumn<int>(
    'time_allocated_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalWeightMeta = const VerificationMeta(
    'goalWeight',
  );
  @override
  late final GeneratedColumn<double> goalWeight = GeneratedColumn<double>(
    'goal_weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urgencyMeta = const VerificationMeta(
    'urgency',
  );
  @override
  late final GeneratedColumn<double> urgency = GeneratedColumn<double>(
    'urgency',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<double> impact = GeneratedColumn<double>(
    'impact',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusFitMeta = const VerificationMeta(
    'focusFit',
  );
  @override
  late final GeneratedColumn<double> focusFit = GeneratedColumn<double>(
    'focus_fit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalFocusSecondsMeta = const VerificationMeta(
    'totalFocusSeconds',
  );
  @override
  late final GeneratedColumn<int> totalFocusSeconds = GeneratedColumn<int>(
    'total_focus_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    quadrant,
    dueDate,
    dueLabel,
    isOverdue,
    hasAi,
    urgencyScore,
    recurrenceLabel,
    hasPomodoro,
    priority,
    notes,
    timeAllocatedMin,
    goalWeight,
    urgency,
    impact,
    focusFit,
    isDone,
    doneAt,
    sortOrder,
    createdAt,
    totalFocusSeconds,
    labels,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quadrant')) {
      context.handle(
        _quadrantMeta,
        quadrant.isAcceptableOrUnknown(data['quadrant']!, _quadrantMeta),
      );
    } else if (isInserting) {
      context.missing(_quadrantMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('due_label')) {
      context.handle(
        _dueLabelMeta,
        dueLabel.isAcceptableOrUnknown(data['due_label']!, _dueLabelMeta),
      );
    }
    if (data.containsKey('is_overdue')) {
      context.handle(
        _isOverdueMeta,
        isOverdue.isAcceptableOrUnknown(data['is_overdue']!, _isOverdueMeta),
      );
    }
    if (data.containsKey('has_ai')) {
      context.handle(
        _hasAiMeta,
        hasAi.isAcceptableOrUnknown(data['has_ai']!, _hasAiMeta),
      );
    }
    if (data.containsKey('urgency_score')) {
      context.handle(
        _urgencyScoreMeta,
        urgencyScore.isAcceptableOrUnknown(
          data['urgency_score']!,
          _urgencyScoreMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_label')) {
      context.handle(
        _recurrenceLabelMeta,
        recurrenceLabel.isAcceptableOrUnknown(
          data['recurrence_label']!,
          _recurrenceLabelMeta,
        ),
      );
    }
    if (data.containsKey('has_pomodoro')) {
      context.handle(
        _hasPomodoroMeta,
        hasPomodoro.isAcceptableOrUnknown(
          data['has_pomodoro']!,
          _hasPomodoroMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('time_allocated_min')) {
      context.handle(
        _timeAllocatedMinMeta,
        timeAllocatedMin.isAcceptableOrUnknown(
          data['time_allocated_min']!,
          _timeAllocatedMinMeta,
        ),
      );
    }
    if (data.containsKey('goal_weight')) {
      context.handle(
        _goalWeightMeta,
        goalWeight.isAcceptableOrUnknown(data['goal_weight']!, _goalWeightMeta),
      );
    }
    if (data.containsKey('urgency')) {
      context.handle(
        _urgencyMeta,
        urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta),
      );
    }
    if (data.containsKey('impact')) {
      context.handle(
        _impactMeta,
        impact.isAcceptableOrUnknown(data['impact']!, _impactMeta),
      );
    }
    if (data.containsKey('focus_fit')) {
      context.handle(
        _focusFitMeta,
        focusFit.isAcceptableOrUnknown(data['focus_fit']!, _focusFitMeta),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('total_focus_seconds')) {
      context.handle(
        _totalFocusSecondsMeta,
        totalFocusSeconds.isAcceptableOrUnknown(
          data['total_focus_seconds']!,
          _totalFocusSecondsMeta,
        ),
      );
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quadrant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quadrant'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      dueLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_label'],
      ),
      isOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_overdue'],
      )!,
      hasAi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_ai'],
      )!,
      urgencyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}urgency_score'],
      ),
      recurrenceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_label'],
      ),
      hasPomodoro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pomodoro'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      timeAllocatedMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_allocated_min'],
      ),
      goalWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_weight'],
      ),
      urgency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}urgency'],
      ),
      impact: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}impact'],
      ),
      focusFit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focus_fit'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      totalFocusSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_focus_seconds'],
      )!,
      labels: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labels'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final int quadrant;
  final DateTime? dueDate;
  final String? dueLabel;
  final bool isOverdue;
  final bool hasAi;
  final double? urgencyScore;
  final String? recurrenceLabel;
  final bool hasPomodoro;
  final String? priority;
  final String? notes;
  final int? timeAllocatedMin;
  final double? goalWeight;
  final double? urgency;
  final double? impact;
  final double? focusFit;
  final bool isDone;
  final DateTime? doneAt;
  final int sortOrder;
  final DateTime createdAt;
  final int totalFocusSeconds;
  final String? labels;
  const Task({
    required this.id,
    required this.title,
    required this.quadrant,
    this.dueDate,
    this.dueLabel,
    required this.isOverdue,
    required this.hasAi,
    this.urgencyScore,
    this.recurrenceLabel,
    required this.hasPomodoro,
    this.priority,
    this.notes,
    this.timeAllocatedMin,
    this.goalWeight,
    this.urgency,
    this.impact,
    this.focusFit,
    required this.isDone,
    this.doneAt,
    required this.sortOrder,
    required this.createdAt,
    required this.totalFocusSeconds,
    this.labels,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['quadrant'] = Variable<int>(quadrant);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || dueLabel != null) {
      map['due_label'] = Variable<String>(dueLabel);
    }
    map['is_overdue'] = Variable<bool>(isOverdue);
    map['has_ai'] = Variable<bool>(hasAi);
    if (!nullToAbsent || urgencyScore != null) {
      map['urgency_score'] = Variable<double>(urgencyScore);
    }
    if (!nullToAbsent || recurrenceLabel != null) {
      map['recurrence_label'] = Variable<String>(recurrenceLabel);
    }
    map['has_pomodoro'] = Variable<bool>(hasPomodoro);
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || timeAllocatedMin != null) {
      map['time_allocated_min'] = Variable<int>(timeAllocatedMin);
    }
    if (!nullToAbsent || goalWeight != null) {
      map['goal_weight'] = Variable<double>(goalWeight);
    }
    if (!nullToAbsent || urgency != null) {
      map['urgency'] = Variable<double>(urgency);
    }
    if (!nullToAbsent || impact != null) {
      map['impact'] = Variable<double>(impact);
    }
    if (!nullToAbsent || focusFit != null) {
      map['focus_fit'] = Variable<double>(focusFit);
    }
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['total_focus_seconds'] = Variable<int>(totalFocusSeconds);
    if (!nullToAbsent || labels != null) {
      map['labels'] = Variable<String>(labels);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      quadrant: Value(quadrant),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dueLabel: dueLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(dueLabel),
      isOverdue: Value(isOverdue),
      hasAi: Value(hasAi),
      urgencyScore: urgencyScore == null && nullToAbsent
          ? const Value.absent()
          : Value(urgencyScore),
      recurrenceLabel: recurrenceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceLabel),
      hasPomodoro: Value(hasPomodoro),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      timeAllocatedMin: timeAllocatedMin == null && nullToAbsent
          ? const Value.absent()
          : Value(timeAllocatedMin),
      goalWeight: goalWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(goalWeight),
      urgency: urgency == null && nullToAbsent
          ? const Value.absent()
          : Value(urgency),
      impact: impact == null && nullToAbsent
          ? const Value.absent()
          : Value(impact),
      focusFit: focusFit == null && nullToAbsent
          ? const Value.absent()
          : Value(focusFit),
      isDone: Value(isDone),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      totalFocusSeconds: Value(totalFocusSeconds),
      labels: labels == null && nullToAbsent
          ? const Value.absent()
          : Value(labels),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      quadrant: serializer.fromJson<int>(json['quadrant']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      dueLabel: serializer.fromJson<String?>(json['dueLabel']),
      isOverdue: serializer.fromJson<bool>(json['isOverdue']),
      hasAi: serializer.fromJson<bool>(json['hasAi']),
      urgencyScore: serializer.fromJson<double?>(json['urgencyScore']),
      recurrenceLabel: serializer.fromJson<String?>(json['recurrenceLabel']),
      hasPomodoro: serializer.fromJson<bool>(json['hasPomodoro']),
      priority: serializer.fromJson<String?>(json['priority']),
      notes: serializer.fromJson<String?>(json['notes']),
      timeAllocatedMin: serializer.fromJson<int?>(json['timeAllocatedMin']),
      goalWeight: serializer.fromJson<double?>(json['goalWeight']),
      urgency: serializer.fromJson<double?>(json['urgency']),
      impact: serializer.fromJson<double?>(json['impact']),
      focusFit: serializer.fromJson<double?>(json['focusFit']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      totalFocusSeconds: serializer.fromJson<int>(json['totalFocusSeconds']),
      labels: serializer.fromJson<String?>(json['labels']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'quadrant': serializer.toJson<int>(quadrant),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'dueLabel': serializer.toJson<String?>(dueLabel),
      'isOverdue': serializer.toJson<bool>(isOverdue),
      'hasAi': serializer.toJson<bool>(hasAi),
      'urgencyScore': serializer.toJson<double?>(urgencyScore),
      'recurrenceLabel': serializer.toJson<String?>(recurrenceLabel),
      'hasPomodoro': serializer.toJson<bool>(hasPomodoro),
      'priority': serializer.toJson<String?>(priority),
      'notes': serializer.toJson<String?>(notes),
      'timeAllocatedMin': serializer.toJson<int?>(timeAllocatedMin),
      'goalWeight': serializer.toJson<double?>(goalWeight),
      'urgency': serializer.toJson<double?>(urgency),
      'impact': serializer.toJson<double?>(impact),
      'focusFit': serializer.toJson<double?>(focusFit),
      'isDone': serializer.toJson<bool>(isDone),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'totalFocusSeconds': serializer.toJson<int>(totalFocusSeconds),
      'labels': serializer.toJson<String?>(labels),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    int? quadrant,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> dueLabel = const Value.absent(),
    bool? isOverdue,
    bool? hasAi,
    Value<double?> urgencyScore = const Value.absent(),
    Value<String?> recurrenceLabel = const Value.absent(),
    bool? hasPomodoro,
    Value<String?> priority = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> timeAllocatedMin = const Value.absent(),
    Value<double?> goalWeight = const Value.absent(),
    Value<double?> urgency = const Value.absent(),
    Value<double?> impact = const Value.absent(),
    Value<double?> focusFit = const Value.absent(),
    bool? isDone,
    Value<DateTime?> doneAt = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    int? totalFocusSeconds,
    Value<String?> labels = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    quadrant: quadrant ?? this.quadrant,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    dueLabel: dueLabel.present ? dueLabel.value : this.dueLabel,
    isOverdue: isOverdue ?? this.isOverdue,
    hasAi: hasAi ?? this.hasAi,
    urgencyScore: urgencyScore.present ? urgencyScore.value : this.urgencyScore,
    recurrenceLabel: recurrenceLabel.present
        ? recurrenceLabel.value
        : this.recurrenceLabel,
    hasPomodoro: hasPomodoro ?? this.hasPomodoro,
    priority: priority.present ? priority.value : this.priority,
    notes: notes.present ? notes.value : this.notes,
    timeAllocatedMin: timeAllocatedMin.present
        ? timeAllocatedMin.value
        : this.timeAllocatedMin,
    goalWeight: goalWeight.present ? goalWeight.value : this.goalWeight,
    urgency: urgency.present ? urgency.value : this.urgency,
    impact: impact.present ? impact.value : this.impact,
    focusFit: focusFit.present ? focusFit.value : this.focusFit,
    isDone: isDone ?? this.isDone,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
    labels: labels.present ? labels.value : this.labels,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      quadrant: data.quadrant.present ? data.quadrant.value : this.quadrant,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueLabel: data.dueLabel.present ? data.dueLabel.value : this.dueLabel,
      isOverdue: data.isOverdue.present ? data.isOverdue.value : this.isOverdue,
      hasAi: data.hasAi.present ? data.hasAi.value : this.hasAi,
      urgencyScore: data.urgencyScore.present
          ? data.urgencyScore.value
          : this.urgencyScore,
      recurrenceLabel: data.recurrenceLabel.present
          ? data.recurrenceLabel.value
          : this.recurrenceLabel,
      hasPomodoro: data.hasPomodoro.present
          ? data.hasPomodoro.value
          : this.hasPomodoro,
      priority: data.priority.present ? data.priority.value : this.priority,
      notes: data.notes.present ? data.notes.value : this.notes,
      timeAllocatedMin: data.timeAllocatedMin.present
          ? data.timeAllocatedMin.value
          : this.timeAllocatedMin,
      goalWeight: data.goalWeight.present
          ? data.goalWeight.value
          : this.goalWeight,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      impact: data.impact.present ? data.impact.value : this.impact,
      focusFit: data.focusFit.present ? data.focusFit.value : this.focusFit,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      totalFocusSeconds: data.totalFocusSeconds.present
          ? data.totalFocusSeconds.value
          : this.totalFocusSeconds,
      labels: data.labels.present ? data.labels.value : this.labels,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quadrant: $quadrant, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueLabel: $dueLabel, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('hasAi: $hasAi, ')
          ..write('urgencyScore: $urgencyScore, ')
          ..write('recurrenceLabel: $recurrenceLabel, ')
          ..write('hasPomodoro: $hasPomodoro, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('timeAllocatedMin: $timeAllocatedMin, ')
          ..write('goalWeight: $goalWeight, ')
          ..write('urgency: $urgency, ')
          ..write('impact: $impact, ')
          ..write('focusFit: $focusFit, ')
          ..write('isDone: $isDone, ')
          ..write('doneAt: $doneAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('labels: $labels')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    quadrant,
    dueDate,
    dueLabel,
    isOverdue,
    hasAi,
    urgencyScore,
    recurrenceLabel,
    hasPomodoro,
    priority,
    notes,
    timeAllocatedMin,
    goalWeight,
    urgency,
    impact,
    focusFit,
    isDone,
    doneAt,
    sortOrder,
    createdAt,
    totalFocusSeconds,
    labels,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.quadrant == this.quadrant &&
          other.dueDate == this.dueDate &&
          other.dueLabel == this.dueLabel &&
          other.isOverdue == this.isOverdue &&
          other.hasAi == this.hasAi &&
          other.urgencyScore == this.urgencyScore &&
          other.recurrenceLabel == this.recurrenceLabel &&
          other.hasPomodoro == this.hasPomodoro &&
          other.priority == this.priority &&
          other.notes == this.notes &&
          other.timeAllocatedMin == this.timeAllocatedMin &&
          other.goalWeight == this.goalWeight &&
          other.urgency == this.urgency &&
          other.impact == this.impact &&
          other.focusFit == this.focusFit &&
          other.isDone == this.isDone &&
          other.doneAt == this.doneAt &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.totalFocusSeconds == this.totalFocusSeconds &&
          other.labels == this.labels);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> quadrant;
  final Value<DateTime?> dueDate;
  final Value<String?> dueLabel;
  final Value<bool> isOverdue;
  final Value<bool> hasAi;
  final Value<double?> urgencyScore;
  final Value<String?> recurrenceLabel;
  final Value<bool> hasPomodoro;
  final Value<String?> priority;
  final Value<String?> notes;
  final Value<int?> timeAllocatedMin;
  final Value<double?> goalWeight;
  final Value<double?> urgency;
  final Value<double?> impact;
  final Value<double?> focusFit;
  final Value<bool> isDone;
  final Value<DateTime?> doneAt;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> totalFocusSeconds;
  final Value<String?> labels;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.quadrant = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueLabel = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.hasAi = const Value.absent(),
    this.urgencyScore = const Value.absent(),
    this.recurrenceLabel = const Value.absent(),
    this.hasPomodoro = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.timeAllocatedMin = const Value.absent(),
    this.goalWeight = const Value.absent(),
    this.urgency = const Value.absent(),
    this.impact = const Value.absent(),
    this.focusFit = const Value.absent(),
    this.isDone = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    this.labels = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int quadrant,
    this.dueDate = const Value.absent(),
    this.dueLabel = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.hasAi = const Value.absent(),
    this.urgencyScore = const Value.absent(),
    this.recurrenceLabel = const Value.absent(),
    this.hasPomodoro = const Value.absent(),
    this.priority = const Value.absent(),
    this.notes = const Value.absent(),
    this.timeAllocatedMin = const Value.absent(),
    this.goalWeight = const Value.absent(),
    this.urgency = const Value.absent(),
    this.impact = const Value.absent(),
    this.focusFit = const Value.absent(),
    this.isDone = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    this.labels = const Value.absent(),
  }) : title = Value(title),
       quadrant = Value(quadrant);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? quadrant,
    Expression<DateTime>? dueDate,
    Expression<String>? dueLabel,
    Expression<bool>? isOverdue,
    Expression<bool>? hasAi,
    Expression<double>? urgencyScore,
    Expression<String>? recurrenceLabel,
    Expression<bool>? hasPomodoro,
    Expression<String>? priority,
    Expression<String>? notes,
    Expression<int>? timeAllocatedMin,
    Expression<double>? goalWeight,
    Expression<double>? urgency,
    Expression<double>? impact,
    Expression<double>? focusFit,
    Expression<bool>? isDone,
    Expression<DateTime>? doneAt,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? totalFocusSeconds,
    Expression<String>? labels,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (quadrant != null) 'quadrant': quadrant,
      if (dueDate != null) 'due_date': dueDate,
      if (dueLabel != null) 'due_label': dueLabel,
      if (isOverdue != null) 'is_overdue': isOverdue,
      if (hasAi != null) 'has_ai': hasAi,
      if (urgencyScore != null) 'urgency_score': urgencyScore,
      if (recurrenceLabel != null) 'recurrence_label': recurrenceLabel,
      if (hasPomodoro != null) 'has_pomodoro': hasPomodoro,
      if (priority != null) 'priority': priority,
      if (notes != null) 'notes': notes,
      if (timeAllocatedMin != null) 'time_allocated_min': timeAllocatedMin,
      if (goalWeight != null) 'goal_weight': goalWeight,
      if (urgency != null) 'urgency': urgency,
      if (impact != null) 'impact': impact,
      if (focusFit != null) 'focus_fit': focusFit,
      if (isDone != null) 'is_done': isDone,
      if (doneAt != null) 'done_at': doneAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (totalFocusSeconds != null) 'total_focus_seconds': totalFocusSeconds,
      if (labels != null) 'labels': labels,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? quadrant,
    Value<DateTime?>? dueDate,
    Value<String?>? dueLabel,
    Value<bool>? isOverdue,
    Value<bool>? hasAi,
    Value<double?>? urgencyScore,
    Value<String?>? recurrenceLabel,
    Value<bool>? hasPomodoro,
    Value<String?>? priority,
    Value<String?>? notes,
    Value<int?>? timeAllocatedMin,
    Value<double?>? goalWeight,
    Value<double?>? urgency,
    Value<double?>? impact,
    Value<double?>? focusFit,
    Value<bool>? isDone,
    Value<DateTime?>? doneAt,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? totalFocusSeconds,
    Value<String?>? labels,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      quadrant: quadrant ?? this.quadrant,
      dueDate: dueDate ?? this.dueDate,
      dueLabel: dueLabel ?? this.dueLabel,
      isOverdue: isOverdue ?? this.isOverdue,
      hasAi: hasAi ?? this.hasAi,
      urgencyScore: urgencyScore ?? this.urgencyScore,
      recurrenceLabel: recurrenceLabel ?? this.recurrenceLabel,
      hasPomodoro: hasPomodoro ?? this.hasPomodoro,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      timeAllocatedMin: timeAllocatedMin ?? this.timeAllocatedMin,
      goalWeight: goalWeight ?? this.goalWeight,
      urgency: urgency ?? this.urgency,
      impact: impact ?? this.impact,
      focusFit: focusFit ?? this.focusFit,
      isDone: isDone ?? this.isDone,
      doneAt: doneAt ?? this.doneAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      labels: labels ?? this.labels,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (quadrant.present) {
      map['quadrant'] = Variable<int>(quadrant.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueLabel.present) {
      map['due_label'] = Variable<String>(dueLabel.value);
    }
    if (isOverdue.present) {
      map['is_overdue'] = Variable<bool>(isOverdue.value);
    }
    if (hasAi.present) {
      map['has_ai'] = Variable<bool>(hasAi.value);
    }
    if (urgencyScore.present) {
      map['urgency_score'] = Variable<double>(urgencyScore.value);
    }
    if (recurrenceLabel.present) {
      map['recurrence_label'] = Variable<String>(recurrenceLabel.value);
    }
    if (hasPomodoro.present) {
      map['has_pomodoro'] = Variable<bool>(hasPomodoro.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (timeAllocatedMin.present) {
      map['time_allocated_min'] = Variable<int>(timeAllocatedMin.value);
    }
    if (goalWeight.present) {
      map['goal_weight'] = Variable<double>(goalWeight.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<double>(urgency.value);
    }
    if (impact.present) {
      map['impact'] = Variable<double>(impact.value);
    }
    if (focusFit.present) {
      map['focus_fit'] = Variable<double>(focusFit.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (totalFocusSeconds.present) {
      map['total_focus_seconds'] = Variable<int>(totalFocusSeconds.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quadrant: $quadrant, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueLabel: $dueLabel, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('hasAi: $hasAi, ')
          ..write('urgencyScore: $urgencyScore, ')
          ..write('recurrenceLabel: $recurrenceLabel, ')
          ..write('hasPomodoro: $hasPomodoro, ')
          ..write('priority: $priority, ')
          ..write('notes: $notes, ')
          ..write('timeAllocatedMin: $timeAllocatedMin, ')
          ..write('goalWeight: $goalWeight, ')
          ..write('urgency: $urgency, ')
          ..write('impact: $impact, ')
          ..write('focusFit: $focusFit, ')
          ..write('isDone: $isDone, ')
          ..write('doneAt: $doneAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('labels: $labels')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, isDone, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class Subtask extends DataClass implements Insertable<Subtask> {
  final int id;
  final int taskId;
  final String title;
  final bool isDone;
  final int sortOrder;
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isDone,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['title'] = Variable<String>(title);
    map['is_done'] = Variable<bool>(isDone);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isDone: Value(isDone),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtask(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'title': serializer.toJson<String>(title),
      'isDone': serializer.toJson<bool>(isDone),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subtask copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isDone,
    int? sortOrder,
  }) => Subtask(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Subtask copyWithCompanion(SubtasksCompanion data) {
    return Subtask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, isDone, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isDone == this.isDone &&
          other.sortOrder == this.sortOrder);
}

class SubtasksCompanion extends UpdateCompanion<Subtask> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> title;
  final Value<bool> isDone;
  final Value<int> sortOrder;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubtasksCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String title,
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title);
  static Insertable<Subtask> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? title,
    Expression<bool>? isDone,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isDone != null) 'is_done': isDone,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubtasksCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? title,
    Value<bool>? isDone,
    Value<int>? sortOrder,
  }) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyLabelMeta = const VerificationMeta(
    'frequencyLabel',
  );
  @override
  late final GeneratedColumn<String> frequencyLabel = GeneratedColumn<String>(
    'frequency_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<int> scheduledTime = GeneratedColumn<int>(
    'scheduled_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quadrantMeta = const VerificationMeta(
    'quadrant',
  );
  @override
  late final GeneratedColumn<int> quadrant = GeneratedColumn<int>(
    'quadrant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _streakLabelMeta = const VerificationMeta(
    'streakLabel',
  );
  @override
  late final GeneratedColumn<String> streakLabel = GeneratedColumn<String>(
    'streak_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakColorValueMeta = const VerificationMeta(
    'streakColorValue',
  );
  @override
  late final GeneratedColumn<int> streakColorValue = GeneratedColumn<int>(
    'streak_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentColorValueMeta = const VerificationMeta(
    'accentColorValue',
  );
  @override
  late final GeneratedColumn<int> accentColorValue = GeneratedColumn<int>(
    'accent_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyFilledCountMeta = const VerificationMeta(
    'weeklyFilledCount',
  );
  @override
  late final GeneratedColumn<int> weeklyFilledCount = GeneratedColumn<int>(
    'weekly_filled_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subLabelMeta = const VerificationMeta(
    'subLabel',
  );
  @override
  late final GeneratedColumn<String> subLabel = GeneratedColumn<String>(
    'sub_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCheckedDateMeta = const VerificationMeta(
    'lastCheckedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedDate =
      GeneratedColumn<DateTime>(
        'last_checked_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    emoji,
    name,
    frequencyLabel,
    durationMinutes,
    scheduledTime,
    quadrant,
    streakLabel,
    streakColorValue,
    accentColorValue,
    weeklyFilledCount,
    subLabel,
    notes,
    lastCheckedDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('frequency_label')) {
      context.handle(
        _frequencyLabelMeta,
        frequencyLabel.isAcceptableOrUnknown(
          data['frequency_label']!,
          _frequencyLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyLabelMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    }
    if (data.containsKey('quadrant')) {
      context.handle(
        _quadrantMeta,
        quadrant.isAcceptableOrUnknown(data['quadrant']!, _quadrantMeta),
      );
    }
    if (data.containsKey('streak_label')) {
      context.handle(
        _streakLabelMeta,
        streakLabel.isAcceptableOrUnknown(
          data['streak_label']!,
          _streakLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streakLabelMeta);
    }
    if (data.containsKey('streak_color_value')) {
      context.handle(
        _streakColorValueMeta,
        streakColorValue.isAcceptableOrUnknown(
          data['streak_color_value']!,
          _streakColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streakColorValueMeta);
    }
    if (data.containsKey('accent_color_value')) {
      context.handle(
        _accentColorValueMeta,
        accentColorValue.isAcceptableOrUnknown(
          data['accent_color_value']!,
          _accentColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentColorValueMeta);
    }
    if (data.containsKey('weekly_filled_count')) {
      context.handle(
        _weeklyFilledCountMeta,
        weeklyFilledCount.isAcceptableOrUnknown(
          data['weekly_filled_count']!,
          _weeklyFilledCountMeta,
        ),
      );
    }
    if (data.containsKey('sub_label')) {
      context.handle(
        _subLabelMeta,
        subLabel.isAcceptableOrUnknown(data['sub_label']!, _subLabelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('last_checked_date')) {
      context.handle(
        _lastCheckedDateMeta,
        lastCheckedDate.isAcceptableOrUnknown(
          data['last_checked_date']!,
          _lastCheckedDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      frequencyLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_label'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_time'],
      ),
      quadrant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quadrant'],
      )!,
      streakLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streak_label'],
      )!,
      streakColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_color_value'],
      )!,
      accentColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color_value'],
      )!,
      weeklyFilledCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_filled_count'],
      )!,
      subLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_label'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      lastCheckedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String emoji;
  final String name;
  final String frequencyLabel;
  final int? durationMinutes;
  final int? scheduledTime;
  final int quadrant;
  final String streakLabel;
  final int streakColorValue;
  final int accentColorValue;
  final int weeklyFilledCount;
  final String? subLabel;
  final String? notes;
  final DateTime? lastCheckedDate;
  final DateTime createdAt;
  const Habit({
    required this.id,
    required this.emoji,
    required this.name,
    required this.frequencyLabel,
    this.durationMinutes,
    this.scheduledTime,
    required this.quadrant,
    required this.streakLabel,
    required this.streakColorValue,
    required this.accentColorValue,
    required this.weeklyFilledCount,
    this.subLabel,
    this.notes,
    this.lastCheckedDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emoji'] = Variable<String>(emoji);
    map['name'] = Variable<String>(name);
    map['frequency_label'] = Variable<String>(frequencyLabel);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<int>(scheduledTime);
    }
    map['quadrant'] = Variable<int>(quadrant);
    map['streak_label'] = Variable<String>(streakLabel);
    map['streak_color_value'] = Variable<int>(streakColorValue);
    map['accent_color_value'] = Variable<int>(accentColorValue);
    map['weekly_filled_count'] = Variable<int>(weeklyFilledCount);
    if (!nullToAbsent || subLabel != null) {
      map['sub_label'] = Variable<String>(subLabel);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || lastCheckedDate != null) {
      map['last_checked_date'] = Variable<DateTime>(lastCheckedDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      emoji: Value(emoji),
      name: Value(name),
      frequencyLabel: Value(frequencyLabel),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      quadrant: Value(quadrant),
      streakLabel: Value(streakLabel),
      streakColorValue: Value(streakColorValue),
      accentColorValue: Value(accentColorValue),
      weeklyFilledCount: Value(weeklyFilledCount),
      subLabel: subLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(subLabel),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      lastCheckedDate: lastCheckedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedDate),
      createdAt: Value(createdAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      emoji: serializer.fromJson<String>(json['emoji']),
      name: serializer.fromJson<String>(json['name']),
      frequencyLabel: serializer.fromJson<String>(json['frequencyLabel']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      scheduledTime: serializer.fromJson<int?>(json['scheduledTime']),
      quadrant: serializer.fromJson<int>(json['quadrant']),
      streakLabel: serializer.fromJson<String>(json['streakLabel']),
      streakColorValue: serializer.fromJson<int>(json['streakColorValue']),
      accentColorValue: serializer.fromJson<int>(json['accentColorValue']),
      weeklyFilledCount: serializer.fromJson<int>(json['weeklyFilledCount']),
      subLabel: serializer.fromJson<String?>(json['subLabel']),
      notes: serializer.fromJson<String?>(json['notes']),
      lastCheckedDate: serializer.fromJson<DateTime?>(json['lastCheckedDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emoji': serializer.toJson<String>(emoji),
      'name': serializer.toJson<String>(name),
      'frequencyLabel': serializer.toJson<String>(frequencyLabel),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'scheduledTime': serializer.toJson<int?>(scheduledTime),
      'quadrant': serializer.toJson<int>(quadrant),
      'streakLabel': serializer.toJson<String>(streakLabel),
      'streakColorValue': serializer.toJson<int>(streakColorValue),
      'accentColorValue': serializer.toJson<int>(accentColorValue),
      'weeklyFilledCount': serializer.toJson<int>(weeklyFilledCount),
      'subLabel': serializer.toJson<String?>(subLabel),
      'notes': serializer.toJson<String?>(notes),
      'lastCheckedDate': serializer.toJson<DateTime?>(lastCheckedDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Habit copyWith({
    int? id,
    String? emoji,
    String? name,
    String? frequencyLabel,
    Value<int?> durationMinutes = const Value.absent(),
    Value<int?> scheduledTime = const Value.absent(),
    int? quadrant,
    String? streakLabel,
    int? streakColorValue,
    int? accentColorValue,
    int? weeklyFilledCount,
    Value<String?> subLabel = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> lastCheckedDate = const Value.absent(),
    DateTime? createdAt,
  }) => Habit(
    id: id ?? this.id,
    emoji: emoji ?? this.emoji,
    name: name ?? this.name,
    frequencyLabel: frequencyLabel ?? this.frequencyLabel,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    scheduledTime: scheduledTime.present
        ? scheduledTime.value
        : this.scheduledTime,
    quadrant: quadrant ?? this.quadrant,
    streakLabel: streakLabel ?? this.streakLabel,
    streakColorValue: streakColorValue ?? this.streakColorValue,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    weeklyFilledCount: weeklyFilledCount ?? this.weeklyFilledCount,
    subLabel: subLabel.present ? subLabel.value : this.subLabel,
    notes: notes.present ? notes.value : this.notes,
    lastCheckedDate: lastCheckedDate.present
        ? lastCheckedDate.value
        : this.lastCheckedDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      name: data.name.present ? data.name.value : this.name,
      frequencyLabel: data.frequencyLabel.present
          ? data.frequencyLabel.value
          : this.frequencyLabel,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      quadrant: data.quadrant.present ? data.quadrant.value : this.quadrant,
      streakLabel: data.streakLabel.present
          ? data.streakLabel.value
          : this.streakLabel,
      streakColorValue: data.streakColorValue.present
          ? data.streakColorValue.value
          : this.streakColorValue,
      accentColorValue: data.accentColorValue.present
          ? data.accentColorValue.value
          : this.accentColorValue,
      weeklyFilledCount: data.weeklyFilledCount.present
          ? data.weeklyFilledCount.value
          : this.weeklyFilledCount,
      subLabel: data.subLabel.present ? data.subLabel.value : this.subLabel,
      notes: data.notes.present ? data.notes.value : this.notes,
      lastCheckedDate: data.lastCheckedDate.present
          ? data.lastCheckedDate.value
          : this.lastCheckedDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('frequencyLabel: $frequencyLabel, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('quadrant: $quadrant, ')
          ..write('streakLabel: $streakLabel, ')
          ..write('streakColorValue: $streakColorValue, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('weeklyFilledCount: $weeklyFilledCount, ')
          ..write('subLabel: $subLabel, ')
          ..write('notes: $notes, ')
          ..write('lastCheckedDate: $lastCheckedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    emoji,
    name,
    frequencyLabel,
    durationMinutes,
    scheduledTime,
    quadrant,
    streakLabel,
    streakColorValue,
    accentColorValue,
    weeklyFilledCount,
    subLabel,
    notes,
    lastCheckedDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.emoji == this.emoji &&
          other.name == this.name &&
          other.frequencyLabel == this.frequencyLabel &&
          other.durationMinutes == this.durationMinutes &&
          other.scheduledTime == this.scheduledTime &&
          other.quadrant == this.quadrant &&
          other.streakLabel == this.streakLabel &&
          other.streakColorValue == this.streakColorValue &&
          other.accentColorValue == this.accentColorValue &&
          other.weeklyFilledCount == this.weeklyFilledCount &&
          other.subLabel == this.subLabel &&
          other.notes == this.notes &&
          other.lastCheckedDate == this.lastCheckedDate &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> emoji;
  final Value<String> name;
  final Value<String> frequencyLabel;
  final Value<int?> durationMinutes;
  final Value<int?> scheduledTime;
  final Value<int> quadrant;
  final Value<String> streakLabel;
  final Value<int> streakColorValue;
  final Value<int> accentColorValue;
  final Value<int> weeklyFilledCount;
  final Value<String?> subLabel;
  final Value<String?> notes;
  final Value<DateTime?> lastCheckedDate;
  final Value<DateTime> createdAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.emoji = const Value.absent(),
    this.name = const Value.absent(),
    this.frequencyLabel = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.quadrant = const Value.absent(),
    this.streakLabel = const Value.absent(),
    this.streakColorValue = const Value.absent(),
    this.accentColorValue = const Value.absent(),
    this.weeklyFilledCount = const Value.absent(),
    this.subLabel = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastCheckedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String emoji,
    required String name,
    required String frequencyLabel,
    this.durationMinutes = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.quadrant = const Value.absent(),
    required String streakLabel,
    required int streakColorValue,
    required int accentColorValue,
    this.weeklyFilledCount = const Value.absent(),
    this.subLabel = const Value.absent(),
    this.notes = const Value.absent(),
    this.lastCheckedDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : emoji = Value(emoji),
       name = Value(name),
       frequencyLabel = Value(frequencyLabel),
       streakLabel = Value(streakLabel),
       streakColorValue = Value(streakColorValue),
       accentColorValue = Value(accentColorValue);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? emoji,
    Expression<String>? name,
    Expression<String>? frequencyLabel,
    Expression<int>? durationMinutes,
    Expression<int>? scheduledTime,
    Expression<int>? quadrant,
    Expression<String>? streakLabel,
    Expression<int>? streakColorValue,
    Expression<int>? accentColorValue,
    Expression<int>? weeklyFilledCount,
    Expression<String>? subLabel,
    Expression<String>? notes,
    Expression<DateTime>? lastCheckedDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emoji != null) 'emoji': emoji,
      if (name != null) 'name': name,
      if (frequencyLabel != null) 'frequency_label': frequencyLabel,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (quadrant != null) 'quadrant': quadrant,
      if (streakLabel != null) 'streak_label': streakLabel,
      if (streakColorValue != null) 'streak_color_value': streakColorValue,
      if (accentColorValue != null) 'accent_color_value': accentColorValue,
      if (weeklyFilledCount != null) 'weekly_filled_count': weeklyFilledCount,
      if (subLabel != null) 'sub_label': subLabel,
      if (notes != null) 'notes': notes,
      if (lastCheckedDate != null) 'last_checked_date': lastCheckedDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? emoji,
    Value<String>? name,
    Value<String>? frequencyLabel,
    Value<int?>? durationMinutes,
    Value<int?>? scheduledTime,
    Value<int>? quadrant,
    Value<String>? streakLabel,
    Value<int>? streakColorValue,
    Value<int>? accentColorValue,
    Value<int>? weeklyFilledCount,
    Value<String?>? subLabel,
    Value<String?>? notes,
    Value<DateTime?>? lastCheckedDate,
    Value<DateTime>? createdAt,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      frequencyLabel: frequencyLabel ?? this.frequencyLabel,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      quadrant: quadrant ?? this.quadrant,
      streakLabel: streakLabel ?? this.streakLabel,
      streakColorValue: streakColorValue ?? this.streakColorValue,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      weeklyFilledCount: weeklyFilledCount ?? this.weeklyFilledCount,
      subLabel: subLabel ?? this.subLabel,
      notes: notes ?? this.notes,
      lastCheckedDate: lastCheckedDate ?? this.lastCheckedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (frequencyLabel.present) {
      map['frequency_label'] = Variable<String>(frequencyLabel.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<int>(scheduledTime.value);
    }
    if (quadrant.present) {
      map['quadrant'] = Variable<int>(quadrant.value);
    }
    if (streakLabel.present) {
      map['streak_label'] = Variable<String>(streakLabel.value);
    }
    if (streakColorValue.present) {
      map['streak_color_value'] = Variable<int>(streakColorValue.value);
    }
    if (accentColorValue.present) {
      map['accent_color_value'] = Variable<int>(accentColorValue.value);
    }
    if (weeklyFilledCount.present) {
      map['weekly_filled_count'] = Variable<int>(weeklyFilledCount.value);
    }
    if (subLabel.present) {
      map['sub_label'] = Variable<String>(subLabel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (lastCheckedDate.present) {
      map['last_checked_date'] = Variable<DateTime>(lastCheckedDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('name: $name, ')
          ..write('frequencyLabel: $frequencyLabel, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('quadrant: $quadrant, ')
          ..write('streakLabel: $streakLabel, ')
          ..write('streakColorValue: $streakColorValue, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('weeklyFilledCount: $weeklyFilledCount, ')
          ..write('subLabel: $subLabel, ')
          ..write('notes: $notes, ')
          ..write('lastCheckedDate: $lastCheckedDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubHabitsTable extends SubHabits
    with TableInfo<$SubHabitsTable, SubHabit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubHabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, title, isDone, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sub_habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubHabit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubHabit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubHabit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubHabitsTable createAlias(String alias) {
    return $SubHabitsTable(attachedDatabase, alias);
  }
}

class SubHabit extends DataClass implements Insertable<SubHabit> {
  final int id;
  final int habitId;
  final String title;
  final bool isDone;
  final int sortOrder;
  const SubHabit({
    required this.id,
    required this.habitId,
    required this.title,
    required this.isDone,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['title'] = Variable<String>(title);
    map['is_done'] = Variable<bool>(isDone);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubHabitsCompanion toCompanion(bool nullToAbsent) {
    return SubHabitsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      title: Value(title),
      isDone: Value(isDone),
      sortOrder: Value(sortOrder),
    );
  }

  factory SubHabit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubHabit(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      title: serializer.fromJson<String>(json['title']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'title': serializer.toJson<String>(title),
      'isDone': serializer.toJson<bool>(isDone),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SubHabit copyWith({
    int? id,
    int? habitId,
    String? title,
    bool? isDone,
    int? sortOrder,
  }) => SubHabit(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    title: title ?? this.title,
    isDone: isDone ?? this.isDone,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  SubHabit copyWithCompanion(SubHabitsCompanion data) {
    return SubHabit(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      title: data.title.present ? data.title.value : this.title,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubHabit(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, title, isDone, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubHabit &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.title == this.title &&
          other.isDone == this.isDone &&
          other.sortOrder == this.sortOrder);
}

class SubHabitsCompanion extends UpdateCompanion<SubHabit> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<String> title;
  final Value<bool> isDone;
  final Value<int> sortOrder;
  const SubHabitsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.title = const Value.absent(),
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubHabitsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required String title,
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : habitId = Value(habitId),
       title = Value(title);
  static Insertable<SubHabit> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<String>? title,
    Expression<bool>? isDone,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (title != null) 'title': title,
      if (isDone != null) 'is_done': isDone,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubHabitsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<String>? title,
    Value<bool>? isDone,
    Value<int>? sortOrder,
  }) {
    return SubHabitsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubHabitsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSkippedMeta = const VerificationMeta(
    'isSkipped',
  );
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
    'is_skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_skipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, logDate, isSkipped];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('is_skipped')) {
      context.handle(
        _isSkippedMeta,
        isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, logDate},
  ];
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}log_date'],
      )!,
      isSkipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_skipped'],
      )!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final int id;
  final int habitId;
  final DateTime logDate;
  final bool isSkipped;
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.logDate,
    required this.isSkipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['log_date'] = Variable<DateTime>(logDate);
    map['is_skipped'] = Variable<bool>(isSkipped);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      logDate: Value(logDate),
      isSkipped: Value(isSkipped),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'isSkipped': serializer.toJson<bool>(isSkipped),
    };
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? logDate,
    bool? isSkipped,
  }) => HabitLog(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    logDate: logDate ?? this.logDate,
    isSkipped: isSkipped ?? this.isSkipped,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('logDate: $logDate, ')
          ..write('isSkipped: $isSkipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, logDate, isSkipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.logDate == this.logDate &&
          other.isSkipped == this.isSkipped);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> logDate;
  final Value<bool> isSkipped;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.isSkipped = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime logDate,
    this.isSkipped = const Value.absent(),
  }) : habitId = Value(habitId),
       logDate = Value(logDate);
  static Insertable<HabitLog> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? logDate,
    Expression<bool>? isSkipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (logDate != null) 'log_date': logDate,
      if (isSkipped != null) 'is_skipped': isSkipped,
    });
  }

  HabitLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? logDate,
    Value<bool>? isSkipped,
  }) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      logDate: logDate ?? this.logDate,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('logDate: $logDate, ')
          ..write('isSkipped: $isSkipped')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiBgMeta = const VerificationMeta(
    'emojiBg',
  );
  @override
  late final GeneratedColumn<String> emojiBg = GeneratedColumn<String>(
    'emoji_bg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressPctMeta = const VerificationMeta(
    'progressPct',
  );
  @override
  late final GeneratedColumn<double> progressPct = GeneratedColumn<double>(
    'progress_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _accentColorValueMeta = const VerificationMeta(
    'accentColorValue',
  );
  @override
  late final GeneratedColumn<int> accentColorValue = GeneratedColumn<int>(
    'accent_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barColorValueMeta = const VerificationMeta(
    'barColorValue',
  );
  @override
  late final GeneratedColumn<int> barColorValue = GeneratedColumn<int>(
    'bar_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borderColorValueMeta = const VerificationMeta(
    'borderColorValue',
  );
  @override
  late final GeneratedColumn<int> borderColorValue = GeneratedColumn<int>(
    'border_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedLabelMeta = const VerificationMeta(
    'linkedLabel',
  );
  @override
  late final GeneratedColumn<String> linkedLabel = GeneratedColumn<String>(
    'linked_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkTypeMeta = const VerificationMeta(
    'linkType',
  );
  @override
  late final GeneratedColumn<String> linkType = GeneratedColumn<String>(
    'link_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('task'),
  );
  static const VerificationMeta _dotColorValueMeta = const VerificationMeta(
    'dotColorValue',
  );
  @override
  late final GeneratedColumn<int> dotColorValue = GeneratedColumn<int>(
    'dot_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _milestonesMeta = const VerificationMeta(
    'milestones',
  );
  @override
  late final GeneratedColumn<String> milestones = GeneratedColumn<String>(
    'milestones',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    emoji,
    emojiBg,
    title,
    subtitle,
    progressPct,
    accentColorValue,
    barColorValue,
    borderColorValue,
    linkedLabel,
    linkType,
    dotColorValue,
    createdAt,
    deadline,
    milestones,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('emoji_bg')) {
      context.handle(
        _emojiBgMeta,
        emojiBg.isAcceptableOrUnknown(data['emoji_bg']!, _emojiBgMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiBgMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('progress_pct')) {
      context.handle(
        _progressPctMeta,
        progressPct.isAcceptableOrUnknown(
          data['progress_pct']!,
          _progressPctMeta,
        ),
      );
    }
    if (data.containsKey('accent_color_value')) {
      context.handle(
        _accentColorValueMeta,
        accentColorValue.isAcceptableOrUnknown(
          data['accent_color_value']!,
          _accentColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentColorValueMeta);
    }
    if (data.containsKey('bar_color_value')) {
      context.handle(
        _barColorValueMeta,
        barColorValue.isAcceptableOrUnknown(
          data['bar_color_value']!,
          _barColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barColorValueMeta);
    }
    if (data.containsKey('border_color_value')) {
      context.handle(
        _borderColorValueMeta,
        borderColorValue.isAcceptableOrUnknown(
          data['border_color_value']!,
          _borderColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borderColorValueMeta);
    }
    if (data.containsKey('linked_label')) {
      context.handle(
        _linkedLabelMeta,
        linkedLabel.isAcceptableOrUnknown(
          data['linked_label']!,
          _linkedLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_linkedLabelMeta);
    }
    if (data.containsKey('link_type')) {
      context.handle(
        _linkTypeMeta,
        linkType.isAcceptableOrUnknown(data['link_type']!, _linkTypeMeta),
      );
    }
    if (data.containsKey('dot_color_value')) {
      context.handle(
        _dotColorValueMeta,
        dotColorValue.isAcceptableOrUnknown(
          data['dot_color_value']!,
          _dotColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dotColorValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('milestones')) {
      context.handle(
        _milestonesMeta,
        milestones.isAcceptableOrUnknown(data['milestones']!, _milestonesMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      emojiBg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji_bg'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      progressPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress_pct'],
      )!,
      accentColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color_value'],
      )!,
      barColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bar_color_value'],
      )!,
      borderColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}border_color_value'],
      )!,
      linkedLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_label'],
      )!,
      linkType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link_type'],
      )!,
      dotColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dot_color_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      milestones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestones'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String emoji;
  final String emojiBg;
  final String title;
  final String subtitle;
  final double progressPct;
  final int accentColorValue;
  final int barColorValue;
  final int borderColorValue;
  final String linkedLabel;
  final String linkType;
  final int dotColorValue;
  final DateTime createdAt;
  final DateTime? deadline;
  final String milestones;
  final String? notes;
  const Goal({
    required this.id,
    required this.emoji,
    required this.emojiBg,
    required this.title,
    required this.subtitle,
    required this.progressPct,
    required this.accentColorValue,
    required this.barColorValue,
    required this.borderColorValue,
    required this.linkedLabel,
    required this.linkType,
    required this.dotColorValue,
    required this.createdAt,
    this.deadline,
    required this.milestones,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['emoji'] = Variable<String>(emoji);
    map['emoji_bg'] = Variable<String>(emojiBg);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['progress_pct'] = Variable<double>(progressPct);
    map['accent_color_value'] = Variable<int>(accentColorValue);
    map['bar_color_value'] = Variable<int>(barColorValue);
    map['border_color_value'] = Variable<int>(borderColorValue);
    map['linked_label'] = Variable<String>(linkedLabel);
    map['link_type'] = Variable<String>(linkType);
    map['dot_color_value'] = Variable<int>(dotColorValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['milestones'] = Variable<String>(milestones);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      emoji: Value(emoji),
      emojiBg: Value(emojiBg),
      title: Value(title),
      subtitle: Value(subtitle),
      progressPct: Value(progressPct),
      accentColorValue: Value(accentColorValue),
      barColorValue: Value(barColorValue),
      borderColorValue: Value(borderColorValue),
      linkedLabel: Value(linkedLabel),
      linkType: Value(linkType),
      dotColorValue: Value(dotColorValue),
      createdAt: Value(createdAt),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      milestones: Value(milestones),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      emoji: serializer.fromJson<String>(json['emoji']),
      emojiBg: serializer.fromJson<String>(json['emojiBg']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      progressPct: serializer.fromJson<double>(json['progressPct']),
      accentColorValue: serializer.fromJson<int>(json['accentColorValue']),
      barColorValue: serializer.fromJson<int>(json['barColorValue']),
      borderColorValue: serializer.fromJson<int>(json['borderColorValue']),
      linkedLabel: serializer.fromJson<String>(json['linkedLabel']),
      linkType: serializer.fromJson<String>(json['linkType']),
      dotColorValue: serializer.fromJson<int>(json['dotColorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      milestones: serializer.fromJson<String>(json['milestones']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'emoji': serializer.toJson<String>(emoji),
      'emojiBg': serializer.toJson<String>(emojiBg),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'progressPct': serializer.toJson<double>(progressPct),
      'accentColorValue': serializer.toJson<int>(accentColorValue),
      'barColorValue': serializer.toJson<int>(barColorValue),
      'borderColorValue': serializer.toJson<int>(borderColorValue),
      'linkedLabel': serializer.toJson<String>(linkedLabel),
      'linkType': serializer.toJson<String>(linkType),
      'dotColorValue': serializer.toJson<int>(dotColorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'milestones': serializer.toJson<String>(milestones),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Goal copyWith({
    int? id,
    String? emoji,
    String? emojiBg,
    String? title,
    String? subtitle,
    double? progressPct,
    int? accentColorValue,
    int? barColorValue,
    int? borderColorValue,
    String? linkedLabel,
    String? linkType,
    int? dotColorValue,
    DateTime? createdAt,
    Value<DateTime?> deadline = const Value.absent(),
    String? milestones,
    Value<String?> notes = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    emoji: emoji ?? this.emoji,
    emojiBg: emojiBg ?? this.emojiBg,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    progressPct: progressPct ?? this.progressPct,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    barColorValue: barColorValue ?? this.barColorValue,
    borderColorValue: borderColorValue ?? this.borderColorValue,
    linkedLabel: linkedLabel ?? this.linkedLabel,
    linkType: linkType ?? this.linkType,
    dotColorValue: dotColorValue ?? this.dotColorValue,
    createdAt: createdAt ?? this.createdAt,
    deadline: deadline.present ? deadline.value : this.deadline,
    milestones: milestones ?? this.milestones,
    notes: notes.present ? notes.value : this.notes,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      emojiBg: data.emojiBg.present ? data.emojiBg.value : this.emojiBg,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      progressPct: data.progressPct.present
          ? data.progressPct.value
          : this.progressPct,
      accentColorValue: data.accentColorValue.present
          ? data.accentColorValue.value
          : this.accentColorValue,
      barColorValue: data.barColorValue.present
          ? data.barColorValue.value
          : this.barColorValue,
      borderColorValue: data.borderColorValue.present
          ? data.borderColorValue.value
          : this.borderColorValue,
      linkedLabel: data.linkedLabel.present
          ? data.linkedLabel.value
          : this.linkedLabel,
      linkType: data.linkType.present ? data.linkType.value : this.linkType,
      dotColorValue: data.dotColorValue.present
          ? data.dotColorValue.value
          : this.dotColorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      milestones: data.milestones.present
          ? data.milestones.value
          : this.milestones,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('emojiBg: $emojiBg, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('progressPct: $progressPct, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('barColorValue: $barColorValue, ')
          ..write('borderColorValue: $borderColorValue, ')
          ..write('linkedLabel: $linkedLabel, ')
          ..write('linkType: $linkType, ')
          ..write('dotColorValue: $dotColorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('deadline: $deadline, ')
          ..write('milestones: $milestones, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    emoji,
    emojiBg,
    title,
    subtitle,
    progressPct,
    accentColorValue,
    barColorValue,
    borderColorValue,
    linkedLabel,
    linkType,
    dotColorValue,
    createdAt,
    deadline,
    milestones,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.emoji == this.emoji &&
          other.emojiBg == this.emojiBg &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.progressPct == this.progressPct &&
          other.accentColorValue == this.accentColorValue &&
          other.barColorValue == this.barColorValue &&
          other.borderColorValue == this.borderColorValue &&
          other.linkedLabel == this.linkedLabel &&
          other.linkType == this.linkType &&
          other.dotColorValue == this.dotColorValue &&
          other.createdAt == this.createdAt &&
          other.deadline == this.deadline &&
          other.milestones == this.milestones &&
          other.notes == this.notes);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> emoji;
  final Value<String> emojiBg;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<double> progressPct;
  final Value<int> accentColorValue;
  final Value<int> barColorValue;
  final Value<int> borderColorValue;
  final Value<String> linkedLabel;
  final Value<String> linkType;
  final Value<int> dotColorValue;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deadline;
  final Value<String> milestones;
  final Value<String?> notes;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.emoji = const Value.absent(),
    this.emojiBg = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.progressPct = const Value.absent(),
    this.accentColorValue = const Value.absent(),
    this.barColorValue = const Value.absent(),
    this.borderColorValue = const Value.absent(),
    this.linkedLabel = const Value.absent(),
    this.linkType = const Value.absent(),
    this.dotColorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deadline = const Value.absent(),
    this.milestones = const Value.absent(),
    this.notes = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String emoji,
    required String emojiBg,
    required String title,
    required String subtitle,
    this.progressPct = const Value.absent(),
    required int accentColorValue,
    required int barColorValue,
    required int borderColorValue,
    required String linkedLabel,
    this.linkType = const Value.absent(),
    required int dotColorValue,
    this.createdAt = const Value.absent(),
    this.deadline = const Value.absent(),
    this.milestones = const Value.absent(),
    this.notes = const Value.absent(),
  }) : emoji = Value(emoji),
       emojiBg = Value(emojiBg),
       title = Value(title),
       subtitle = Value(subtitle),
       accentColorValue = Value(accentColorValue),
       barColorValue = Value(barColorValue),
       borderColorValue = Value(borderColorValue),
       linkedLabel = Value(linkedLabel),
       dotColorValue = Value(dotColorValue);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? emoji,
    Expression<String>? emojiBg,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<double>? progressPct,
    Expression<int>? accentColorValue,
    Expression<int>? barColorValue,
    Expression<int>? borderColorValue,
    Expression<String>? linkedLabel,
    Expression<String>? linkType,
    Expression<int>? dotColorValue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deadline,
    Expression<String>? milestones,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emoji != null) 'emoji': emoji,
      if (emojiBg != null) 'emoji_bg': emojiBg,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (progressPct != null) 'progress_pct': progressPct,
      if (accentColorValue != null) 'accent_color_value': accentColorValue,
      if (barColorValue != null) 'bar_color_value': barColorValue,
      if (borderColorValue != null) 'border_color_value': borderColorValue,
      if (linkedLabel != null) 'linked_label': linkedLabel,
      if (linkType != null) 'link_type': linkType,
      if (dotColorValue != null) 'dot_color_value': dotColorValue,
      if (createdAt != null) 'created_at': createdAt,
      if (deadline != null) 'deadline': deadline,
      if (milestones != null) 'milestones': milestones,
      if (notes != null) 'notes': notes,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? emoji,
    Value<String>? emojiBg,
    Value<String>? title,
    Value<String>? subtitle,
    Value<double>? progressPct,
    Value<int>? accentColorValue,
    Value<int>? barColorValue,
    Value<int>? borderColorValue,
    Value<String>? linkedLabel,
    Value<String>? linkType,
    Value<int>? dotColorValue,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deadline,
    Value<String>? milestones,
    Value<String?>? notes,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      emojiBg: emojiBg ?? this.emojiBg,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      progressPct: progressPct ?? this.progressPct,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      barColorValue: barColorValue ?? this.barColorValue,
      borderColorValue: borderColorValue ?? this.borderColorValue,
      linkedLabel: linkedLabel ?? this.linkedLabel,
      linkType: linkType ?? this.linkType,
      dotColorValue: dotColorValue ?? this.dotColorValue,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      milestones: milestones ?? this.milestones,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (emojiBg.present) {
      map['emoji_bg'] = Variable<String>(emojiBg.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (progressPct.present) {
      map['progress_pct'] = Variable<double>(progressPct.value);
    }
    if (accentColorValue.present) {
      map['accent_color_value'] = Variable<int>(accentColorValue.value);
    }
    if (barColorValue.present) {
      map['bar_color_value'] = Variable<int>(barColorValue.value);
    }
    if (borderColorValue.present) {
      map['border_color_value'] = Variable<int>(borderColorValue.value);
    }
    if (linkedLabel.present) {
      map['linked_label'] = Variable<String>(linkedLabel.value);
    }
    if (linkType.present) {
      map['link_type'] = Variable<String>(linkType.value);
    }
    if (dotColorValue.present) {
      map['dot_color_value'] = Variable<int>(dotColorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (milestones.present) {
      map['milestones'] = Variable<String>(milestones.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('emoji: $emoji, ')
          ..write('emojiBg: $emojiBg, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('progressPct: $progressPct, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('barColorValue: $barColorValue, ')
          ..write('borderColorValue: $borderColorValue, ')
          ..write('linkedLabel: $linkedLabel, ')
          ..write('linkType: $linkType, ')
          ..write('dotColorValue: $dotColorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('deadline: $deadline, ')
          ..write('milestones: $milestones, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $GoalTaskLinksTable extends GoalTaskLinks
    with TableInfo<$GoalTaskLinksTable, GoalTaskLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalTaskLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [goalId, taskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_task_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalTaskLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, taskId};
  @override
  GoalTaskLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalTaskLink(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
    );
  }

  @override
  $GoalTaskLinksTable createAlias(String alias) {
    return $GoalTaskLinksTable(attachedDatabase, alias);
  }
}

class GoalTaskLink extends DataClass implements Insertable<GoalTaskLink> {
  final int goalId;
  final int taskId;
  const GoalTaskLink({required this.goalId, required this.taskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<int>(goalId);
    map['task_id'] = Variable<int>(taskId);
    return map;
  }

  GoalTaskLinksCompanion toCompanion(bool nullToAbsent) {
    return GoalTaskLinksCompanion(goalId: Value(goalId), taskId: Value(taskId));
  }

  factory GoalTaskLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalTaskLink(
      goalId: serializer.fromJson<int>(json['goalId']),
      taskId: serializer.fromJson<int>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<int>(goalId),
      'taskId': serializer.toJson<int>(taskId),
    };
  }

  GoalTaskLink copyWith({int? goalId, int? taskId}) => GoalTaskLink(
    goalId: goalId ?? this.goalId,
    taskId: taskId ?? this.taskId,
  );
  GoalTaskLink copyWithCompanion(GoalTaskLinksCompanion data) {
    return GoalTaskLink(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalTaskLink(')
          ..write('goalId: $goalId, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalId, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalTaskLink &&
          other.goalId == this.goalId &&
          other.taskId == this.taskId);
}

class GoalTaskLinksCompanion extends UpdateCompanion<GoalTaskLink> {
  final Value<int> goalId;
  final Value<int> taskId;
  final Value<int> rowid;
  const GoalTaskLinksCompanion({
    this.goalId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalTaskLinksCompanion.insert({
    required int goalId,
    required int taskId,
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       taskId = Value(taskId);
  static Insertable<GoalTaskLink> custom({
    Expression<int>? goalId,
    Expression<int>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalTaskLinksCompanion copyWith({
    Value<int>? goalId,
    Value<int>? taskId,
    Value<int>? rowid,
  }) {
    return GoalTaskLinksCompanion(
      goalId: goalId ?? this.goalId,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalTaskLinksCompanion(')
          ..write('goalId: $goalId, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalHabitLinksTable extends GoalHabitLinks
    with TableInfo<$GoalHabitLinksTable, GoalHabitLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalHabitLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [goalId, habitId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_habit_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalHabitLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, habitId};
  @override
  GoalHabitLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalHabitLink(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
    );
  }

  @override
  $GoalHabitLinksTable createAlias(String alias) {
    return $GoalHabitLinksTable(attachedDatabase, alias);
  }
}

class GoalHabitLink extends DataClass implements Insertable<GoalHabitLink> {
  final int goalId;
  final int habitId;
  const GoalHabitLink({required this.goalId, required this.habitId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<int>(goalId);
    map['habit_id'] = Variable<int>(habitId);
    return map;
  }

  GoalHabitLinksCompanion toCompanion(bool nullToAbsent) {
    return GoalHabitLinksCompanion(
      goalId: Value(goalId),
      habitId: Value(habitId),
    );
  }

  factory GoalHabitLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalHabitLink(
      goalId: serializer.fromJson<int>(json['goalId']),
      habitId: serializer.fromJson<int>(json['habitId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<int>(goalId),
      'habitId': serializer.toJson<int>(habitId),
    };
  }

  GoalHabitLink copyWith({int? goalId, int? habitId}) => GoalHabitLink(
    goalId: goalId ?? this.goalId,
    habitId: habitId ?? this.habitId,
  );
  GoalHabitLink copyWithCompanion(GoalHabitLinksCompanion data) {
    return GoalHabitLink(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalHabitLink(')
          ..write('goalId: $goalId, ')
          ..write('habitId: $habitId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalId, habitId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalHabitLink &&
          other.goalId == this.goalId &&
          other.habitId == this.habitId);
}

class GoalHabitLinksCompanion extends UpdateCompanion<GoalHabitLink> {
  final Value<int> goalId;
  final Value<int> habitId;
  final Value<int> rowid;
  const GoalHabitLinksCompanion({
    this.goalId = const Value.absent(),
    this.habitId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalHabitLinksCompanion.insert({
    required int goalId,
    required int habitId,
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       habitId = Value(habitId);
  static Insertable<GoalHabitLink> custom({
    Expression<int>? goalId,
    Expression<int>? habitId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (habitId != null) 'habit_id': habitId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalHabitLinksCompanion copyWith({
    Value<int>? goalId,
    Value<int>? habitId,
    Value<int>? rowid,
  }) {
    return GoalHabitLinksCompanion(
      goalId: goalId ?? this.goalId,
      habitId: habitId ?? this.habitId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalHabitLinksCompanion(')
          ..write('goalId: $goalId, ')
          ..write('habitId: $habitId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aiLabelMeta = const VerificationMeta(
    'aiLabel',
  );
  @override
  late final GeneratedColumn<String> aiLabel = GeneratedColumn<String>(
    'ai_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeLabelMeta = const VerificationMeta(
    'timeLabel',
  );
  @override
  late final GeneratedColumn<String> timeLabel = GeneratedColumn<String>(
    'time_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    isPinned,
    aiLabel,
    timeLabel,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('ai_label')) {
      context.handle(
        _aiLabelMeta,
        aiLabel.isAcceptableOrUnknown(data['ai_label']!, _aiLabelMeta),
      );
    }
    if (data.containsKey('time_label')) {
      context.handle(
        _timeLabelMeta,
        timeLabel.isAcceptableOrUnknown(data['time_label']!, _timeLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_timeLabelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      aiLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_label'],
      ),
      timeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String title;
  final String body;
  final bool isPinned;
  final String? aiLabel;
  final String timeLabel;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.isPinned,
    this.aiLabel,
    required this.timeLabel,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['is_pinned'] = Variable<bool>(isPinned);
    if (!nullToAbsent || aiLabel != null) {
      map['ai_label'] = Variable<String>(aiLabel);
    }
    map['time_label'] = Variable<String>(timeLabel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      isPinned: Value(isPinned),
      aiLabel: aiLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(aiLabel),
      timeLabel: Value(timeLabel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      aiLabel: serializer.fromJson<String?>(json['aiLabel']),
      timeLabel: serializer.fromJson<String>(json['timeLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'isPinned': serializer.toJson<bool>(isPinned),
      'aiLabel': serializer.toJson<String?>(aiLabel),
      'timeLabel': serializer.toJson<String>(timeLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? body,
    bool? isPinned,
    Value<String?> aiLabel = const Value.absent(),
    String? timeLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    isPinned: isPinned ?? this.isPinned,
    aiLabel: aiLabel.present ? aiLabel.value : this.aiLabel,
    timeLabel: timeLabel ?? this.timeLabel,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      aiLabel: data.aiLabel.present ? data.aiLabel.value : this.aiLabel,
      timeLabel: data.timeLabel.present ? data.timeLabel.value : this.timeLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isPinned: $isPinned, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    body,
    isPinned,
    aiLabel,
    timeLabel,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.isPinned == this.isPinned &&
          other.aiLabel == this.aiLabel &&
          other.timeLabel == this.timeLabel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<bool> isPinned;
  final Value<String?> aiLabel;
  final Value<String> timeLabel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.aiLabel = const Value.absent(),
    this.timeLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.body = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.aiLabel = const Value.absent(),
    required String timeLabel,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       timeLabel = Value(timeLabel);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? isPinned,
    Expression<String>? aiLabel,
    Expression<String>? timeLabel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (isPinned != null) 'is_pinned': isPinned,
      if (aiLabel != null) 'ai_label': aiLabel,
      if (timeLabel != null) 'time_label': timeLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<bool>? isPinned,
    Value<String?>? aiLabel,
    Value<String>? timeLabel,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isPinned: isPinned ?? this.isPinned,
      aiLabel: aiLabel ?? this.aiLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (aiLabel.present) {
      map['ai_label'] = Variable<String>(aiLabel.value);
    }
    if (timeLabel.present) {
      map['time_label'] = Variable<String>(timeLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isPinned: $isPinned, ')
          ..write('aiLabel: $aiLabel, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags with TableInfo<$NoteTagsTable, NoteTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bgColorValueMeta = const VerificationMeta(
    'bgColorValue',
  );
  @override
  late final GeneratedColumn<int> bgColorValue = GeneratedColumn<int>(
    'bg_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fgColorValueMeta = const VerificationMeta(
    'fgColorValue',
  );
  @override
  late final GeneratedColumn<int> fgColorValue = GeneratedColumn<int>(
    'fg_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    label,
    bgColorValue,
    fgColorValue,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('bg_color_value')) {
      context.handle(
        _bgColorValueMeta,
        bgColorValue.isAcceptableOrUnknown(
          data['bg_color_value']!,
          _bgColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bgColorValueMeta);
    }
    if (data.containsKey('fg_color_value')) {
      context.handle(
        _fgColorValueMeta,
        fgColorValue.isAcceptableOrUnknown(
          data['fg_color_value']!,
          _fgColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fgColorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      bgColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bg_color_value'],
      )!,
      fgColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fg_color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTag extends DataClass implements Insertable<NoteTag> {
  final int id;
  final int noteId;
  final String label;
  final int bgColorValue;
  final int fgColorValue;
  final int sortOrder;
  const NoteTag({
    required this.id,
    required this.noteId,
    required this.label,
    required this.bgColorValue,
    required this.fgColorValue,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note_id'] = Variable<int>(noteId);
    map['label'] = Variable<String>(label);
    map['bg_color_value'] = Variable<int>(bgColorValue);
    map['fg_color_value'] = Variable<int>(fgColorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      label: Value(label),
      bgColorValue: Value(bgColorValue),
      fgColorValue: Value(fgColorValue),
      sortOrder: Value(sortOrder),
    );
  }

  factory NoteTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTag(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<int>(json['noteId']),
      label: serializer.fromJson<String>(json['label']),
      bgColorValue: serializer.fromJson<int>(json['bgColorValue']),
      fgColorValue: serializer.fromJson<int>(json['fgColorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<int>(noteId),
      'label': serializer.toJson<String>(label),
      'bgColorValue': serializer.toJson<int>(bgColorValue),
      'fgColorValue': serializer.toJson<int>(fgColorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  NoteTag copyWith({
    int? id,
    int? noteId,
    String? label,
    int? bgColorValue,
    int? fgColorValue,
    int? sortOrder,
  }) => NoteTag(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    label: label ?? this.label,
    bgColorValue: bgColorValue ?? this.bgColorValue,
    fgColorValue: fgColorValue ?? this.fgColorValue,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  NoteTag copyWithCompanion(NoteTagsCompanion data) {
    return NoteTag(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      label: data.label.present ? data.label.value : this.label,
      bgColorValue: data.bgColorValue.present
          ? data.bgColorValue.value
          : this.bgColorValue,
      fgColorValue: data.fgColorValue.present
          ? data.fgColorValue.value
          : this.fgColorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTag(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('label: $label, ')
          ..write('bgColorValue: $bgColorValue, ')
          ..write('fgColorValue: $fgColorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, noteId, label, bgColorValue, fgColorValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTag &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.label == this.label &&
          other.bgColorValue == this.bgColorValue &&
          other.fgColorValue == this.fgColorValue &&
          other.sortOrder == this.sortOrder);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTag> {
  final Value<int> id;
  final Value<int> noteId;
  final Value<String> label;
  final Value<int> bgColorValue;
  final Value<int> fgColorValue;
  final Value<int> sortOrder;
  const NoteTagsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.label = const Value.absent(),
    this.bgColorValue = const Value.absent(),
    this.fgColorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    this.id = const Value.absent(),
    required int noteId,
    required String label,
    required int bgColorValue,
    required int fgColorValue,
    this.sortOrder = const Value.absent(),
  }) : noteId = Value(noteId),
       label = Value(label),
       bgColorValue = Value(bgColorValue),
       fgColorValue = Value(fgColorValue);
  static Insertable<NoteTag> custom({
    Expression<int>? id,
    Expression<int>? noteId,
    Expression<String>? label,
    Expression<int>? bgColorValue,
    Expression<int>? fgColorValue,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (label != null) 'label': label,
      if (bgColorValue != null) 'bg_color_value': bgColorValue,
      if (fgColorValue != null) 'fg_color_value': fgColorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  NoteTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? noteId,
    Value<String>? label,
    Value<int>? bgColorValue,
    Value<int>? fgColorValue,
    Value<int>? sortOrder,
  }) {
    return NoteTagsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      label: label ?? this.label,
      bgColorValue: bgColorValue ?? this.bgColorValue,
      fgColorValue: fgColorValue ?? this.fgColorValue,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (bgColorValue.present) {
      map['bg_color_value'] = Variable<int>(bgColorValue.value);
    }
    if (fgColorValue.present) {
      map['fg_color_value'] = Variable<int>(fgColorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('label: $label, ')
          ..write('bgColorValue: $bgColorValue, ')
          ..write('fgColorValue: $fgColorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $NoteTaskLinksTable extends NoteTaskLinks
    with TableInfo<$NoteTaskLinksTable, NoteTaskLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTaskLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, taskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_task_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTaskLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, taskId};
  @override
  NoteTaskLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTaskLink(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
    );
  }

  @override
  $NoteTaskLinksTable createAlias(String alias) {
    return $NoteTaskLinksTable(attachedDatabase, alias);
  }
}

class NoteTaskLink extends DataClass implements Insertable<NoteTaskLink> {
  final int noteId;
  final int taskId;
  const NoteTaskLink({required this.noteId, required this.taskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<int>(noteId);
    map['task_id'] = Variable<int>(taskId);
    return map;
  }

  NoteTaskLinksCompanion toCompanion(bool nullToAbsent) {
    return NoteTaskLinksCompanion(noteId: Value(noteId), taskId: Value(taskId));
  }

  factory NoteTaskLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTaskLink(
      noteId: serializer.fromJson<int>(json['noteId']),
      taskId: serializer.fromJson<int>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<int>(noteId),
      'taskId': serializer.toJson<int>(taskId),
    };
  }

  NoteTaskLink copyWith({int? noteId, int? taskId}) => NoteTaskLink(
    noteId: noteId ?? this.noteId,
    taskId: taskId ?? this.taskId,
  );
  NoteTaskLink copyWithCompanion(NoteTaskLinksCompanion data) {
    return NoteTaskLink(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTaskLink(')
          ..write('noteId: $noteId, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTaskLink &&
          other.noteId == this.noteId &&
          other.taskId == this.taskId);
}

class NoteTaskLinksCompanion extends UpdateCompanion<NoteTaskLink> {
  final Value<int> noteId;
  final Value<int> taskId;
  final Value<int> rowid;
  const NoteTaskLinksCompanion({
    this.noteId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTaskLinksCompanion.insert({
    required int noteId,
    required int taskId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       taskId = Value(taskId);
  static Insertable<NoteTaskLink> custom({
    Expression<int>? noteId,
    Expression<int>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTaskLinksCompanion copyWith({
    Value<int>? noteId,
    Value<int>? taskId,
    Value<int>? rowid,
  }) {
    return NoteTaskLinksCompanion(
      noteId: noteId ?? this.noteId,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTaskLinksCompanion(')
          ..write('noteId: $noteId, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _timeSlotMeta = const VerificationMeta(
    'timeSlot',
  );
  @override
  late final GeneratedColumn<String> timeSlot = GeneratedColumn<String>(
    'time_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOverdueMeta = const VerificationMeta(
    'isOverdue',
  );
  @override
  late final GeneratedColumn<bool> isOverdue = GeneratedColumn<bool>(
    'is_overdue',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_overdue" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isInviteMeta = const VerificationMeta(
    'isInvite',
  );
  @override
  late final GeneratedColumn<bool> isInvite = GeneratedColumn<bool>(
    'is_invite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_invite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    timeSlot,
    colorValue,
    isOverdue,
    isInvite,
    eventDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('time_slot')) {
      context.handle(
        _timeSlotMeta,
        timeSlot.isAcceptableOrUnknown(data['time_slot']!, _timeSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSlotMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_overdue')) {
      context.handle(
        _isOverdueMeta,
        isOverdue.isAcceptableOrUnknown(data['is_overdue']!, _isOverdueMeta),
      );
    }
    if (data.containsKey('is_invite')) {
      context.handle(
        _isInviteMeta,
        isInvite.isAcceptableOrUnknown(data['is_invite']!, _isInviteMeta),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      timeSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_slot'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      isOverdue: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_overdue'],
      )!,
      isInvite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_invite'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final int id;
  final String title;
  final String subtitle;
  final String timeSlot;
  final int colorValue;
  final bool isOverdue;
  final bool isInvite;
  final DateTime? eventDate;
  final DateTime createdAt;
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeSlot,
    required this.colorValue,
    required this.isOverdue,
    required this.isInvite,
    this.eventDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['time_slot'] = Variable<String>(timeSlot);
    map['color_value'] = Variable<int>(colorValue);
    map['is_overdue'] = Variable<bool>(isOverdue);
    map['is_invite'] = Variable<bool>(isInvite);
    if (!nullToAbsent || eventDate != null) {
      map['event_date'] = Variable<DateTime>(eventDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      timeSlot: Value(timeSlot),
      colorValue: Value(colorValue),
      isOverdue: Value(isOverdue),
      isInvite: Value(isInvite),
      eventDate: eventDate == null && nullToAbsent
          ? const Value.absent()
          : Value(eventDate),
      createdAt: Value(createdAt),
    );
  }

  factory CalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      timeSlot: serializer.fromJson<String>(json['timeSlot']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isOverdue: serializer.fromJson<bool>(json['isOverdue']),
      isInvite: serializer.fromJson<bool>(json['isInvite']),
      eventDate: serializer.fromJson<DateTime?>(json['eventDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'timeSlot': serializer.toJson<String>(timeSlot),
      'colorValue': serializer.toJson<int>(colorValue),
      'isOverdue': serializer.toJson<bool>(isOverdue),
      'isInvite': serializer.toJson<bool>(isInvite),
      'eventDate': serializer.toJson<DateTime?>(eventDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CalendarEvent copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? timeSlot,
    int? colorValue,
    bool? isOverdue,
    bool? isInvite,
    Value<DateTime?> eventDate = const Value.absent(),
    DateTime? createdAt,
  }) => CalendarEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    timeSlot: timeSlot ?? this.timeSlot,
    colorValue: colorValue ?? this.colorValue,
    isOverdue: isOverdue ?? this.isOverdue,
    isInvite: isInvite ?? this.isInvite,
    eventDate: eventDate.present ? eventDate.value : this.eventDate,
    createdAt: createdAt ?? this.createdAt,
  );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      timeSlot: data.timeSlot.present ? data.timeSlot.value : this.timeSlot,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isOverdue: data.isOverdue.present ? data.isOverdue.value : this.isOverdue,
      isInvite: data.isInvite.present ? data.isInvite.value : this.isInvite,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('colorValue: $colorValue, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('isInvite: $isInvite, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    timeSlot,
    colorValue,
    isOverdue,
    isInvite,
    eventDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.timeSlot == this.timeSlot &&
          other.colorValue == this.colorValue &&
          other.isOverdue == this.isOverdue &&
          other.isInvite == this.isInvite &&
          other.eventDate == this.eventDate &&
          other.createdAt == this.createdAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> timeSlot;
  final Value<int> colorValue;
  final Value<bool> isOverdue;
  final Value<bool> isInvite;
  final Value<DateTime?> eventDate;
  final Value<DateTime> createdAt;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.timeSlot = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isOverdue = const Value.absent(),
    this.isInvite = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    required String timeSlot,
    required int colorValue,
    this.isOverdue = const Value.absent(),
    this.isInvite = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       timeSlot = Value(timeSlot),
       colorValue = Value(colorValue);
  static Insertable<CalendarEvent> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? timeSlot,
    Expression<int>? colorValue,
    Expression<bool>? isOverdue,
    Expression<bool>? isInvite,
    Expression<DateTime>? eventDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (timeSlot != null) 'time_slot': timeSlot,
      if (colorValue != null) 'color_value': colorValue,
      if (isOverdue != null) 'is_overdue': isOverdue,
      if (isInvite != null) 'is_invite': isInvite,
      if (eventDate != null) 'event_date': eventDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? timeSlot,
    Value<int>? colorValue,
    Value<bool>? isOverdue,
    Value<bool>? isInvite,
    Value<DateTime?>? eventDate,
    Value<DateTime>? createdAt,
  }) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeSlot: timeSlot ?? this.timeSlot,
      colorValue: colorValue ?? this.colorValue,
      isOverdue: isOverdue ?? this.isOverdue,
      isInvite: isInvite ?? this.isInvite,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (timeSlot.present) {
      map['time_slot'] = Variable<String>(timeSlot.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isOverdue.present) {
      map['is_overdue'] = Variable<bool>(isOverdue.value);
    }
    if (isInvite.present) {
      map['is_invite'] = Variable<bool>(isInvite.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('timeSlot: $timeSlot, ')
          ..write('colorValue: $colorValue, ')
          ..write('isOverdue: $isOverdue, ')
          ..write('isInvite: $isInvite, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomListsTable extends CustomLists
    with TableInfo<$CustomListsTable, CustomList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📋'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_lists (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceLabelMeta = const VerificationMeta(
    'recurrenceLabel',
  );
  @override
  late final GeneratedColumn<String> recurrenceLabel = GeneratedColumn<String>(
    'recurrence_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    emoji,
    createdAt,
    parentId,
    dueDate,
    recurrenceLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('recurrence_label')) {
      context.handle(
        _recurrenceLabelMeta,
        recurrenceLabel.isAcceptableOrUnknown(
          data['recurrence_label']!,
          _recurrenceLabelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      recurrenceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_label'],
      ),
    );
  }

  @override
  $CustomListsTable createAlias(String alias) {
    return $CustomListsTable(attachedDatabase, alias);
  }
}

class CustomList extends DataClass implements Insertable<CustomList> {
  final int id;
  final String title;
  final String emoji;
  final DateTime createdAt;
  final int? parentId;
  final DateTime? dueDate;
  final String? recurrenceLabel;
  const CustomList({
    required this.id,
    required this.title,
    required this.emoji,
    required this.createdAt,
    this.parentId,
    this.dueDate,
    this.recurrenceLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['emoji'] = Variable<String>(emoji);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || recurrenceLabel != null) {
      map['recurrence_label'] = Variable<String>(recurrenceLabel);
    }
    return map;
  }

  CustomListsCompanion toCompanion(bool nullToAbsent) {
    return CustomListsCompanion(
      id: Value(id),
      title: Value(title),
      emoji: Value(emoji),
      createdAt: Value(createdAt),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      recurrenceLabel: recurrenceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceLabel),
    );
  }

  factory CustomList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomList(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      emoji: serializer.fromJson<String>(json['emoji']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      recurrenceLabel: serializer.fromJson<String?>(json['recurrenceLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'emoji': serializer.toJson<String>(emoji),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'parentId': serializer.toJson<int?>(parentId),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'recurrenceLabel': serializer.toJson<String?>(recurrenceLabel),
    };
  }

  CustomList copyWith({
    int? id,
    String? title,
    String? emoji,
    DateTime? createdAt,
    Value<int?> parentId = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> recurrenceLabel = const Value.absent(),
  }) => CustomList(
    id: id ?? this.id,
    title: title ?? this.title,
    emoji: emoji ?? this.emoji,
    createdAt: createdAt ?? this.createdAt,
    parentId: parentId.present ? parentId.value : this.parentId,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    recurrenceLabel: recurrenceLabel.present
        ? recurrenceLabel.value
        : this.recurrenceLabel,
  );
  CustomList copyWithCompanion(CustomListsCompanion data) {
    return CustomList(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      recurrenceLabel: data.recurrenceLabel.present
          ? data.recurrenceLabel.value
          : this.recurrenceLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomList(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('parentId: $parentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceLabel: $recurrenceLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    emoji,
    createdAt,
    parentId,
    dueDate,
    recurrenceLabel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomList &&
          other.id == this.id &&
          other.title == this.title &&
          other.emoji == this.emoji &&
          other.createdAt == this.createdAt &&
          other.parentId == this.parentId &&
          other.dueDate == this.dueDate &&
          other.recurrenceLabel == this.recurrenceLabel);
}

class CustomListsCompanion extends UpdateCompanion<CustomList> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> emoji;
  final Value<DateTime> createdAt;
  final Value<int?> parentId;
  final Value<DateTime?> dueDate;
  final Value<String?> recurrenceLabel;
  const CustomListsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.parentId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.recurrenceLabel = const Value.absent(),
  });
  CustomListsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.emoji = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.parentId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.recurrenceLabel = const Value.absent(),
  }) : title = Value(title);
  static Insertable<CustomList> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? emoji,
    Expression<DateTime>? createdAt,
    Expression<int>? parentId,
    Expression<DateTime>? dueDate,
    Expression<String>? recurrenceLabel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (emoji != null) 'emoji': emoji,
      if (createdAt != null) 'created_at': createdAt,
      if (parentId != null) 'parent_id': parentId,
      if (dueDate != null) 'due_date': dueDate,
      if (recurrenceLabel != null) 'recurrence_label': recurrenceLabel,
    });
  }

  CustomListsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? emoji,
    Value<DateTime>? createdAt,
    Value<int?>? parentId,
    Value<DateTime?>? dueDate,
    Value<String?>? recurrenceLabel,
  }) {
    return CustomListsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      dueDate: dueDate ?? this.dueDate,
      recurrenceLabel: recurrenceLabel ?? this.recurrenceLabel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (recurrenceLabel.present) {
      map['recurrence_label'] = Variable<String>(recurrenceLabel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomListsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('emoji: $emoji, ')
          ..write('createdAt: $createdAt, ')
          ..write('parentId: $parentId, ')
          ..write('dueDate: $dueDate, ')
          ..write('recurrenceLabel: $recurrenceLabel')
          ..write(')'))
        .toString();
  }
}

class $CustomListItemsTable extends CustomListItems
    with TableInfo<$CustomListItemsTable, CustomListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    content,
    isDone,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomListItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CustomListItemsTable createAlias(String alias) {
    return $CustomListItemsTable(attachedDatabase, alias);
  }
}

class CustomListItem extends DataClass implements Insertable<CustomListItem> {
  final int id;
  final int listId;
  final String content;
  final bool isDone;
  final int sortOrder;
  const CustomListItem({
    required this.id,
    required this.listId,
    required this.content,
    required this.isDone,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['content'] = Variable<String>(content);
    map['is_done'] = Variable<bool>(isDone);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CustomListItemsCompanion toCompanion(bool nullToAbsent) {
    return CustomListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      content: Value(content),
      isDone: Value(isDone),
      sortOrder: Value(sortOrder),
    );
  }

  factory CustomListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomListItem(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      content: serializer.fromJson<String>(json['content']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'content': serializer.toJson<String>(content),
      'isDone': serializer.toJson<bool>(isDone),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CustomListItem copyWith({
    int? id,
    int? listId,
    String? content,
    bool? isDone,
    int? sortOrder,
  }) => CustomListItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    content: content ?? this.content,
    isDone: isDone ?? this.isDone,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CustomListItem copyWithCompanion(CustomListItemsCompanion data) {
    return CustomListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      content: data.content.present ? data.content.value : this.content,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('content: $content, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, content, isDone, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.content == this.content &&
          other.isDone == this.isDone &&
          other.sortOrder == this.sortOrder);
}

class CustomListItemsCompanion extends UpdateCompanion<CustomListItem> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> content;
  final Value<bool> isDone;
  final Value<int> sortOrder;
  const CustomListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.content = const Value.absent(),
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CustomListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String content,
    this.isDone = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : listId = Value(listId),
       content = Value(content);
  static Insertable<CustomListItem> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? content,
    Expression<bool>? isDone,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (content != null) 'content': content,
      if (isDone != null) 'is_done': isDone,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CustomListItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<String>? content,
    Value<bool>? isDone,
    Value<int>? sortOrder,
  }) {
    return CustomListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      content: content ?? this.content,
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('content: $content, ')
          ..write('isDone: $isDone, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quadrantMeta = const VerificationMeta(
    'quadrant',
  );
  @override
  late final GeneratedColumn<int> quadrant = GeneratedColumn<int>(
    'quadrant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    quadrant,
    startedAt,
    durationSeconds,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('quadrant')) {
      context.handle(
        _quadrantMeta,
        quadrant.isAcceptableOrUnknown(data['quadrant']!, _quadrantMeta),
      );
    } else if (isInserting) {
      context.missing(_quadrantMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      quadrant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quadrant'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final int taskId;
  final int quadrant;
  final DateTime startedAt;
  final int durationSeconds;
  final bool completed;
  const FocusSession({
    required this.id,
    required this.taskId,
    required this.quadrant,
    required this.startedAt,
    required this.durationSeconds,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['quadrant'] = Variable<int>(quadrant);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      quadrant: Value(quadrant),
      startedAt: Value(startedAt),
      durationSeconds: Value(durationSeconds),
      completed: Value(completed),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      quadrant: serializer.fromJson<int>(json['quadrant']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'quadrant': serializer.toJson<int>(quadrant),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  FocusSession copyWith({
    int? id,
    int? taskId,
    int? quadrant,
    DateTime? startedAt,
    int? durationSeconds,
    bool? completed,
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    quadrant: quadrant ?? this.quadrant,
    startedAt: startedAt ?? this.startedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completed: completed ?? this.completed,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      quadrant: data.quadrant.present ? data.quadrant.value : this.quadrant,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('quadrant: $quadrant, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, quadrant, startedAt, durationSeconds, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.quadrant == this.quadrant &&
          other.startedAt == this.startedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.completed == this.completed);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<int> quadrant;
  final Value<DateTime> startedAt;
  final Value<int> durationSeconds;
  final Value<bool> completed;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.quadrant = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completed = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required int quadrant,
    required DateTime startedAt,
    required int durationSeconds,
    this.completed = const Value.absent(),
  }) : taskId = Value(taskId),
       quadrant = Value(quadrant),
       startedAt = Value(startedAt),
       durationSeconds = Value(durationSeconds);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<int>? quadrant,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSeconds,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (quadrant != null) 'quadrant': quadrant,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completed != null) 'completed': completed,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<int>? quadrant,
    Value<DateTime>? startedAt,
    Value<int>? durationSeconds,
    Value<bool>? completed,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      quadrant: quadrant ?? this.quadrant,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (quadrant.present) {
      map['quadrant'] = Variable<int>(quadrant.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('quadrant: $quadrant, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $KaalDatabasesTable extends KaalDatabases
    with TableInfo<$KaalDatabasesTable, KaalDatabase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KaalDatabasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Untitled'),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🗂️'),
  );
  static const VerificationMeta _defaultViewMeta = const VerificationMeta(
    'defaultView',
  );
  @override
  late final GeneratedColumn<String> defaultView = GeneratedColumn<String>(
    'default_view',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('table'),
  );
  static const VerificationMeta _boardGroupPropMeta = const VerificationMeta(
    'boardGroupProp',
  );
  @override
  late final GeneratedColumn<String> boardGroupProp = GeneratedColumn<String>(
    'board_group_prop',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    defaultView,
    boardGroupProp,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kaal_databases';
  @override
  VerificationContext validateIntegrity(
    Insertable<KaalDatabase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('default_view')) {
      context.handle(
        _defaultViewMeta,
        defaultView.isAcceptableOrUnknown(
          data['default_view']!,
          _defaultViewMeta,
        ),
      );
    }
    if (data.containsKey('board_group_prop')) {
      context.handle(
        _boardGroupPropMeta,
        boardGroupProp.isAcceptableOrUnknown(
          data['board_group_prop']!,
          _boardGroupPropMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KaalDatabase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KaalDatabase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      defaultView: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_view'],
      )!,
      boardGroupProp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_group_prop'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $KaalDatabasesTable createAlias(String alias) {
    return $KaalDatabasesTable(attachedDatabase, alias);
  }
}

class KaalDatabase extends DataClass implements Insertable<KaalDatabase> {
  final int id;
  final String name;
  final String icon;

  /// table | board | list
  final String defaultView;

  /// Property id used to group the board view (a select/status column).
  final String? boardGroupProp;
  final DateTime createdAt;
  const KaalDatabase({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultView,
    this.boardGroupProp,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['default_view'] = Variable<String>(defaultView);
    if (!nullToAbsent || boardGroupProp != null) {
      map['board_group_prop'] = Variable<String>(boardGroupProp);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  KaalDatabasesCompanion toCompanion(bool nullToAbsent) {
    return KaalDatabasesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      defaultView: Value(defaultView),
      boardGroupProp: boardGroupProp == null && nullToAbsent
          ? const Value.absent()
          : Value(boardGroupProp),
      createdAt: Value(createdAt),
    );
  }

  factory KaalDatabase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KaalDatabase(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      defaultView: serializer.fromJson<String>(json['defaultView']),
      boardGroupProp: serializer.fromJson<String?>(json['boardGroupProp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'defaultView': serializer.toJson<String>(defaultView),
      'boardGroupProp': serializer.toJson<String?>(boardGroupProp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  KaalDatabase copyWith({
    int? id,
    String? name,
    String? icon,
    String? defaultView,
    Value<String?> boardGroupProp = const Value.absent(),
    DateTime? createdAt,
  }) => KaalDatabase(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    defaultView: defaultView ?? this.defaultView,
    boardGroupProp: boardGroupProp.present
        ? boardGroupProp.value
        : this.boardGroupProp,
    createdAt: createdAt ?? this.createdAt,
  );
  KaalDatabase copyWithCompanion(KaalDatabasesCompanion data) {
    return KaalDatabase(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      defaultView: data.defaultView.present
          ? data.defaultView.value
          : this.defaultView,
      boardGroupProp: data.boardGroupProp.present
          ? data.boardGroupProp.value
          : this.boardGroupProp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KaalDatabase(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('defaultView: $defaultView, ')
          ..write('boardGroupProp: $boardGroupProp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, defaultView, boardGroupProp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KaalDatabase &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.defaultView == this.defaultView &&
          other.boardGroupProp == this.boardGroupProp &&
          other.createdAt == this.createdAt);
}

class KaalDatabasesCompanion extends UpdateCompanion<KaalDatabase> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<String> defaultView;
  final Value<String?> boardGroupProp;
  final Value<DateTime> createdAt;
  const KaalDatabasesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.defaultView = const Value.absent(),
    this.boardGroupProp = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  KaalDatabasesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.defaultView = const Value.absent(),
    this.boardGroupProp = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<KaalDatabase> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? defaultView,
    Expression<String>? boardGroupProp,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (defaultView != null) 'default_view': defaultView,
      if (boardGroupProp != null) 'board_group_prop': boardGroupProp,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  KaalDatabasesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<String>? defaultView,
    Value<String?>? boardGroupProp,
    Value<DateTime>? createdAt,
  }) {
    return KaalDatabasesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      defaultView: defaultView ?? this.defaultView,
      boardGroupProp: boardGroupProp ?? this.boardGroupProp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (defaultView.present) {
      map['default_view'] = Variable<String>(defaultView.value);
    }
    if (boardGroupProp.present) {
      map['board_group_prop'] = Variable<String>(boardGroupProp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KaalDatabasesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('defaultView: $defaultView, ')
          ..write('boardGroupProp: $boardGroupProp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DbPropertiesTable extends DbProperties
    with TableInfo<$DbPropertiesTable, DbProperty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbPropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseIdMeta = const VerificationMeta(
    'databaseId',
  );
  @override
  late final GeneratedColumn<int> databaseId = GeneratedColumn<int>(
    'database_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kaal_databases (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    databaseId,
    name,
    type,
    config,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbProperty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('database_id')) {
      context.handle(
        _databaseIdMeta,
        databaseId.isAcceptableOrUnknown(data['database_id']!, _databaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbProperty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbProperty(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      databaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}database_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DbPropertiesTable createAlias(String alias) {
    return $DbPropertiesTable(attachedDatabase, alias);
  }
}

class DbProperty extends DataClass implements Insertable<DbProperty> {
  final String id;
  final int databaseId;
  final String name;

  /// text | number | select | multiSelect | date | checkbox | url
  final String type;

  /// JSON config. For select/multiSelect: `{"options":[{"name":..,"color":..}]}`.
  final String config;
  final int sortOrder;
  const DbProperty({
    required this.id,
    required this.databaseId,
    required this.name,
    required this.type,
    required this.config,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['database_id'] = Variable<int>(databaseId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['config'] = Variable<String>(config);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DbPropertiesCompanion toCompanion(bool nullToAbsent) {
    return DbPropertiesCompanion(
      id: Value(id),
      databaseId: Value(databaseId),
      name: Value(name),
      type: Value(type),
      config: Value(config),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbProperty.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbProperty(
      id: serializer.fromJson<String>(json['id']),
      databaseId: serializer.fromJson<int>(json['databaseId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      config: serializer.fromJson<String>(json['config']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'databaseId': serializer.toJson<int>(databaseId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'config': serializer.toJson<String>(config),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbProperty copyWith({
    String? id,
    int? databaseId,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
  }) => DbProperty(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    name: name ?? this.name,
    type: type ?? this.type,
    config: config ?? this.config,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DbProperty copyWithCompanion(DbPropertiesCompanion data) {
    return DbProperty(
      id: data.id.present ? data.id.value : this.id,
      databaseId: data.databaseId.present
          ? data.databaseId.value
          : this.databaseId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      config: data.config.present ? data.config.value : this.config,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbProperty(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, databaseId, name, type, config, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbProperty &&
          other.id == this.id &&
          other.databaseId == this.databaseId &&
          other.name == this.name &&
          other.type == this.type &&
          other.config == this.config &&
          other.sortOrder == this.sortOrder);
}

class DbPropertiesCompanion extends UpdateCompanion<DbProperty> {
  final Value<String> id;
  final Value<int> databaseId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> config;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const DbPropertiesCompanion({
    this.id = const Value.absent(),
    this.databaseId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbPropertiesCompanion.insert({
    required String id,
    required int databaseId,
    required String name,
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       databaseId = Value(databaseId),
       name = Value(name);
  static Insertable<DbProperty> custom({
    Expression<String>? id,
    Expression<int>? databaseId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? config,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseId != null) 'database_id': databaseId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbPropertiesCompanion copyWith({
    Value<String>? id,
    Value<int>? databaseId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? config,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return DbPropertiesCompanion(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (databaseId.present) {
      map['database_id'] = Variable<int>(databaseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbPropertiesCompanion(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbRowsTable extends DbRows with TableInfo<$DbRowsTable, DbRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseIdMeta = const VerificationMeta(
    'databaseId',
  );
  @override
  late final GeneratedColumn<int> databaseId = GeneratedColumn<int>(
    'database_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kaal_databases (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cellsMeta = const VerificationMeta('cells');
  @override
  late final GeneratedColumn<String> cells = GeneratedColumn<String>(
    'cells',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    databaseId,
    cells,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('database_id')) {
      context.handle(
        _databaseIdMeta,
        databaseId.isAcceptableOrUnknown(data['database_id']!, _databaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseIdMeta);
    }
    if (data.containsKey('cells')) {
      context.handle(
        _cellsMeta,
        cells.isAcceptableOrUnknown(data['cells']!, _cellsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      databaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}database_id'],
      )!,
      cells: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cells'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DbRowsTable createAlias(String alias) {
    return $DbRowsTable(attachedDatabase, alias);
  }
}

class DbRow extends DataClass implements Insertable<DbRow> {
  final String id;
  final int databaseId;
  final String cells;
  final int sortOrder;
  final DateTime createdAt;
  const DbRow({
    required this.id,
    required this.databaseId,
    required this.cells,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['database_id'] = Variable<int>(databaseId);
    map['cells'] = Variable<String>(cells);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DbRowsCompanion toCompanion(bool nullToAbsent) {
    return DbRowsCompanion(
      id: Value(id),
      databaseId: Value(databaseId),
      cells: Value(cells),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory DbRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRow(
      id: serializer.fromJson<String>(json['id']),
      databaseId: serializer.fromJson<int>(json['databaseId']),
      cells: serializer.fromJson<String>(json['cells']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'databaseId': serializer.toJson<int>(databaseId),
      'cells': serializer.toJson<String>(cells),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbRow copyWith({
    String? id,
    int? databaseId,
    String? cells,
    int? sortOrder,
    DateTime? createdAt,
  }) => DbRow(
    id: id ?? this.id,
    databaseId: databaseId ?? this.databaseId,
    cells: cells ?? this.cells,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  DbRow copyWithCompanion(DbRowsCompanion data) {
    return DbRow(
      id: data.id.present ? data.id.value : this.id,
      databaseId: data.databaseId.present
          ? data.databaseId.value
          : this.databaseId,
      cells: data.cells.present ? data.cells.value : this.cells,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRow(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('cells: $cells, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, databaseId, cells, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRow &&
          other.id == this.id &&
          other.databaseId == this.databaseId &&
          other.cells == this.cells &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class DbRowsCompanion extends UpdateCompanion<DbRow> {
  final Value<String> id;
  final Value<int> databaseId;
  final Value<String> cells;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DbRowsCompanion({
    this.id = const Value.absent(),
    this.databaseId = const Value.absent(),
    this.cells = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbRowsCompanion.insert({
    required String id,
    required int databaseId,
    this.cells = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       databaseId = Value(databaseId);
  static Insertable<DbRow> custom({
    Expression<String>? id,
    Expression<int>? databaseId,
    Expression<String>? cells,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (databaseId != null) 'database_id': databaseId,
      if (cells != null) 'cells': cells,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbRowsCompanion copyWith({
    Value<String>? id,
    Value<int>? databaseId,
    Value<String>? cells,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DbRowsCompanion(
      id: id ?? this.id,
      databaseId: databaseId ?? this.databaseId,
      cells: cells ?? this.cells,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (databaseId.present) {
      map['database_id'] = Variable<int>(databaseId.value);
    }
    if (cells.present) {
      map['cells'] = Variable<String>(cells.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbRowsCompanion(')
          ..write('id: $id, ')
          ..write('databaseId: $databaseId, ')
          ..write('cells: $cells, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $SubHabitsTable subHabits = $SubHabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $GoalTaskLinksTable goalTaskLinks = $GoalTaskLinksTable(this);
  late final $GoalHabitLinksTable goalHabitLinks = $GoalHabitLinksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $NoteTaskLinksTable noteTaskLinks = $NoteTaskLinksTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $CustomListsTable customLists = $CustomListsTable(this);
  late final $CustomListItemsTable customListItems = $CustomListItemsTable(
    this,
  );
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $KaalDatabasesTable kaalDatabases = $KaalDatabasesTable(this);
  late final $DbPropertiesTable dbProperties = $DbPropertiesTable(this);
  late final $DbRowsTable dbRows = $DbRowsTable(this);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final HabitsDao habitsDao = HabitsDao(this as AppDatabase);
  late final GoalsDao goalsDao = GoalsDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final CalendarDao calendarDao = CalendarDao(this as AppDatabase);
  late final ListsDao listsDao = ListsDao(this as AppDatabase);
  late final FocusDao focusDao = FocusDao(this as AppDatabase);
  late final DatabasesDao databasesDao = DatabasesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    subtasks,
    habits,
    subHabits,
    habitLogs,
    goals,
    goalTaskLinks,
    goalHabitLinks,
    notes,
    noteTags,
    noteTaskLinks,
    calendarEvents,
    customLists,
    customListItems,
    focusSessions,
    kaalDatabases,
    dbProperties,
    dbRows,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subtasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sub_habits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('goal_task_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'goals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('goal_habit_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_task_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_lists', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_list_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'kaal_databases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_properties', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'kaal_databases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('db_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required int quadrant,
      Value<DateTime?> dueDate,
      Value<String?> dueLabel,
      Value<bool> isOverdue,
      Value<bool> hasAi,
      Value<double?> urgencyScore,
      Value<String?> recurrenceLabel,
      Value<bool> hasPomodoro,
      Value<String?> priority,
      Value<String?> notes,
      Value<int?> timeAllocatedMin,
      Value<double?> goalWeight,
      Value<double?> urgency,
      Value<double?> impact,
      Value<double?> focusFit,
      Value<bool> isDone,
      Value<DateTime?> doneAt,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> totalFocusSeconds,
      Value<String?> labels,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int> quadrant,
      Value<DateTime?> dueDate,
      Value<String?> dueLabel,
      Value<bool> isOverdue,
      Value<bool> hasAi,
      Value<double?> urgencyScore,
      Value<String?> recurrenceLabel,
      Value<bool> hasPomodoro,
      Value<String?> priority,
      Value<String?> notes,
      Value<int?> timeAllocatedMin,
      Value<double?> goalWeight,
      Value<double?> urgency,
      Value<double?> impact,
      Value<double?> focusFit,
      Value<bool> isDone,
      Value<DateTime?> doneAt,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> totalFocusSeconds,
      Value<String?> labels,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubtasksTable, List<Subtask>> _subtasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'tasks__id__subtasks__task_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueLabel => $composableBuilder(
    column: $table.dueLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAi => $composableBuilder(
    column: $table.hasAi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get urgencyScore => $composableBuilder(
    column: $table.urgencyScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPomodoro => $composableBuilder(
    column: $table.hasPomodoro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeAllocatedMin => $composableBuilder(
    column: $table.timeAllocatedMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalWeight => $composableBuilder(
    column: $table.goalWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focusFit => $composableBuilder(
    column: $table.focusFit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueLabel => $composableBuilder(
    column: $table.dueLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAi => $composableBuilder(
    column: $table.hasAi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get urgencyScore => $composableBuilder(
    column: $table.urgencyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPomodoro => $composableBuilder(
    column: $table.hasPomodoro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeAllocatedMin => $composableBuilder(
    column: $table.timeAllocatedMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalWeight => $composableBuilder(
    column: $table.goalWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get urgency => $composableBuilder(
    column: $table.urgency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focusFit => $composableBuilder(
    column: $table.focusFit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get quadrant =>
      $composableBuilder(column: $table.quadrant, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dueLabel =>
      $composableBuilder(column: $table.dueLabel, builder: (column) => column);

  GeneratedColumn<bool> get isOverdue =>
      $composableBuilder(column: $table.isOverdue, builder: (column) => column);

  GeneratedColumn<bool> get hasAi =>
      $composableBuilder(column: $table.hasAi, builder: (column) => column);

  GeneratedColumn<double> get urgencyScore => $composableBuilder(
    column: $table.urgencyScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPomodoro => $composableBuilder(
    column: $table.hasPomodoro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get timeAllocatedMin => $composableBuilder(
    column: $table.timeAllocatedMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get goalWeight => $composableBuilder(
    column: $table.goalWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<double> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<double> get focusFit =>
      $composableBuilder(column: $table.focusFit, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool subtasksRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> quadrant = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> dueLabel = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<bool> hasAi = const Value.absent(),
                Value<double?> urgencyScore = const Value.absent(),
                Value<String?> recurrenceLabel = const Value.absent(),
                Value<bool> hasPomodoro = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> timeAllocatedMin = const Value.absent(),
                Value<double?> goalWeight = const Value.absent(),
                Value<double?> urgency = const Value.absent(),
                Value<double?> impact = const Value.absent(),
                Value<double?> focusFit = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> totalFocusSeconds = const Value.absent(),
                Value<String?> labels = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                quadrant: quadrant,
                dueDate: dueDate,
                dueLabel: dueLabel,
                isOverdue: isOverdue,
                hasAi: hasAi,
                urgencyScore: urgencyScore,
                recurrenceLabel: recurrenceLabel,
                hasPomodoro: hasPomodoro,
                priority: priority,
                notes: notes,
                timeAllocatedMin: timeAllocatedMin,
                goalWeight: goalWeight,
                urgency: urgency,
                impact: impact,
                focusFit: focusFit,
                isDone: isDone,
                doneAt: doneAt,
                sortOrder: sortOrder,
                createdAt: createdAt,
                totalFocusSeconds: totalFocusSeconds,
                labels: labels,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required int quadrant,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> dueLabel = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<bool> hasAi = const Value.absent(),
                Value<double?> urgencyScore = const Value.absent(),
                Value<String?> recurrenceLabel = const Value.absent(),
                Value<bool> hasPomodoro = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> timeAllocatedMin = const Value.absent(),
                Value<double?> goalWeight = const Value.absent(),
                Value<double?> urgency = const Value.absent(),
                Value<double?> impact = const Value.absent(),
                Value<double?> focusFit = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> totalFocusSeconds = const Value.absent(),
                Value<String?> labels = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                quadrant: quadrant,
                dueDate: dueDate,
                dueLabel: dueLabel,
                isOverdue: isOverdue,
                hasAi: hasAi,
                urgencyScore: urgencyScore,
                recurrenceLabel: recurrenceLabel,
                hasPomodoro: hasPomodoro,
                priority: priority,
                notes: notes,
                timeAllocatedMin: timeAllocatedMin,
                goalWeight: goalWeight,
                urgency: urgency,
                impact: impact,
                focusFit: focusFit,
                isDone: isDone,
                doneAt: doneAt,
                sortOrder: sortOrder,
                createdAt: createdAt,
                totalFocusSeconds: totalFocusSeconds,
                labels: labels,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({subtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subtasksRefs) db.subtasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtasksRefs)
                    await $_getPrefetchedData<Task, $TasksTable, Subtask>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._subtasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).subtasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool subtasksRefs})
    >;
typedef $$SubtasksTableCreateCompanionBuilder =
    SubtasksCompanion Function({
      Value<int> id,
      required int taskId,
      required String title,
      Value<bool> isDone,
      Value<int> sortOrder,
    });
typedef $$SubtasksTableUpdateCompanionBuilder =
    SubtasksCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<String> title,
      Value<bool> isDone,
      Value<int> sortOrder,
    });

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, Subtask> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('subtasks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          Subtask,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (Subtask, $$SubtasksTableReferences),
          Subtask,
          PrefetchHooks Function({bool taskId})
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required String title,
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$SubtasksTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$SubtasksTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      Subtask,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (Subtask, $$SubtasksTableReferences),
      Subtask,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String emoji,
      required String name,
      required String frequencyLabel,
      Value<int?> durationMinutes,
      Value<int?> scheduledTime,
      Value<int> quadrant,
      required String streakLabel,
      required int streakColorValue,
      required int accentColorValue,
      Value<int> weeklyFilledCount,
      Value<String?> subLabel,
      Value<String?> notes,
      Value<DateTime?> lastCheckedDate,
      Value<DateTime> createdAt,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> emoji,
      Value<String> name,
      Value<String> frequencyLabel,
      Value<int?> durationMinutes,
      Value<int?> scheduledTime,
      Value<int> quadrant,
      Value<String> streakLabel,
      Value<int> streakColorValue,
      Value<int> accentColorValue,
      Value<int> weeklyFilledCount,
      Value<String?> subLabel,
      Value<String?> notes,
      Value<DateTime?> lastCheckedDate,
      Value<DateTime> createdAt,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubHabitsTable, List<SubHabit>>
  _subHabitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subHabits,
    aliasName: 'habits__id__sub_habits__habit_id',
  );

  $$SubHabitsTableProcessedTableManager get subHabitsRefs {
    final manager = $$SubHabitsTableTableManager(
      $_db,
      $_db.subHabits,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subHabitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>>
  _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: 'habits__id__habit_logs__habit_id',
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyLabel => $composableBuilder(
    column: $table.frequencyLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streakLabel => $composableBuilder(
    column: $table.streakLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakColorValue => $composableBuilder(
    column: $table.streakColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyFilledCount => $composableBuilder(
    column: $table.weeklyFilledCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subLabel => $composableBuilder(
    column: $table.subLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedDate => $composableBuilder(
    column: $table.lastCheckedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subHabitsRefs(
    Expression<bool> Function($$SubHabitsTableFilterComposer f) f,
  ) {
    final $$SubHabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subHabits,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubHabitsTableFilterComposer(
            $db: $db,
            $table: $db.subHabits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyLabel => $composableBuilder(
    column: $table.frequencyLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streakLabel => $composableBuilder(
    column: $table.streakLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakColorValue => $composableBuilder(
    column: $table.streakColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyFilledCount => $composableBuilder(
    column: $table.weeklyFilledCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subLabel => $composableBuilder(
    column: $table.subLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedDate => $composableBuilder(
    column: $table.lastCheckedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get frequencyLabel => $composableBuilder(
    column: $table.frequencyLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quadrant =>
      $composableBuilder(column: $table.quadrant, builder: (column) => column);

  GeneratedColumn<String> get streakLabel => $composableBuilder(
    column: $table.streakLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakColorValue => $composableBuilder(
    column: $table.streakColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyFilledCount => $composableBuilder(
    column: $table.weeklyFilledCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subLabel =>
      $composableBuilder(column: $table.subLabel, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedDate => $composableBuilder(
    column: $table.lastCheckedDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> subHabitsRefs<T extends Object>(
    Expression<T> Function($$SubHabitsTableAnnotationComposer a) f,
  ) {
    final $$SubHabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subHabits,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubHabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.subHabits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool subHabitsRefs, bool habitLogsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> frequencyLabel = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<int?> scheduledTime = const Value.absent(),
                Value<int> quadrant = const Value.absent(),
                Value<String> streakLabel = const Value.absent(),
                Value<int> streakColorValue = const Value.absent(),
                Value<int> accentColorValue = const Value.absent(),
                Value<int> weeklyFilledCount = const Value.absent(),
                Value<String?> subLabel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastCheckedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                emoji: emoji,
                name: name,
                frequencyLabel: frequencyLabel,
                durationMinutes: durationMinutes,
                scheduledTime: scheduledTime,
                quadrant: quadrant,
                streakLabel: streakLabel,
                streakColorValue: streakColorValue,
                accentColorValue: accentColorValue,
                weeklyFilledCount: weeklyFilledCount,
                subLabel: subLabel,
                notes: notes,
                lastCheckedDate: lastCheckedDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String emoji,
                required String name,
                required String frequencyLabel,
                Value<int?> durationMinutes = const Value.absent(),
                Value<int?> scheduledTime = const Value.absent(),
                Value<int> quadrant = const Value.absent(),
                required String streakLabel,
                required int streakColorValue,
                required int accentColorValue,
                Value<int> weeklyFilledCount = const Value.absent(),
                Value<String?> subLabel = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> lastCheckedDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                emoji: emoji,
                name: name,
                frequencyLabel: frequencyLabel,
                durationMinutes: durationMinutes,
                scheduledTime: scheduledTime,
                quadrant: quadrant,
                streakLabel: streakLabel,
                streakColorValue: streakColorValue,
                accentColorValue: accentColorValue,
                weeklyFilledCount: weeklyFilledCount,
                subLabel: subLabel,
                notes: notes,
                lastCheckedDate: lastCheckedDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({subHabitsRefs = false, habitLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subHabitsRefs) db.subHabits,
                    if (habitLogsRefs) db.habitLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subHabitsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          SubHabit
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._subHabitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).subHabitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitLogsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitLog
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool subHabitsRefs, bool habitLogsRefs})
    >;
typedef $$SubHabitsTableCreateCompanionBuilder =
    SubHabitsCompanion Function({
      Value<int> id,
      required int habitId,
      required String title,
      Value<bool> isDone,
      Value<int> sortOrder,
    });
typedef $$SubHabitsTableUpdateCompanionBuilder =
    SubHabitsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<String> title,
      Value<bool> isDone,
      Value<int> sortOrder,
    });

final class $$SubHabitsTableReferences
    extends BaseReferences<_$AppDatabase, $SubHabitsTable, SubHabit> {
  $$SubHabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('sub_habits__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubHabitsTableFilterComposer
    extends Composer<_$AppDatabase, $SubHabitsTable> {
  $$SubHabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubHabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubHabitsTable> {
  $$SubHabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubHabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubHabitsTable> {
  $$SubHabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubHabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubHabitsTable,
          SubHabit,
          $$SubHabitsTableFilterComposer,
          $$SubHabitsTableOrderingComposer,
          $$SubHabitsTableAnnotationComposer,
          $$SubHabitsTableCreateCompanionBuilder,
          $$SubHabitsTableUpdateCompanionBuilder,
          (SubHabit, $$SubHabitsTableReferences),
          SubHabit,
          PrefetchHooks Function({bool habitId})
        > {
  $$SubHabitsTableTableManager(_$AppDatabase db, $SubHabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubHabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubHabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubHabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubHabitsCompanion(
                id: id,
                habitId: habitId,
                title: title,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required String title,
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubHabitsCompanion.insert(
                id: id,
                habitId: habitId,
                title: title,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubHabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$SubHabitsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$SubHabitsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubHabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubHabitsTable,
      SubHabit,
      $$SubHabitsTableFilterComposer,
      $$SubHabitsTableOrderingComposer,
      $$SubHabitsTableAnnotationComposer,
      $$SubHabitsTableCreateCompanionBuilder,
      $$SubHabitsTableUpdateCompanionBuilder,
      (SubHabit, $$SubHabitsTableReferences),
      SubHabit,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime logDate,
      Value<bool> isSkipped,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> logDate,
      Value<bool> isSkipped,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_logs__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
    column: $table.isSkipped,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, $$HabitLogsTableReferences),
          HabitLog,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> logDate = const Value.absent(),
                Value<bool> isSkipped = const Value.absent(),
              }) => HabitLogsCompanion(
                id: id,
                habitId: habitId,
                logDate: logDate,
                isSkipped: isSkipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime logDate,
                Value<bool> isSkipped = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                id: id,
                habitId: habitId,
                logDate: logDate,
                isSkipped: isSkipped,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, $$HabitLogsTableReferences),
      HabitLog,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String emoji,
      required String emojiBg,
      required String title,
      required String subtitle,
      Value<double> progressPct,
      required int accentColorValue,
      required int barColorValue,
      required int borderColorValue,
      required String linkedLabel,
      Value<String> linkType,
      required int dotColorValue,
      Value<DateTime> createdAt,
      Value<DateTime?> deadline,
      Value<String> milestones,
      Value<String?> notes,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> emoji,
      Value<String> emojiBg,
      Value<String> title,
      Value<String> subtitle,
      Value<double> progressPct,
      Value<int> accentColorValue,
      Value<int> barColorValue,
      Value<int> borderColorValue,
      Value<String> linkedLabel,
      Value<String> linkType,
      Value<int> dotColorValue,
      Value<DateTime> createdAt,
      Value<DateTime?> deadline,
      Value<String> milestones,
      Value<String?> notes,
    });

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GoalTaskLinksTable, List<GoalTaskLink>>
  _goalTaskLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalTaskLinks,
    aliasName: 'goals__id__goal_task_links__goal_id',
  );

  $$GoalTaskLinksTableProcessedTableManager get goalTaskLinksRefs {
    final manager = $$GoalTaskLinksTableTableManager(
      $_db,
      $_db.goalTaskLinks,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalTaskLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalHabitLinksTable, List<GoalHabitLink>>
  _goalHabitLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalHabitLinks,
    aliasName: 'goals__id__goal_habit_links__goal_id',
  );

  $$GoalHabitLinksTableProcessedTableManager get goalHabitLinksRefs {
    final manager = $$GoalHabitLinksTableTableManager(
      $_db,
      $_db.goalHabitLinks,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalHabitLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emojiBg => $composableBuilder(
    column: $table.emojiBg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progressPct => $composableBuilder(
    column: $table.progressPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get barColorValue => $composableBuilder(
    column: $table.barColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get borderColorValue => $composableBuilder(
    column: $table.borderColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedLabel => $composableBuilder(
    column: $table.linkedLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dotColorValue => $composableBuilder(
    column: $table.dotColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get milestones => $composableBuilder(
    column: $table.milestones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> goalTaskLinksRefs(
    Expression<bool> Function($$GoalTaskLinksTableFilterComposer f) f,
  ) {
    final $$GoalTaskLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalTaskLinks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalTaskLinksTableFilterComposer(
            $db: $db,
            $table: $db.goalTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalHabitLinksRefs(
    Expression<bool> Function($$GoalHabitLinksTableFilterComposer f) f,
  ) {
    final $$GoalHabitLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalHabitLinks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalHabitLinksTableFilterComposer(
            $db: $db,
            $table: $db.goalHabitLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emojiBg => $composableBuilder(
    column: $table.emojiBg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progressPct => $composableBuilder(
    column: $table.progressPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get barColorValue => $composableBuilder(
    column: $table.barColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get borderColorValue => $composableBuilder(
    column: $table.borderColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedLabel => $composableBuilder(
    column: $table.linkedLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkType => $composableBuilder(
    column: $table.linkType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dotColorValue => $composableBuilder(
    column: $table.dotColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milestones => $composableBuilder(
    column: $table.milestones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get emojiBg =>
      $composableBuilder(column: $table.emojiBg, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<double> get progressPct => $composableBuilder(
    column: $table.progressPct,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get barColorValue => $composableBuilder(
    column: $table.barColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get borderColorValue => $composableBuilder(
    column: $table.borderColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedLabel => $composableBuilder(
    column: $table.linkedLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkType =>
      $composableBuilder(column: $table.linkType, builder: (column) => column);

  GeneratedColumn<int> get dotColorValue => $composableBuilder(
    column: $table.dotColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get milestones => $composableBuilder(
    column: $table.milestones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> goalTaskLinksRefs<T extends Object>(
    Expression<T> Function($$GoalTaskLinksTableAnnotationComposer a) f,
  ) {
    final $$GoalTaskLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalTaskLinks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalTaskLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.goalTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalHabitLinksRefs<T extends Object>(
    Expression<T> Function($$GoalHabitLinksTableAnnotationComposer a) f,
  ) {
    final $$GoalHabitLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalHabitLinks,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalHabitLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.goalHabitLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({
            bool goalTaskLinksRefs,
            bool goalHabitLinksRefs,
          })
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> emojiBg = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<double> progressPct = const Value.absent(),
                Value<int> accentColorValue = const Value.absent(),
                Value<int> barColorValue = const Value.absent(),
                Value<int> borderColorValue = const Value.absent(),
                Value<String> linkedLabel = const Value.absent(),
                Value<String> linkType = const Value.absent(),
                Value<int> dotColorValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String> milestones = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                emoji: emoji,
                emojiBg: emojiBg,
                title: title,
                subtitle: subtitle,
                progressPct: progressPct,
                accentColorValue: accentColorValue,
                barColorValue: barColorValue,
                borderColorValue: borderColorValue,
                linkedLabel: linkedLabel,
                linkType: linkType,
                dotColorValue: dotColorValue,
                createdAt: createdAt,
                deadline: deadline,
                milestones: milestones,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String emoji,
                required String emojiBg,
                required String title,
                required String subtitle,
                Value<double> progressPct = const Value.absent(),
                required int accentColorValue,
                required int barColorValue,
                required int borderColorValue,
                required String linkedLabel,
                Value<String> linkType = const Value.absent(),
                required int dotColorValue,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String> milestones = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                emoji: emoji,
                emojiBg: emojiBg,
                title: title,
                subtitle: subtitle,
                progressPct: progressPct,
                accentColorValue: accentColorValue,
                barColorValue: barColorValue,
                borderColorValue: borderColorValue,
                linkedLabel: linkedLabel,
                linkType: linkType,
                dotColorValue: dotColorValue,
                createdAt: createdAt,
                deadline: deadline,
                milestones: milestones,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GoalsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({goalTaskLinksRefs = false, goalHabitLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (goalTaskLinksRefs) db.goalTaskLinks,
                    if (goalHabitLinksRefs) db.goalHabitLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (goalTaskLinksRefs)
                        await $_getPrefetchedData<
                          Goal,
                          $GoalsTable,
                          GoalTaskLink
                        >(
                          currentTable: table,
                          referencedTable: $$GoalsTableReferences
                              ._goalTaskLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalTaskLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.goalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (goalHabitLinksRefs)
                        await $_getPrefetchedData<
                          Goal,
                          $GoalsTable,
                          GoalHabitLink
                        >(
                          currentTable: table,
                          referencedTable: $$GoalsTableReferences
                              ._goalHabitLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalHabitLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.goalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool goalTaskLinksRefs, bool goalHabitLinksRefs})
    >;
typedef $$GoalTaskLinksTableCreateCompanionBuilder =
    GoalTaskLinksCompanion Function({
      required int goalId,
      required int taskId,
      Value<int> rowid,
    });
typedef $$GoalTaskLinksTableUpdateCompanionBuilder =
    GoalTaskLinksCompanion Function({
      Value<int> goalId,
      Value<int> taskId,
      Value<int> rowid,
    });

final class $$GoalTaskLinksTableReferences
    extends BaseReferences<_$AppDatabase, $GoalTaskLinksTable, GoalTaskLink> {
  $$GoalTaskLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias('goal_task_links__goal_id__goals__id');

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalTaskLinksTableFilterComposer
    extends Composer<_$AppDatabase, $GoalTaskLinksTable> {
  $$GoalTaskLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalTaskLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalTaskLinksTable> {
  $$GoalTaskLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalTaskLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalTaskLinksTable> {
  $$GoalTaskLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalTaskLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalTaskLinksTable,
          GoalTaskLink,
          $$GoalTaskLinksTableFilterComposer,
          $$GoalTaskLinksTableOrderingComposer,
          $$GoalTaskLinksTableAnnotationComposer,
          $$GoalTaskLinksTableCreateCompanionBuilder,
          $$GoalTaskLinksTableUpdateCompanionBuilder,
          (GoalTaskLink, $$GoalTaskLinksTableReferences),
          GoalTaskLink,
          PrefetchHooks Function({bool goalId})
        > {
  $$GoalTaskLinksTableTableManager(_$AppDatabase db, $GoalTaskLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalTaskLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalTaskLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalTaskLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> goalId = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalTaskLinksCompanion(
                goalId: goalId,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int goalId,
                required int taskId,
                Value<int> rowid = const Value.absent(),
              }) => GoalTaskLinksCompanion.insert(
                goalId: goalId,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalTaskLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable: $$GoalTaskLinksTableReferences
                                    ._goalIdTable(db),
                                referencedColumn: $$GoalTaskLinksTableReferences
                                    ._goalIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalTaskLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalTaskLinksTable,
      GoalTaskLink,
      $$GoalTaskLinksTableFilterComposer,
      $$GoalTaskLinksTableOrderingComposer,
      $$GoalTaskLinksTableAnnotationComposer,
      $$GoalTaskLinksTableCreateCompanionBuilder,
      $$GoalTaskLinksTableUpdateCompanionBuilder,
      (GoalTaskLink, $$GoalTaskLinksTableReferences),
      GoalTaskLink,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$GoalHabitLinksTableCreateCompanionBuilder =
    GoalHabitLinksCompanion Function({
      required int goalId,
      required int habitId,
      Value<int> rowid,
    });
typedef $$GoalHabitLinksTableUpdateCompanionBuilder =
    GoalHabitLinksCompanion Function({
      Value<int> goalId,
      Value<int> habitId,
      Value<int> rowid,
    });

final class $$GoalHabitLinksTableReferences
    extends BaseReferences<_$AppDatabase, $GoalHabitLinksTable, GoalHabitLink> {
  $$GoalHabitLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias('goal_habit_links__goal_id__goals__id');

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalHabitLinksTableFilterComposer
    extends Composer<_$AppDatabase, $GoalHabitLinksTable> {
  $$GoalHabitLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalHabitLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalHabitLinksTable> {
  $$GoalHabitLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalHabitLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalHabitLinksTable> {
  $$GoalHabitLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalHabitLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalHabitLinksTable,
          GoalHabitLink,
          $$GoalHabitLinksTableFilterComposer,
          $$GoalHabitLinksTableOrderingComposer,
          $$GoalHabitLinksTableAnnotationComposer,
          $$GoalHabitLinksTableCreateCompanionBuilder,
          $$GoalHabitLinksTableUpdateCompanionBuilder,
          (GoalHabitLink, $$GoalHabitLinksTableReferences),
          GoalHabitLink,
          PrefetchHooks Function({bool goalId})
        > {
  $$GoalHabitLinksTableTableManager(
    _$AppDatabase db,
    $GoalHabitLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalHabitLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalHabitLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalHabitLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> goalId = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalHabitLinksCompanion(
                goalId: goalId,
                habitId: habitId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int goalId,
                required int habitId,
                Value<int> rowid = const Value.absent(),
              }) => GoalHabitLinksCompanion.insert(
                goalId: goalId,
                habitId: habitId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GoalHabitLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable: $$GoalHabitLinksTableReferences
                                    ._goalIdTable(db),
                                referencedColumn:
                                    $$GoalHabitLinksTableReferences
                                        ._goalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalHabitLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalHabitLinksTable,
      GoalHabitLink,
      $$GoalHabitLinksTableFilterComposer,
      $$GoalHabitLinksTableOrderingComposer,
      $$GoalHabitLinksTableAnnotationComposer,
      $$GoalHabitLinksTableCreateCompanionBuilder,
      $$GoalHabitLinksTableUpdateCompanionBuilder,
      (GoalHabitLink, $$GoalHabitLinksTableReferences),
      GoalHabitLink,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      required String title,
      Value<String> body,
      Value<bool> isPinned,
      Value<String?> aiLabel,
      required String timeLabel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> body,
      Value<bool> isPinned,
      Value<String?> aiLabel,
      Value<String> timeLabel,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTag>> _noteTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'notes__id__note_tags__note_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteTaskLinksTable, List<NoteTaskLink>>
  _noteTaskLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTaskLinks,
    aliasName: 'notes__id__note_task_links__note_id',
  );

  $$NoteTaskLinksTableProcessedTableManager get noteTaskLinksRefs {
    final manager = $$NoteTaskLinksTableTableManager(
      $_db,
      $_db.noteTaskLinks,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTaskLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteTaskLinksRefs(
    Expression<bool> Function($$NoteTaskLinksTableFilterComposer f) f,
  ) {
    final $$NoteTaskLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableFilterComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiLabel => $composableBuilder(
    column: $table.aiLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get aiLabel =>
      $composableBuilder(column: $table.aiLabel, builder: (column) => column);

  GeneratedColumn<String> get timeLabel =>
      $composableBuilder(column: $table.timeLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteTaskLinksRefs<T extends Object>(
    Expression<T> Function($$NoteTaskLinksTableAnnotationComposer a) f,
  ) {
    final $$NoteTaskLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTaskLinks,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTaskLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTaskLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool noteTagsRefs, bool noteTaskLinksRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<String?> aiLabel = const Value.absent(),
                Value<String> timeLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                body: body,
                isPinned: isPinned,
                aiLabel: aiLabel,
                timeLabel: timeLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> body = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<String?> aiLabel = const Value.absent(),
                required String timeLabel,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                body: body,
                isPinned: isPinned,
                aiLabel: aiLabel,
                timeLabel: timeLabel,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteTagsRefs = false, noteTaskLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteTagsRefs) db.noteTags,
                    if (noteTaskLinksRefs) db.noteTaskLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteTagsRefs)
                        await $_getPrefetchedData<Note, $NotesTable, NoteTag>(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteTaskLinksRefs)
                        await $_getPrefetchedData<
                          Note,
                          $NotesTable,
                          NoteTaskLink
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteTaskLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTaskLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.noteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool noteTagsRefs, bool noteTaskLinksRefs})
    >;
typedef $$NoteTagsTableCreateCompanionBuilder =
    NoteTagsCompanion Function({
      Value<int> id,
      required int noteId,
      required String label,
      required int bgColorValue,
      required int fgColorValue,
      Value<int> sortOrder,
    });
typedef $$NoteTagsTableUpdateCompanionBuilder =
    NoteTagsCompanion Function({
      Value<int> id,
      Value<int> noteId,
      Value<String> label,
      Value<int> bgColorValue,
      Value<int> fgColorValue,
      Value<int> sortOrder,
    });

final class $$NoteTagsTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTag> {
  $$NoteTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_tags__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bgColorValue => $composableBuilder(
    column: $table.bgColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fgColorValue => $composableBuilder(
    column: $table.fgColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bgColorValue => $composableBuilder(
    column: $table.bgColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fgColorValue => $composableBuilder(
    column: $table.fgColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get bgColorValue => $composableBuilder(
    column: $table.bgColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fgColorValue => $composableBuilder(
    column: $table.fgColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTagsTable,
          NoteTag,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTag, $$NoteTagsTableReferences),
          NoteTag,
          PrefetchHooks Function({bool noteId})
        > {
  $$NoteTagsTableTableManager(_$AppDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> bgColorValue = const Value.absent(),
                Value<int> fgColorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => NoteTagsCompanion(
                id: id,
                noteId: noteId,
                label: label,
                bgColorValue: bgColorValue,
                fgColorValue: fgColorValue,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int noteId,
                required String label,
                required int bgColorValue,
                required int fgColorValue,
                Value<int> sortOrder = const Value.absent(),
              }) => NoteTagsCompanion.insert(
                id: id,
                noteId: noteId,
                label: label,
                bgColorValue: bgColorValue,
                fgColorValue: fgColorValue,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NoteTagsTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NoteTagsTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTagsTable,
      NoteTag,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTag, $$NoteTagsTableReferences),
      NoteTag,
      PrefetchHooks Function({bool noteId})
    >;
typedef $$NoteTaskLinksTableCreateCompanionBuilder =
    NoteTaskLinksCompanion Function({
      required int noteId,
      required int taskId,
      Value<int> rowid,
    });
typedef $$NoteTaskLinksTableUpdateCompanionBuilder =
    NoteTaskLinksCompanion Function({
      Value<int> noteId,
      Value<int> taskId,
      Value<int> rowid,
    });

final class $$NoteTaskLinksTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTaskLinksTable, NoteTaskLink> {
  $$NoteTaskLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_task_links__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTaskLinksTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTaskLinksTable> {
  $$NoteTaskLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTaskLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTaskLinksTable,
          NoteTaskLink,
          $$NoteTaskLinksTableFilterComposer,
          $$NoteTaskLinksTableOrderingComposer,
          $$NoteTaskLinksTableAnnotationComposer,
          $$NoteTaskLinksTableCreateCompanionBuilder,
          $$NoteTaskLinksTableUpdateCompanionBuilder,
          (NoteTaskLink, $$NoteTaskLinksTableReferences),
          NoteTaskLink,
          PrefetchHooks Function({bool noteId})
        > {
  $$NoteTaskLinksTableTableManager(_$AppDatabase db, $NoteTaskLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTaskLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTaskLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTaskLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> noteId = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteTaskLinksCompanion(
                noteId: noteId,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int noteId,
                required int taskId,
                Value<int> rowid = const Value.absent(),
              }) => NoteTaskLinksCompanion.insert(
                noteId: noteId,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteTaskLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NoteTaskLinksTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NoteTaskLinksTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTaskLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTaskLinksTable,
      NoteTaskLink,
      $$NoteTaskLinksTableFilterComposer,
      $$NoteTaskLinksTableOrderingComposer,
      $$NoteTaskLinksTableAnnotationComposer,
      $$NoteTaskLinksTableCreateCompanionBuilder,
      $$NoteTaskLinksTableUpdateCompanionBuilder,
      (NoteTaskLink, $$NoteTaskLinksTableReferences),
      NoteTaskLink,
      PrefetchHooks Function({bool noteId})
    >;
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> subtitle,
      required String timeSlot,
      required int colorValue,
      Value<bool> isOverdue,
      Value<bool> isInvite,
      Value<DateTime?> eventDate,
      Value<DateTime> createdAt,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> subtitle,
      Value<String> timeSlot,
      Value<int> colorValue,
      Value<bool> isOverdue,
      Value<bool> isInvite,
      Value<DateTime?> eventDate,
      Value<DateTime> createdAt,
    });

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInvite => $composableBuilder(
    column: $table.isInvite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSlot => $composableBuilder(
    column: $table.timeSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOverdue => $composableBuilder(
    column: $table.isOverdue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInvite => $composableBuilder(
    column: $table.isInvite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get timeSlot =>
      $composableBuilder(column: $table.timeSlot, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOverdue =>
      $composableBuilder(column: $table.isOverdue, builder: (column) => column);

  GeneratedColumn<bool> get isInvite =>
      $composableBuilder(column: $table.isInvite, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEventsTable,
          CalendarEvent,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (
            CalendarEvent,
            BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>,
          ),
          CalendarEvent,
          PrefetchHooks Function()
        > {
  $$CalendarEventsTableTableManager(
    _$AppDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> timeSlot = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<bool> isOverdue = const Value.absent(),
                Value<bool> isInvite = const Value.absent(),
                Value<DateTime?> eventDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CalendarEventsCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                timeSlot: timeSlot,
                colorValue: colorValue,
                isOverdue: isOverdue,
                isInvite: isInvite,
                eventDate: eventDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> subtitle = const Value.absent(),
                required String timeSlot,
                required int colorValue,
                Value<bool> isOverdue = const Value.absent(),
                Value<bool> isInvite = const Value.absent(),
                Value<DateTime?> eventDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                timeSlot: timeSlot,
                colorValue: colorValue,
                isOverdue: isOverdue,
                isInvite: isInvite,
                eventDate: eventDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEventsTable,
      CalendarEvent,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (
        CalendarEvent,
        BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>,
      ),
      CalendarEvent,
      PrefetchHooks Function()
    >;
typedef $$CustomListsTableCreateCompanionBuilder =
    CustomListsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> emoji,
      Value<DateTime> createdAt,
      Value<int?> parentId,
      Value<DateTime?> dueDate,
      Value<String?> recurrenceLabel,
    });
typedef $$CustomListsTableUpdateCompanionBuilder =
    CustomListsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> emoji,
      Value<DateTime> createdAt,
      Value<int?> parentId,
      Value<DateTime?> dueDate,
      Value<String?> recurrenceLabel,
    });

final class $$CustomListsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomListsTable, CustomList> {
  $$CustomListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomListsTable _parentIdTable(_$AppDatabase db) =>
      db.customLists.createAlias('custom_lists__parent_id__custom_lists__id');

  $$CustomListsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$CustomListsTableTableManager(
      $_db,
      $_db.customLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CustomListItemsTable, List<CustomListItem>>
  _customListItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customListItems,
    aliasName: 'custom_lists__id__custom_list_items__list_id',
  );

  $$CustomListItemsTableProcessedTableManager get customListItemsRefs {
    final manager = $$CustomListItemsTableTableManager(
      $_db,
      $_db.customListItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customListItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomListsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomListsTableFilterComposer get parentId {
    final $$CustomListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableFilterComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> customListItemsRefs(
    Expression<bool> Function($$CustomListItemsTableFilterComposer f) f,
  ) {
    final $$CustomListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListItemsTableFilterComposer(
            $db: $db,
            $table: $db.customListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomListsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomListsTableOrderingComposer get parentId {
    final $$CustomListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableOrderingComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get recurrenceLabel => $composableBuilder(
    column: $table.recurrenceLabel,
    builder: (column) => column,
  );

  $$CustomListsTableAnnotationComposer get parentId {
    final $$CustomListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableAnnotationComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> customListItemsRefs<T extends Object>(
    Expression<T> Function($$CustomListItemsTableAnnotationComposer a) f,
  ) {
    final $$CustomListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.customListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomListsTable,
          CustomList,
          $$CustomListsTableFilterComposer,
          $$CustomListsTableOrderingComposer,
          $$CustomListsTableAnnotationComposer,
          $$CustomListsTableCreateCompanionBuilder,
          $$CustomListsTableUpdateCompanionBuilder,
          (CustomList, $$CustomListsTableReferences),
          CustomList,
          PrefetchHooks Function({bool parentId, bool customListItemsRefs})
        > {
  $$CustomListsTableTableManager(_$AppDatabase db, $CustomListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> recurrenceLabel = const Value.absent(),
              }) => CustomListsCompanion(
                id: id,
                title: title,
                emoji: emoji,
                createdAt: createdAt,
                parentId: parentId,
                dueDate: dueDate,
                recurrenceLabel: recurrenceLabel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> emoji = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> recurrenceLabel = const Value.absent(),
              }) => CustomListsCompanion.insert(
                id: id,
                title: title,
                emoji: emoji,
                createdAt: createdAt,
                parentId: parentId,
                dueDate: dueDate,
                recurrenceLabel: recurrenceLabel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentId = false, customListItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customListItemsRefs) db.customListItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable:
                                        $$CustomListsTableReferences
                                            ._parentIdTable(db),
                                    referencedColumn:
                                        $$CustomListsTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customListItemsRefs)
                        await $_getPrefetchedData<
                          CustomList,
                          $CustomListsTable,
                          CustomListItem
                        >(
                          currentTable: table,
                          referencedTable: $$CustomListsTableReferences
                              ._customListItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomListsTableReferences(
                                db,
                                table,
                                p0,
                              ).customListItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomListsTable,
      CustomList,
      $$CustomListsTableFilterComposer,
      $$CustomListsTableOrderingComposer,
      $$CustomListsTableAnnotationComposer,
      $$CustomListsTableCreateCompanionBuilder,
      $$CustomListsTableUpdateCompanionBuilder,
      (CustomList, $$CustomListsTableReferences),
      CustomList,
      PrefetchHooks Function({bool parentId, bool customListItemsRefs})
    >;
typedef $$CustomListItemsTableCreateCompanionBuilder =
    CustomListItemsCompanion Function({
      Value<int> id,
      required int listId,
      required String content,
      Value<bool> isDone,
      Value<int> sortOrder,
    });
typedef $$CustomListItemsTableUpdateCompanionBuilder =
    CustomListItemsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<String> content,
      Value<bool> isDone,
      Value<int> sortOrder,
    });

final class $$CustomListItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomListItemsTable, CustomListItem> {
  $$CustomListItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomListsTable _listIdTable(_$AppDatabase db) => db.customLists
      .createAlias('custom_list_items__list_id__custom_lists__id');

  $$CustomListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$CustomListsTableTableManager(
      $_db,
      $_db.customLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomListItemsTable> {
  $$CustomListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomListsTableFilterComposer get listId {
    final $$CustomListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableFilterComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomListItemsTable> {
  $$CustomListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomListsTableOrderingComposer get listId {
    final $$CustomListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableOrderingComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomListItemsTable> {
  $$CustomListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CustomListsTableAnnotationComposer get listId {
    final $$CustomListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableAnnotationComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomListItemsTable,
          CustomListItem,
          $$CustomListItemsTableFilterComposer,
          $$CustomListItemsTableOrderingComposer,
          $$CustomListItemsTableAnnotationComposer,
          $$CustomListItemsTableCreateCompanionBuilder,
          $$CustomListItemsTableUpdateCompanionBuilder,
          (CustomListItem, $$CustomListItemsTableReferences),
          CustomListItem,
          PrefetchHooks Function({bool listId})
        > {
  $$CustomListItemsTableTableManager(
    _$AppDatabase db,
    $CustomListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CustomListItemsCompanion(
                id: id,
                listId: listId,
                content: content,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required String content,
                Value<bool> isDone = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CustomListItemsCompanion.insert(
                id: id,
                listId: listId,
                content: content,
                isDone: isDone,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomListItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$CustomListItemsTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$CustomListItemsTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomListItemsTable,
      CustomListItem,
      $$CustomListItemsTableFilterComposer,
      $$CustomListItemsTableOrderingComposer,
      $$CustomListItemsTableAnnotationComposer,
      $$CustomListItemsTableCreateCompanionBuilder,
      $$CustomListItemsTableUpdateCompanionBuilder,
      (CustomListItem, $$CustomListItemsTableReferences),
      CustomListItem,
      PrefetchHooks Function({bool listId})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      required int taskId,
      required int quadrant,
      required DateTime startedAt,
      required int durationSeconds,
      Value<bool> completed,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<int> quadrant,
      Value<DateTime> startedAt,
      Value<int> durationSeconds,
      Value<bool> completed,
    });

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quadrant => $composableBuilder(
    column: $table.quadrant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get quadrant =>
      $composableBuilder(column: $table.quadrant, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (
            FocusSession,
            BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession>,
          ),
          FocusSession,
          PrefetchHooks Function()
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<int> quadrant = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                taskId: taskId,
                quadrant: quadrant,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required int quadrant,
                required DateTime startedAt,
                required int durationSeconds,
                Value<bool> completed = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                taskId: taskId,
                quadrant: quadrant,
                startedAt: startedAt,
                durationSeconds: durationSeconds,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (
        FocusSession,
        BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession>,
      ),
      FocusSession,
      PrefetchHooks Function()
    >;
typedef $$KaalDatabasesTableCreateCompanionBuilder =
    KaalDatabasesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<String> defaultView,
      Value<String?> boardGroupProp,
      Value<DateTime> createdAt,
    });
typedef $$KaalDatabasesTableUpdateCompanionBuilder =
    KaalDatabasesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<String> defaultView,
      Value<String?> boardGroupProp,
      Value<DateTime> createdAt,
    });

final class $$KaalDatabasesTableReferences
    extends BaseReferences<_$AppDatabase, $KaalDatabasesTable, KaalDatabase> {
  $$KaalDatabasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$DbPropertiesTable, List<DbProperty>>
  _dbPropertiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dbProperties,
    aliasName: 'kaal_databases__id__db_properties__database_id',
  );

  $$DbPropertiesTableProcessedTableManager get dbPropertiesRefs {
    final manager = $$DbPropertiesTableTableManager(
      $_db,
      $_db.dbProperties,
    ).filter((f) => f.databaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbPropertiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DbRowsTable, List<DbRow>> _dbRowsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.dbRows,
    aliasName: 'kaal_databases__id__db_rows__database_id',
  );

  $$DbRowsTableProcessedTableManager get dbRowsRefs {
    final manager = $$DbRowsTableTableManager(
      $_db,
      $_db.dbRows,
    ).filter((f) => f.databaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_dbRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$KaalDatabasesTableFilterComposer
    extends Composer<_$AppDatabase, $KaalDatabasesTable> {
  $$KaalDatabasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultView => $composableBuilder(
    column: $table.defaultView,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardGroupProp => $composableBuilder(
    column: $table.boardGroupProp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dbPropertiesRefs(
    Expression<bool> Function($$DbPropertiesTableFilterComposer f) f,
  ) {
    final $$DbPropertiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbProperties,
      getReferencedColumn: (t) => t.databaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPropertiesTableFilterComposer(
            $db: $db,
            $table: $db.dbProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dbRowsRefs(
    Expression<bool> Function($$DbRowsTableFilterComposer f) f,
  ) {
    final $$DbRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbRows,
      getReferencedColumn: (t) => t.databaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbRowsTableFilterComposer(
            $db: $db,
            $table: $db.dbRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KaalDatabasesTableOrderingComposer
    extends Composer<_$AppDatabase, $KaalDatabasesTable> {
  $$KaalDatabasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultView => $composableBuilder(
    column: $table.defaultView,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardGroupProp => $composableBuilder(
    column: $table.boardGroupProp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KaalDatabasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KaalDatabasesTable> {
  $$KaalDatabasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get defaultView => $composableBuilder(
    column: $table.defaultView,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boardGroupProp => $composableBuilder(
    column: $table.boardGroupProp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> dbPropertiesRefs<T extends Object>(
    Expression<T> Function($$DbPropertiesTableAnnotationComposer a) f,
  ) {
    final $$DbPropertiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbProperties,
      getReferencedColumn: (t) => t.databaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbPropertiesTableAnnotationComposer(
            $db: $db,
            $table: $db.dbProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> dbRowsRefs<T extends Object>(
    Expression<T> Function($$DbRowsTableAnnotationComposer a) f,
  ) {
    final $$DbRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dbRows,
      getReferencedColumn: (t) => t.databaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DbRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.dbRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KaalDatabasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KaalDatabasesTable,
          KaalDatabase,
          $$KaalDatabasesTableFilterComposer,
          $$KaalDatabasesTableOrderingComposer,
          $$KaalDatabasesTableAnnotationComposer,
          $$KaalDatabasesTableCreateCompanionBuilder,
          $$KaalDatabasesTableUpdateCompanionBuilder,
          (KaalDatabase, $$KaalDatabasesTableReferences),
          KaalDatabase,
          PrefetchHooks Function({bool dbPropertiesRefs, bool dbRowsRefs})
        > {
  $$KaalDatabasesTableTableManager(_$AppDatabase db, $KaalDatabasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KaalDatabasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KaalDatabasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KaalDatabasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> defaultView = const Value.absent(),
                Value<String?> boardGroupProp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => KaalDatabasesCompanion(
                id: id,
                name: name,
                icon: icon,
                defaultView: defaultView,
                boardGroupProp: boardGroupProp,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> defaultView = const Value.absent(),
                Value<String?> boardGroupProp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => KaalDatabasesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                defaultView: defaultView,
                boardGroupProp: boardGroupProp,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$KaalDatabasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dbPropertiesRefs = false, dbRowsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (dbPropertiesRefs) db.dbProperties,
                    if (dbRowsRefs) db.dbRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (dbPropertiesRefs)
                        await $_getPrefetchedData<
                          KaalDatabase,
                          $KaalDatabasesTable,
                          DbProperty
                        >(
                          currentTable: table,
                          referencedTable: $$KaalDatabasesTableReferences
                              ._dbPropertiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KaalDatabasesTableReferences(
                                db,
                                table,
                                p0,
                              ).dbPropertiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.databaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dbRowsRefs)
                        await $_getPrefetchedData<
                          KaalDatabase,
                          $KaalDatabasesTable,
                          DbRow
                        >(
                          currentTable: table,
                          referencedTable: $$KaalDatabasesTableReferences
                              ._dbRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KaalDatabasesTableReferences(
                                db,
                                table,
                                p0,
                              ).dbRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.databaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$KaalDatabasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KaalDatabasesTable,
      KaalDatabase,
      $$KaalDatabasesTableFilterComposer,
      $$KaalDatabasesTableOrderingComposer,
      $$KaalDatabasesTableAnnotationComposer,
      $$KaalDatabasesTableCreateCompanionBuilder,
      $$KaalDatabasesTableUpdateCompanionBuilder,
      (KaalDatabase, $$KaalDatabasesTableReferences),
      KaalDatabase,
      PrefetchHooks Function({bool dbPropertiesRefs, bool dbRowsRefs})
    >;
typedef $$DbPropertiesTableCreateCompanionBuilder =
    DbPropertiesCompanion Function({
      required String id,
      required int databaseId,
      required String name,
      Value<String> type,
      Value<String> config,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$DbPropertiesTableUpdateCompanionBuilder =
    DbPropertiesCompanion Function({
      Value<String> id,
      Value<int> databaseId,
      Value<String> name,
      Value<String> type,
      Value<String> config,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$DbPropertiesTableReferences
    extends BaseReferences<_$AppDatabase, $DbPropertiesTable, DbProperty> {
  $$DbPropertiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KaalDatabasesTable _databaseIdTable(_$AppDatabase db) => db
      .kaalDatabases
      .createAlias('db_properties__database_id__kaal_databases__id');

  $$KaalDatabasesTableProcessedTableManager get databaseId {
    final $_column = $_itemColumn<int>('database_id')!;

    final manager = $$KaalDatabasesTableTableManager(
      $_db,
      $_db.kaalDatabases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_databaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbPropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $DbPropertiesTable> {
  $$DbPropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$KaalDatabasesTableFilterComposer get databaseId {
    final $$KaalDatabasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableFilterComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $DbPropertiesTable> {
  $$DbPropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$KaalDatabasesTableOrderingComposer get databaseId {
    final $$KaalDatabasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableOrderingComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbPropertiesTable> {
  $$DbPropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$KaalDatabasesTableAnnotationComposer get databaseId {
    final $$KaalDatabasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableAnnotationComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbPropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbPropertiesTable,
          DbProperty,
          $$DbPropertiesTableFilterComposer,
          $$DbPropertiesTableOrderingComposer,
          $$DbPropertiesTableAnnotationComposer,
          $$DbPropertiesTableCreateCompanionBuilder,
          $$DbPropertiesTableUpdateCompanionBuilder,
          (DbProperty, $$DbPropertiesTableReferences),
          DbProperty,
          PrefetchHooks Function({bool databaseId})
        > {
  $$DbPropertiesTableTableManager(_$AppDatabase db, $DbPropertiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbPropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbPropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbPropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> databaseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPropertiesCompanion(
                id: id,
                databaseId: databaseId,
                name: name,
                type: type,
                config: config,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int databaseId,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbPropertiesCompanion.insert(
                id: id,
                databaseId: databaseId,
                name: name,
                type: type,
                config: config,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DbPropertiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({databaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (databaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.databaseId,
                                referencedTable: $$DbPropertiesTableReferences
                                    ._databaseIdTable(db),
                                referencedColumn: $$DbPropertiesTableReferences
                                    ._databaseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbPropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbPropertiesTable,
      DbProperty,
      $$DbPropertiesTableFilterComposer,
      $$DbPropertiesTableOrderingComposer,
      $$DbPropertiesTableAnnotationComposer,
      $$DbPropertiesTableCreateCompanionBuilder,
      $$DbPropertiesTableUpdateCompanionBuilder,
      (DbProperty, $$DbPropertiesTableReferences),
      DbProperty,
      PrefetchHooks Function({bool databaseId})
    >;
typedef $$DbRowsTableCreateCompanionBuilder =
    DbRowsCompanion Function({
      required String id,
      required int databaseId,
      Value<String> cells,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DbRowsTableUpdateCompanionBuilder =
    DbRowsCompanion Function({
      Value<String> id,
      Value<int> databaseId,
      Value<String> cells,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DbRowsTableReferences
    extends BaseReferences<_$AppDatabase, $DbRowsTable, DbRow> {
  $$DbRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KaalDatabasesTable _databaseIdTable(_$AppDatabase db) =>
      db.kaalDatabases.createAlias('db_rows__database_id__kaal_databases__id');

  $$KaalDatabasesTableProcessedTableManager get databaseId {
    final $_column = $_itemColumn<int>('database_id')!;

    final manager = $$KaalDatabasesTableTableManager(
      $_db,
      $_db.kaalDatabases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_databaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DbRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DbRowsTable> {
  $$DbRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$KaalDatabasesTableFilterComposer get databaseId {
    final $$KaalDatabasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableFilterComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DbRowsTable> {
  $$DbRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cells => $composableBuilder(
    column: $table.cells,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$KaalDatabasesTableOrderingComposer get databaseId {
    final $$KaalDatabasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableOrderingComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbRowsTable> {
  $$DbRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cells =>
      $composableBuilder(column: $table.cells, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$KaalDatabasesTableAnnotationComposer get databaseId {
    final $$KaalDatabasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.databaseId,
      referencedTable: $db.kaalDatabases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KaalDatabasesTableAnnotationComposer(
            $db: $db,
            $table: $db.kaalDatabases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DbRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbRowsTable,
          DbRow,
          $$DbRowsTableFilterComposer,
          $$DbRowsTableOrderingComposer,
          $$DbRowsTableAnnotationComposer,
          $$DbRowsTableCreateCompanionBuilder,
          $$DbRowsTableUpdateCompanionBuilder,
          (DbRow, $$DbRowsTableReferences),
          DbRow,
          PrefetchHooks Function({bool databaseId})
        > {
  $$DbRowsTableTableManager(_$AppDatabase db, $DbRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> databaseId = const Value.absent(),
                Value<String> cells = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbRowsCompanion(
                id: id,
                databaseId: databaseId,
                cells: cells,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int databaseId,
                Value<String> cells = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbRowsCompanion.insert(
                id: id,
                databaseId: databaseId,
                cells: cells,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DbRowsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({databaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (databaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.databaseId,
                                referencedTable: $$DbRowsTableReferences
                                    ._databaseIdTable(db),
                                referencedColumn: $$DbRowsTableReferences
                                    ._databaseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DbRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbRowsTable,
      DbRow,
      $$DbRowsTableFilterComposer,
      $$DbRowsTableOrderingComposer,
      $$DbRowsTableAnnotationComposer,
      $$DbRowsTableCreateCompanionBuilder,
      $$DbRowsTableUpdateCompanionBuilder,
      (DbRow, $$DbRowsTableReferences),
      DbRow,
      PrefetchHooks Function({bool databaseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$SubHabitsTableTableManager get subHabits =>
      $$SubHabitsTableTableManager(_db, _db.subHabits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$GoalTaskLinksTableTableManager get goalTaskLinks =>
      $$GoalTaskLinksTableTableManager(_db, _db.goalTaskLinks);
  $$GoalHabitLinksTableTableManager get goalHabitLinks =>
      $$GoalHabitLinksTableTableManager(_db, _db.goalHabitLinks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$NoteTaskLinksTableTableManager get noteTaskLinks =>
      $$NoteTaskLinksTableTableManager(_db, _db.noteTaskLinks);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$CustomListsTableTableManager get customLists =>
      $$CustomListsTableTableManager(_db, _db.customLists);
  $$CustomListItemsTableTableManager get customListItems =>
      $$CustomListItemsTableTableManager(_db, _db.customListItems);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$KaalDatabasesTableTableManager get kaalDatabases =>
      $$KaalDatabasesTableTableManager(_db, _db.kaalDatabases);
  $$DbPropertiesTableTableManager get dbProperties =>
      $$DbPropertiesTableTableManager(_db, _db.dbProperties);
  $$DbRowsTableTableManager get dbRows =>
      $$DbRowsTableTableManager(_db, _db.dbRows);
}
