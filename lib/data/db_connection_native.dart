import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

LazyDatabase openDatabaseConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaal.db');
    return NativeDatabase.createInBackground(file);
  });
}

Future<void> deleteDatabaseFile() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/kaal.db');
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
