import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database.dart';
import 'database_provider.dart';

/// Stream of all calendar events ordered by time slot.
final calendarEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  return ref.watch(appDatabaseProvider).calendarDao.watchAll();
});

/// All events, with client-side filter for a given date (yyyy-mm-dd string key).
final calendarEventsForDayProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
  final all = ref.watch(calendarEventsProvider).valueOrNull ?? [];
  return all.where((e) {
    if (e.eventDate == null) {
      // Events without a date show on today only.
      final now = DateTime.now();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    }
    return e.eventDate!.year == date.year &&
        e.eventDate!.month == date.month &&
        e.eventDate!.day == date.day;
  }).toList();
});
