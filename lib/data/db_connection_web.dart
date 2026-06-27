import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web database backend. Uses drift's modern WASM backend, which runs SQLite
/// (`sqlite3.wasm`) inside a web worker (`drift_worker.js`) and persists to the
/// best storage the browser supports (OPFS → IndexedDB). Both asset files live
/// in `web/` and are served alongside the app.
LazyDatabase openDatabaseConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'kaal',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}

Future<void> deleteDatabaseFile() async {
  // Web persistence lives in the browser (OPFS/IndexedDB); nothing to delete
  // from a file system here.
}
