import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppLaunchPrefs {
  static const _onboardingDone = 'kaal.onboardingDone';
  static const _skipAuth       = 'kaal.skipAuth';
  static const _installDate    = 'kaal.installDate';

  // ── Onboarding profile (written once on finish, read-only after) ─────────────
  static const _kRole  = 'kaal.profile.role';
  static const _kFocus = 'kaal.profile.focus';
  static const _kPeak  = 'kaal.profile.peak';

  static Future<void> saveProfile(
    SharedPreferences p, {
    int? role,
    int? focus,
    int? peak,
  }) async {
    if (role  != null) await p.setInt(_kRole,  role);
    if (focus != null) await p.setInt(_kFocus, focus);
    if (peak  != null) await p.setInt(_kPeak,  peak);
  }

  static int? profileRole(SharedPreferences p)  => p.getInt(_kRole);
  static int? profileFocus(SharedPreferences p) => p.getInt(_kFocus);
  static int? profilePeak(SharedPreferences p)  => p.getInt(_kPeak);

  static bool onboardingDone(SharedPreferences p) => p.getBool(_onboardingDone) ?? false;
  static bool skipAuth(SharedPreferences p)       => p.getBool(_skipAuth)       ?? false;

  static Future<void> completeOnboarding(SharedPreferences p) =>
      p.setBool(_onboardingDone, true);

  static Future<void> markSkipAuth(SharedPreferences p) =>
      p.setBool(_skipAuth, true);

  // Records the first-launch date once; never overwrites.
  static Future<void> recordInstallDate(SharedPreferences p) async {
    if (p.getInt(_installDate) == null) {
      await p.setInt(_installDate, DateTime.now().millisecondsSinceEpoch);
    }
  }

  static DateTime? installDate(SharedPreferences p) {
    final ms = p.getInt(_installDate);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static int daysSinceInstall(SharedPreferences p) {
    final d = installDate(p);
    if (d == null) return 0;
    return DateTime.now().difference(d).inDays;
  }
}
