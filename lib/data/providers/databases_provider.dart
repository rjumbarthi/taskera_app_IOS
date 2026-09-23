import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// All databases, newest first.
final databasesProvider = StreamProvider<List<TaskEraDatabase>>((ref) {
  return ref.watch(appDatabaseProvider).databasesDao.watchDatabases();
});

/// A single database by id.
final databaseProvider =
    StreamProvider.family<TaskEraDatabase?, int>((ref, id) {
  return ref.watch(appDatabaseProvider).databasesDao.watchDatabase(id);
});

/// Properties (columns) of a database, ordered.
final dbPropertiesProvider =
    StreamProvider.family<List<DbProperty>, int>((ref, dbId) {
  return ref.watch(appDatabaseProvider).databasesDao.watchProperties(dbId);
});

/// Rows of a database, ordered.
final dbRowsProvider =
    StreamProvider.family<List<DbRow>, int>((ref, dbId) {
  return ref.watch(appDatabaseProvider).databasesDao.watchRows(dbId);
});

/// Every row across all databases — for global search.
final allDbRowsProvider = StreamProvider<List<DbRow>>((ref) {
  return ref.watch(appDatabaseProvider).databasesDao.watchAllRows();
});

/// Every property across all databases — for resolving row titles in search.
final allDbPropertiesProvider = StreamProvider<List<DbProperty>>((ref) {
  return ref.watch(appDatabaseProvider).databasesDao.watchAllProperties();
});
