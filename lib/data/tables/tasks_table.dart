import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get quadrant => integer()(); // 1–4
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get dueLabel => text().nullable()(); // display string e.g. "Today · Score 9.2"
  BoolColumn get isOverdue => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAi => boolean().withDefault(const Constant(false))();
  RealColumn get urgencyScore => real().nullable()();
  TextColumn get recurrenceLabel => text().nullable()(); // e.g. "↻ Daily"
  BoolColumn get hasPomodoro => boolean().withDefault(const Constant(false))();
  TextColumn get priority => text().nullable()(); // "P1" | "P2" | "P3" | "P4"
  TextColumn get notes => text().nullable()();
  IntColumn  get timeAllocatedMin => integer().nullable()(); // minutes allocated for task
  RealColumn get goalWeight => real().nullable()(); // Attention Score component 0–10
  RealColumn get urgency    => real().nullable()(); // Attention Score component 0–10
  RealColumn get impact     => real().nullable()(); // Attention Score component 0–10
  RealColumn get focusFit   => real().nullable()(); // Attention Score component 0–10
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get doneAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Accumulated focus time logged against this task (seconds).
  IntColumn get totalFocusSeconds => integer().withDefault(const Constant(0))();
  // Comma-separated user labels/tags, e.g. "work,health". Null = none.
  TextColumn get labels => text().nullable()();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
