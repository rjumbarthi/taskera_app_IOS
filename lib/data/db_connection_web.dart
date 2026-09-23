import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web database backend (Drift on sqlite3 compiled to WebAssembly).
///
/// Requires two assets served from the web root (see `web/`):
///   - `sqlite3.wasm`      — sqlite3 compiled to WASM
///   - `drift_worker.js`   — drift's shared worker
///
/// `WasmDatabase.open` transparently picks the best available persistence
/// backend for the browser (OPFS → IndexedDB → in-memory) so the same
/// `taskera_db` name survives reloads wherever the browser allows it.
LazyDatabase openDatabaseConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'taskera_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}

/// No-op on web — persistence is managed by the browser, and the native
/// "wipe demo data on upgrade" file deletion has no filesystem to act on.
Future<void> deleteDatabaseFile() async {}
