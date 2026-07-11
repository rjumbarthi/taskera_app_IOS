import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Hardened, shared [FlutterSecureStorage] used by every token/secret store.
///
/// - **Android:** `encryptedSharedPreferences` routes secrets through
///   EncryptedSharedPreferences (AES-256 GCM, key wrapped by the Android
///   Keystore) instead of the weaker default backend.
/// - **iOS/macOS:** keychain items are only readable after the first device
///   unlock and are `ThisDeviceOnly`, so they never sync to iCloud Keychain or
///   restore onto a different device.
///
/// Use `kSecureStorage` everywhere instead of `const FlutterSecureStorage()`.
const kSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
