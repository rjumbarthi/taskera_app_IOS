import 'package:drift/drift.dart';

// Web is no longer a supported target. This stub only exists so the conditional
// export in db_connection.dart still resolves; it is never compiled for the
// native (Android/iOS/Windows) builds.
LazyDatabase openDatabaseConnection() =>
    throw UnsupportedError('Kaal does not support the web platform.');

Future<void> deleteDatabaseFile() async {}
