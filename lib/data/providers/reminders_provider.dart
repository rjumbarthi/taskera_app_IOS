import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reminder.dart';
import '../../services/notification_service.dart';
import '../../settings/prefs_provider.dart';

/// Prefs-backed list of standalone reminders/alarms, kept sorted by fire time.
/// Adding/removing also schedules/cancels the matching notification.
class RemindersNotifier extends Notifier<List<Reminder>> {
  static const _key = 'taskera.reminders';
  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  List<Reminder> build() {
    final raw = _p.getStringList(_key) ?? const [];
    final list = <Reminder>[];
    for (final s in raw) {
      try {
        list.add(Reminder.decode(s));
      } catch (_) {/* skip malformed */}
    }
    list.sort((a, b) => a.whenMs.compareTo(b.whenMs));
    return list;
  }

  void _persist(List<Reminder> list) =>
      _p.setStringList(_key, list.map((r) => r.encode()).toList());

  Future<void> add(Reminder r) async {
    final list = [...state, r]..sort((a, b) => a.whenMs.compareTo(b.whenMs));
    state = list;
    _persist(list);
    await NotificationService.instance.scheduleReminder(r);
  }

  Future<void> remove(int id) async {
    state = state.where((r) => r.id != id).toList();
    _persist(state);
    await NotificationService.instance.cancelReminder(id);
  }
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, List<Reminder>>(RemindersNotifier.new);
