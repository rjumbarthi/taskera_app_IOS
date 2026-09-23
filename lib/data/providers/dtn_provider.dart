import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/taskera_settings.dart';
import '../database.dart';
import 'tasks_provider.dart';

/// Sort active tasks into "Do The Next" priority order. Shared by the focus
/// dashboard card and the DTN notification so they always agree.
List<Task> sortDtn(List<Task> tasks, {bool useScore = true}) {
  final all = [...tasks];
  all.sort((a, b) {
    if (useScore) {
      final cmp = (b.urgencyScore ?? 0.0).compareTo(a.urgencyScore ?? 0.0);
      return cmp != 0 ? cmp : a.quadrant.compareTo(b.quadrant);
    }
    return a.quadrant.compareTo(b.quadrant);
  });
  return all;
}

/// Tasks the user has "skipped" from the DTN notification this session
/// (cleared on app restart).
final dtnSkipProvider = StateProvider<Set<int>>((ref) => <int>{});

/// The single current "Do The Next" task (top of Q1–Q3 by priority), or null.
final dtnTaskProvider = Provider<Task?>((ref) {
  final q1 = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? const [];
  final q2 = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? const [];
  final q3 = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? const [];
  final useScore = ref.watch(taskeraSettingsProvider.select((s) => s.sw('scoreRec')));
  final skipped = ref.watch(dtnSkipProvider);

  final sorted = sortDtn([...q1, ...q2, ...q3], useScore: useScore)
      .where((t) => !skipped.contains(t.id))
      .toList();
  return sorted.isEmpty ? null : sorted.first;
});
