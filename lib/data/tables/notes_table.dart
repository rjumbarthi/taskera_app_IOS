import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get aiLabel => text().nullable()(); // "✦ AI summary"
  TextColumn get timeLabel => text()(); // "2h ago", "6d ago"
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class NoteTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  IntColumn get bgColorValue => integer()();
  IntColumn get fgColorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
