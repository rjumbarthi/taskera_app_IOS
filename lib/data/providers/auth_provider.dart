import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../settings/prefs_provider.dart';

/// Streams every auth state change (signed-in, signed-out, token refreshed…).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// The currently signed-in user, or null when not authenticated.
final currentUserProvider = Provider<User?>((ref) {
  // Re-reads whenever authStateProvider emits.
  ref.watch(authStateProvider);
  return Supabase.instance.client.auth.currentUser;
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Profile image path — persisted in SharedPreferences.
class ProfileImageNotifier extends Notifier<String?> {
  static const _key = 'kaal.profileImagePath';

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key);
  }

  Future<void> setPath(String path) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, path);
    state = path;
  }

  Future<void> clear() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
    state = null;
  }
}

final profileImagePathProvider =
    NotifierProvider<ProfileImageNotifier, String?>(ProfileImageNotifier.new);

// Profile avatar colour index (0–7, maps to _kAvatarColors in edit_profile_screen).
class ProfileAvatarColorNotifier extends Notifier<int> {
  static const _key = 'kaal.profileAvatarColor';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> setColor(int index) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_key, index);
    state = index;
  }
}

final profileAvatarColorProvider =
    NotifierProvider<ProfileAvatarColorNotifier, int>(ProfileAvatarColorNotifier.new);

// Profile avatar logo index (null = show initials/image, 0–7 = logo from _kLogos).
class ProfileAvatarLogoNotifier extends Notifier<int?> {
  static const _key = 'kaal.profileAvatarLogo';

  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final v = prefs.getInt(_key);
    return v == -1 ? null : v;
  }

  Future<void> setLogo(int? index) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_key, index ?? -1);
    state = index;
  }
}

final profileAvatarLogoProvider =
    NotifierProvider<ProfileAvatarLogoNotifier, int?>(ProfileAvatarLogoNotifier.new);

// Locally-persisted display name (overrides Supabase metadata when set).
class ProfileDisplayNameNotifier extends Notifier<String?> {
  static const _key = 'kaal.profileDisplayName';

  @override
  String? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getString(_key);
  }

  Future<void> setName(String name) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (name.isEmpty) {
      await prefs.remove(_key);
      state = null;
    } else {
      await prefs.setString(_key, name);
      state = name;
    }
  }
}

final profileDisplayNameProvider =
    NotifierProvider<ProfileDisplayNameNotifier, String?>(ProfileDisplayNameNotifier.new);

/// Display name — local SharedPreferences name first, then Supabase metadata, then email prefix.
final displayNameProvider = Provider<String?>((ref) {
  final local = ref.watch(profileDisplayNameProvider);
  if (local != null && local.isNotEmpty) return local;
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return (user.userMetadata?['full_name'] as String?) ??
      (user.userMetadata?['name'] as String?) ??
      user.email?.split('@').first;
});
