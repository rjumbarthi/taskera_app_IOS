import 'package:drift/drift.dart';

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emoji => text()();
  TextColumn get emojiBg => text()(); // sentinel string e.g. "0x14q2" or "0x1ABF5AF2"
  TextColumn get title => text()();
  TextColumn get subtitle => text()(); // "42 days left · Q2 focus"
  RealColumn get progressPct => real().withDefault(const Constant(0.0))();
  IntColumn get accentColorValue => integer()();
  IntColumn get barColorValue => integer()();
  IntColumn get borderColorValue => integer()();
  TextColumn get linkedLabel => text()(); // "LINKED Q2 TASKS · 6/10"
  TextColumn get linkType => text().withDefault(const Constant('task'))(); // "task" | "habit"
  IntColumn get dotColorValue => integer()();
  DateTimeColumn get createdAt  => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deadline   => dateTime().nullable()();
  TextColumn     get milestones => text().withDefault(const Constant(''))();
  TextColumn     get notes      => text().nullable()(); // freeform user notes — surfaced in Notes
}

class GoalTaskLinks extends Table {
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  IntColumn get taskId => integer()();

  @override
  Set<Column> get primaryKey => {goalId, taskId};
}

class GoalHabitLinks extends Table {
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  IntColumn get habitId => integer()();

  @override
  Set<Column> get primaryKey => {goalId, habitId};
}
