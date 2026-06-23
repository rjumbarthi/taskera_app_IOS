import 'package:drift/drift.dart';

class CalendarEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  TextColumn get timeSlot => text()(); // "9 AM", "2 PM"
  IntColumn get colorValue => integer()(); // ARGB int
  BoolColumn get isOverdue => boolean().withDefault(const Constant(false))();
  BoolColumn get isInvite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get eventDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
