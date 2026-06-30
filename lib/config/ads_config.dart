import 'dart:io' show Platform;

/// AdMob configuration for Kaal's free-plan ads.
///
/// Ads are shown to free users only (Pro is ad-free) and only on Android/iOS —
/// google_mobile_ads has no desktop/web support, so the ad layer no-ops there.
///
/// While [useTestAds] is true the official Google **test** unit IDs are used, so
/// you can develop without risking your AdMob account. Before release:
///   1. Create an AdMob app + ad units (console.admob.com).
///   2. Paste the real IDs into the `_prod*` constants below.
///   3. Set [useTestAds] = false.
///   4. Put the real **app ID** in AndroidManifest.xml (and iOS Info.plist).
abstract final class AdsConfig {
  /// Master switch — flip to false to disable all ads app-wide.
  static const bool enabled = true;

  /// Use Google's sample ad units (safe for development). Set false for release.
  static const bool useTestAds = true;

  // ── Test IDs (Google-provided, always safe to load) ─────────────────────────
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos     = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid     = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos         = 'ca-app-pub-3940256099942544/1712485313';

  // ── Production IDs — REPLACE before going live ──────────────────────────────
  static const _prodInterstitialAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _prodInterstitialIos     = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _prodRewardedAndroid     = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _prodRewardedIos         = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static bool get _ios => Platform.isIOS;

  static String get interstitialUnitId => useTestAds
      ? (_ios ? _testInterstitialIos : _testInterstitialAndroid)
      : (_ios ? _prodInterstitialIos : _prodInterstitialAndroid);

  static String get rewardedUnitId => useTestAds
      ? (_ios ? _testRewardedIos : _testRewardedAndroid)
      : (_ios ? _prodRewardedIos : _prodRewardedAndroid);

  /// Minimum gap between interstitials, so we never spam the user. A free user
  /// sees at most one interstitial every 2 hours (and only on a tab-switch).
  static const Duration interstitialMinGap = Duration(hours: 2);
}
