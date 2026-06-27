import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppLaunchPrefs {
  static const _onboardingDone = 'kaal.onboardingDone';
  static const _skipAuth       = 'kaal.skipAuth';
  static const _installDate    = 'kaal.installDate';
  static const _lastActive     = 'kaal.lastActiveAt';

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

  // ── Last-active tracking — used to suppress the splash on quick re-launch ─────
  // Written when the app is backgrounded; read on cold start to tell a genuine
  // fresh start (show splash) from Android killing us while backgrounded and the
  // user reopening (skip splash — feels like a resume).
  static Future<void> recordActive(SharedPreferences p) =>
      p.setInt(_lastActive, DateTime.now().millisecondsSinceEpoch);

  static bool wasActiveWithin(SharedPreferences p, Duration within) {
    final ms = p.getInt(_lastActive);
    if (ms == null) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime.now().difference(last) < within;
  }

  /// True when this cold start is a quick same-day reopen — last active was less
  /// than [within] ago AND on the same calendar day as now. Used to skip the
  /// splash: a new calendar day or an idle gap ≥ [within] both show it again.
  static bool wasActiveSameDayWithin(SharedPreferences p, Duration within) {
    final ms = p.getInt(_lastActive);
    if (ms == null) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(ms);
    final now  = DateTime.now();
    if (now.difference(last) >= within) return false; // idle too long → splash
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day; // different calendar day → splash
  }
}
