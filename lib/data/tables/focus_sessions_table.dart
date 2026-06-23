import 'package:drift/drift.dart';

// One row per completed/aborted focus session.
// Shape: { taskId, quadrant, startedAt, durationSeconds, completed }.
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer()();
  IntColumn get quadrant => integer()(); // 1–4
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}
