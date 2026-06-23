// Web is not a shipping target; drift/web is the only DB backend available for
// it and remains in bugfix-only mode. Suppress its deprecation here.
// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase openDatabaseConnection() {
  return LazyDatabase(() async => WebDatabase('kaal'));
}

Future<void> deleteDatabaseFile() async {}
