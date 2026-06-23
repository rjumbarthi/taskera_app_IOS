import 'package:drift/drift.dart';

class CustomLists extends Table {
  IntColumn     get id       => integer().autoIncrement()();
  TextColumn    get title    => text()();
  TextColumn    get emoji    => text().withDefault(const Constant('📋'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn      get parentId => integer().nullable().references(CustomLists, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get dueDate        => dateTime().nullable()();
  TextColumn     get recurrenceLabel => text().nullable()();
}

class CustomListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(CustomLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
