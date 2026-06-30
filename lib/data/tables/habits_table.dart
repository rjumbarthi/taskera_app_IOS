import 'package:drift/drift.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get emoji => text()();
  TextColumn get name => text()();
  TextColumn get frequencyLabel => text()(); // "Mon · Wed · Fri · 60 min · Q2"
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get scheduledTime => integer().nullable()(); // minutes from midnight (0–1439)
  IntColumn get quadrant => integer().withDefault(const Constant(2))();
  TextColumn get streakLabel => text()(); // "🔥 14d"
  IntColumn get streakColorValue => integer()(); // ARGB int
  IntColumn get accentColorValue => integer()(); // ARGB int
  IntColumn get weeklyFilledCount => integer().withDefault(const Constant(0))(); // 0–7
  TextColumn get subLabel => text().nullable()(); // e.g. "Today's routine"
  TextColumn get notes => text().nullable()(); // freeform user notes — surfaced in Notes
  DateTimeColumn get lastCheckedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SubHabits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// One row per habit per day — isDone=false means skipped (streak protected).
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  // Stored as local midnight so .day comparisons work correctly.
  DateTimeColumn get logDate => dateTime()();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, logDate}
      ];
}
