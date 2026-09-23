import 'package:drift/drift.dart';

/// A Notion-style database: a named collection of rows described by a set of
/// typed properties (columns), renderable as table / board / list views.
class TaskEraDatabases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant('Untitled'))();
  TextColumn get icon => text().withDefault(const Constant('🗂️'))();

  /// table | board | list
  TextColumn get defaultView => text().withDefault(const Constant('table'))();

  /// Property id used to group the board view (a select/status column).
  TextColumn get boardGroupProp => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// A column definition for a [TaskEraDatabases] row. `id` is a client-generated
/// string so row cells can reference it stably across renames.
class DbProperties extends Table {
  TextColumn get id => text()();
  IntColumn get databaseId =>
      integer().references(TaskEraDatabases, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();

  /// text | number | select | multiSelect | date | checkbox | url
  TextColumn get type => text().withDefault(const Constant('text'))();

  /// JSON config. For select/multiSelect: `{"options":[{"name":..,"color":..}]}`.
  TextColumn get config => text().withDefault(const Constant('{}'))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single record in a database. Cell values are stored as a JSON map keyed by
/// property id (`{"<propId>": <value>}`) — flexible and cheap for a local-first
/// model where filtering/sorting happens in Dart.
class DbRows extends Table {
  TextColumn get id => text()();
  IntColumn get databaseId =>
      integer().references(TaskEraDatabases, #id, onDelete: KeyAction.cascade)();
  TextColumn get cells => text().withDefault(const Constant('{}'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
