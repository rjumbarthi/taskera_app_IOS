import 'dart:convert';

/// A standalone one-time reminder or alarm (not tied to a calendar event).
/// Persisted in SharedPreferences as JSON; scheduled via NotificationService.
/// How a reminder/alarm repeats. Index is persisted, so order is stable.
enum ReminderRepeat { none, daily, weekly }

class Reminder {
  final int id;        // unique id (creation epoch-ms) — also the notification key
  final String label;
  final int whenMs;    // fire time, epoch-ms
  final bool isAlarm;  // true = full-screen alarm (alarm sound); false = notification
  final ReminderRepeat repeat;

  const Reminder({
    required this.id,
    required this.label,
    required this.whenMs,
    required this.isAlarm,
    this.repeat = ReminderRepeat.none,
  });

  DateTime get when => DateTime.fromMillisecondsSinceEpoch(whenMs);
  // A repeating reminder is never "past" — it keeps firing.
  bool get isPast =>
      repeat == ReminderRepeat.none &&
      whenMs <= DateTime.now().millisecondsSinceEpoch;

  String get repeatLabel => switch (repeat) {
        ReminderRepeat.none => 'Once',
        ReminderRepeat.daily => 'Daily',
        ReminderRepeat.weekly => 'Weekly',
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'whenMs': whenMs,
        'isAlarm': isAlarm,
        'repeat': repeat.index,
      };

  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
        id: j['id'] as int,
        label: (j['label'] as String?) ?? '',
        whenMs: j['whenMs'] as int,
        isAlarm: (j['isAlarm'] as bool?) ?? false,
        repeat: ReminderRepeat
            .values[((j['repeat'] as int?) ?? 0).clamp(0, ReminderRepeat.values.length - 1)],
      );

  String encode() => jsonEncode(toJson());
  static Reminder decode(String s) =>
      Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
