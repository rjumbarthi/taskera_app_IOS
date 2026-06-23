import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class ActivityLog {
  final String message;
  final String type; // 'task' | 'checklist' | 'goal' | 'note' | 'habit'
  final DateTime timestamp;

  const ActivityLog({
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return ActivityLog(
      message:   m['message'] as String,
      type:      m['type'] as String,
      timestamp: DateTime.parse(m['timestamp'] as String),
    );
  }

  String toJson() => jsonEncode({
    'message':   message,
    'type':      type,
    'timestamp': timestamp.toIso8601String(),
  });
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ActivityLogNotifier extends AsyncNotifier<List<ActivityLog>> {
  static const _key     = 'activity_logs';
  static const _maxLogs = 300;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<List<ActivityLog>> build() async {
    final prefs = await _getPrefs();
    final raw   = prefs.getStringList(_key) ?? [];
    return raw.map(ActivityLog.fromJson).toList();
  }

  Future<void> add(String message, {String type = 'task'}) async {
    final prefs = await _getPrefs();
    final entry = ActivityLog(
      message:   message,
      type:      type,
      timestamp: DateTime.now(),
    );
    final current = state.valueOrNull ?? [];
    final updated = [entry, ...current];
    if (updated.length > _maxLogs) updated.removeRange(_maxLogs, updated.length);
    await prefs.setStringList(_key, updated.map((e) => e.toJson()).toList());
    state = AsyncData(updated);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.remove(_key);
    state = const AsyncData([]);
  }
}

final activityLogProvider =
    AsyncNotifierProvider<ActivityLogNotifier, List<ActivityLog>>(
  ActivityLogNotifier.new,
);

// ── Convenience global for use inside ConsumerWidget callbacks ─────────────────

extension ActivityLogRef on WidgetRef {
  void logActivity(String message, {String type = 'task'}) =>
      read(activityLogProvider.notifier).add(message, type: type);
}

extension ActivityLogProviderRef on Ref {
  void logActivity(String message, {String type = 'task'}) =>
      read(activityLogProvider.notifier).add(message, type: type);
}
