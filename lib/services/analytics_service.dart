import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Lightweight, vendor-agnostic product analytics over PostHog's HTTP capture
/// API. Works on every target (Android / iOS / Windows) with no native SDK, so
/// there's no platform gap. Deliberately coarse-grained: no per-screen/nav
/// tracking (too noisy, and not something we act on) — just explicit [capture]
/// events plus a settings snapshot throttled to ~once/day per user.
///
/// Privacy: disabled when the user opts out (Settings → Privacy), and a no-op
/// until a real PostHog key is set in [AppConfig]. It never throws into the app
/// and never blocks the UI — every network failure is swallowed.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const _anonKey = 'taskera.analytics.anonId';
  // Last snapshot actually sent (its JSON encoding) and when — together these
  // let us send only on a real change, or at most once/day as a heartbeat if
  // nothing changed in that time. No change + <24h since last send = no event.
  static const _lastSnapshotJsonKey = 'taskera.analytics.lastSettingsSnapshotJson';
  static const _lastSnapshotAtKey = 'taskera.analytics.lastSettingsSnapshotAt';
  static const _snapshotHeartbeat = Duration(days: 1);

  final _client = http.Client();
  SharedPreferences? _prefs;
  String _anonId = '';
  String _distinctId = '';
  bool _enabled = true;
  bool _initialised = false;
  Timer? _settingsDebounce;

  bool get _configured =>
      AppConfig.posthogApiKey.isNotEmpty &&
      !AppConfig.posthogApiKey.startsWith('YOUR_');

  /// Loads (or mints) a stable anonymous id. Call once at startup.
  Future<void> init(SharedPreferences prefs) async {
    if (_initialised) return;
    _initialised = true;
    _prefs = prefs;
    var anon = prefs.getString(_anonKey);
    if (anon == null || anon.isEmpty) {
      anon = _randomId();
      await prefs.setString(_anonKey, anon);
    }
    _anonId = anon;
    _distinctId = anon;
  }

  /// Honor the Settings → Privacy opt-out.
  void setEnabled(bool value) => _enabled = value;

  /// Tie subsequent events to the signed-in user.
  void identify(String userId) {
    if (userId.isNotEmpty) _distinctId = userId;
  }

  /// Revert to the anonymous id (call on sign-out).
  void resetIdentity() {
    if (_anonId.isNotEmpty) _distinctId = _anonId;
  }

  /// Fire an arbitrary product event. Fire-and-forget.
  Future<void> capture(String event, {Map<String, dynamic>? props}) async {
    if (!_enabled || !_configured || _distinctId.isEmpty) return;
    final payload = <String, dynamic>{
      'api_key': AppConfig.posthogApiKey,
      'event': event,
      'distinct_id': _distinctId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'properties': <String, dynamic>{
        '\$lib': 'taskera-flutter',
        'platform': defaultTargetPlatform.name,
        ...?props,
      },
    };
    try {
      await _client.post(
        Uri.parse('${AppConfig.posthogHost}/capture/'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (_) {
      // Analytics must never crash or block the app.
    }
  }

  /// Records the user's current settings as PostHog *person* properties (via
  /// `$set`) — so later you can query "what % of users have quadColors on" /
  /// "least-picked accent" etc. across the whole user base to decide what to
  /// prune. Sends only when [props] differs from the last snapshot actually
  /// sent, or it's been at least [_snapshotHeartbeat] since that last send
  /// (so a user with unchanged settings still refreshes ~once/day, but a
  /// quiet session between changes produces zero events).
  Future<void> _maybeSendSnapshot(Map<String, dynamic> props) async {
    final prefs = _prefs;
    final json = jsonEncode(props);
    if (prefs != null) {
      final lastJson = prefs.getString(_lastSnapshotJsonKey);
      final lastAtMs = prefs.getInt(_lastSnapshotAtKey);
      final changed = lastJson != json;
      final stale = lastAtMs == null ||
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastAtMs)) >=
              _snapshotHeartbeat;
      if (!changed && !stale) return;
      await prefs.setString(_lastSnapshotJsonKey, json);
      await prefs.setInt(_lastSnapshotAtKey, DateTime.now().millisecondsSinceEpoch);
    }
    await capture('settings_snapshot', props: {r'$set': props});
  }

  /// Entry point for both the launch-time snapshot and every in-session
  /// settings change. Debounced so a slider drag (wallpaper dim) or rapid
  /// toggling doesn't spam a request per tick — only the settled state after
  /// 2s of inactivity is considered; [_maybeSendSnapshot] then decides
  /// whether it's actually worth sending.
  void captureSettingsSnapshot(Map<String, dynamic> props, {bool immediate = false}) {
    _settingsDebounce?.cancel();
    if (immediate) {
      _maybeSendSnapshot(props);
      return;
    }
    _settingsDebounce = Timer(const Duration(seconds: 2), () => _maybeSendSnapshot(props));
  }

  String _randomId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
