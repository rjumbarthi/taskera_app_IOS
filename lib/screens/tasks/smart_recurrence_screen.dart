import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Habit, HabitsCompanion;
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/ai_insight_card.dart';

// ── Badges ────────────────────────────────────────────────────────────────────

enum _Badge { adapt, stretch, onTrack, watching }

extension _BadgeExt on _Badge {
  String get label => switch (this) {
        _Badge.adapt => 'Adapt',
        _Badge.stretch => 'Stretch',
        _Badge.onTrack => 'On track',
        _Badge.watching => 'Watching',
      };
  Color get color => switch (this) {
        _Badge.adapt => TaskEraColors.q4,
        _Badge.stretch => TaskEraColors.acc2,
        _Badge.onTrack => const Color(0xFF9FCD44),
        _Badge.watching => TaskEraColors.q3,
      };
  Color get bg => color.withAlpha(0x22);
}

_Badge _badgeFor(int pct) {
  if (pct >= 95) return _Badge.onTrack;
  if (pct >= 80) return _Badge.stretch;
  if (pct >= 55) return _Badge.watching;
  return _Badge.adapt;
}

// ── Frequency helpers ─────────────────────────────────────────────────────────

const _dayAbbr = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};

/// The weekdays (1=Mon … 7=Sun) a habit is scheduled, parsed from its
/// frequency label. Empty set ⇒ weekly (no fixed weekday).
Set<int> _scheduledDays(String freq) {
  final f = freq.toLowerCase();
  if (f.contains('daily') || f.contains('every day')) return {1, 2, 3, 4, 5, 6, 7};
  final days = <int>{};
  const map = {'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6, 'sun': 7};
  map.forEach((k, v) {
    if (f.contains(k)) days.add(v);
  });
  if (f.contains('weekday')) days.addAll({1, 2, 3, 4, 5});
  if (f.contains('weekend')) days.addAll({6, 7});
  if (days.isNotEmpty) return days;
  if (f.contains('weekly')) return {};
  return {1, 2, 3, 4, 5, 6, 7}; // default daily
}

String _freqShort(Set<int> days) {
  if (days.length == 7) return 'Daily';
  if (days.length == 5 && days.containsAll({1, 2, 3, 4, 5})) return 'Weekdays';
  if (days.length == 2 && days.containsAll({6, 7})) return 'Weekends';
  if (days.isEmpty) return 'Weekly';
  final sorted = days.toList()..sort();
  return sorted.map((d) => _dayAbbr[d]).join(' · ');
}

/// Replace the day portion of a frequency label, keeping trailing segments
/// like "60 min" / "Q2".
String _rebuildFreq(String old, String newSpec) {
  final parts = old.split('·').map((s) => s.trim()).where((s) => s.isNotEmpty);
  const dayWords = [
    'daily', 'weekday', 'weekend', 'weekly', 'every day',
    'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun',
  ];
  final kept = parts.where((p) {
    final l = p.toLowerCase();
    return !dayWords.any((d) => l.contains(d));
  });
  return [newSpec, ...kept].join(' · ');
}

// ── Computed model ────────────────────────────────────────────────────────────

class _HabitStat {
  final Habit habit;
  final Set<int> days;
  final int pct;
  final _Badge badge;
  const _HabitStat(this.habit, this.days, this.pct, this.badge);

  String get freqShort => _freqShort(days);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SmartRecurrenceScreen extends ConsumerStatefulWidget {
  const SmartRecurrenceScreen({super.key});

  @override
  ConsumerState<SmartRecurrenceScreen> createState() => _SmartRecurrenceScreenState();
}

class _SmartRecurrenceScreenState extends ConsumerState<SmartRecurrenceScreen> {
  final _dismissed = <int>{}; // habit ids whose suggestion was dismissed

  Future<void> _apply(Habit h, String newSpec) async {
    await ref.read(appDatabaseProvider).habitsDao.updateHabit(
          h.id,
          HabitsCompanion(frequencyLabel: Value(_rebuildFreq(h.frequencyLabel, newSpec))),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final habits = ref.watch(habitsProvider).value ?? [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final windowStart = today.subtract(const Duration(days: 29));
    // All logs across habits in the 30-day window.
    final logs = ref.watch(allHabitLogsInRangeProvider(
        (windowStart, today.add(const Duration(days: 1)))))
        .value ??
        [];
    final byHabit = <int, Set<DateTime>>{};
    for (final l in logs) {
      if (l.isSkipped) continue;
      final d = DateTime(l.logDate.year, l.logDate.month, l.logDate.day);
      if (d.isBefore(windowStart) || d.isAfter(today)) continue;
      (byHabit[l.habitId] ??= {}).add(d);
    }

    // Build per-habit stats.
    final stats = <_HabitStat>[];
    for (final h in habits) {
      final days = _scheduledDays(h.frequencyLabel);
      final hStart = DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day);
      final effStart = hStart.isAfter(windowStart) ? hStart : windowStart;

      int expected;
      if (days.isEmpty) {
        final span = today.difference(effStart).inDays + 1;
        expected = (span / 7).ceil().clamp(1, 100);
      } else {
        expected = 0;
        for (var d = effStart; !d.isAfter(today); d = d.add(const Duration(days: 1))) {
          if (days.contains(d.weekday)) expected++;
        }
      }
      final completed = (byHabit[h.id] ?? const <DateTime>{})
          .where((d) => !d.isBefore(effStart))
          .length;
      final pct = expected > 0
          ? (completed / expected * 100).round().clamp(0, 100)
          : (completed > 0 ? 100 : 0);
      stats.add(_HabitStat(h, days, pct, _badgeFor(pct)));
    }

    // Suggestions: high performers with room to extend, or strugglers to ease off.
    final suggestions = <_HabitStat>[];
    for (final s in stats) {
      if (_dismissed.contains(s.habit.id)) continue;
      final canExtend = s.pct >= 90 && s.days.isNotEmpty && s.days.length < 7;
      final shouldEase = s.pct < 55 && s.days.length == 7;
      if (canExtend || shouldEase) suggestions.add(s);
    }

    final aiInput = habits.isEmpty
        ? 'The user has no habits yet.'
        : 'My habits and their 30-day completion rate:\n${stats.map((s) => '- ${s.habit.name}: ${_freqShort(s.days)}, ${s.pct}% completed').join('\n')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sub-bar
          Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Smart recurrence',
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink,
                            height: 1.1)),
                    Text('Adapts to your completion patterns',
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Real on-demand TaskEra AI — reasons over your habit completion data.
          AiInsightCard(
            input: aiInput,
            hint: 'Suggest smarter habit frequencies',
            margin: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          if (habits.isEmpty)
            _Empty(colors: colors)
          else ...[
            // FREQUENCY SUGGESTIONS
            if (suggestions.isNotEmpty) ...[
              Text('FREQUENCY SUGGESTIONS',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: colors.ink3)),
              const SizedBox(height: 8),
              for (final s in suggestions) ...[
                _SuggestionCard(
                  stat: s,
                  colors: colors,
                  onApply: (spec) => _apply(s.habit, spec),
                  onKeep: () => setState(() => _dismissed.add(s.habit.id)),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],

            // ALL RECURRING
            Row(
              children: [
                Text('ALL RECURRING',
                    style: TextStyle(
                        fontFamily: TaskEraTheme.of(context).fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.ink3)),
                const SizedBox(width: 6),
                Text('· ${stats.length} HABIT${stats.length == 1 ? '' : 'S'}',
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
              ],
            ),
            const SizedBox(height: 6),
            for (final s in stats) ...[
              _RecurRow(stat: s, colors: colors),
              const SizedBox(height: 4),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Suggestion card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final _HabitStat stat;
  final TaskEraColors colors;
  final void Function(String newSpec) onApply;
  final VoidCallback onKeep;
  const _SuggestionCard({
    required this.stat,
    required this.colors,
    required this.onApply,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    final extend = stat.pct >= 90 && stat.days.length < 7;
    final newSpec = extend ? 'Daily' : 'Weekdays';
    final actionLabel = extend ? 'Extend to daily' : 'Switch to weekdays';
    final body = extend
        ? '${stat.pct}% completion over 30 days — you\'re ready to extend to daily.'
        : 'Only ${stat.pct}% completion — easing to weekdays may help you keep the streak.';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(stat.habit.name,
                      style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: stat.badge.color))),
              _BadgePill(badge: stat.badge),
            ],
          ),
          const SizedBox(height: 4),
          Text('Current: ${stat.freqShort} · Completion: ${stat.pct}%',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
          Text('Suggestion: $actionLabel',
              style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: TaskEraColors.acc2)),
          const SizedBox(height: 6),
          Text(body,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink2, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onApply(newSpec),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: TaskEraColors.accBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: const Color(0x660A84FF))),
                    alignment: Alignment.center,
                    child: Text(actionLabel,
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TaskEraColors.acc2)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onKeep,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr)),
                    alignment: Alignment.center,
                    child: Text('Keep as is',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recurring habit row ───────────────────────────────────────────────────────

class _RecurRow extends StatelessWidget {
  final _HabitStat stat;
  final TaskEraColors colors;
  const _RecurRow({required this.stat, required this.colors});

  @override
  Widget build(BuildContext context) {
    final streak = stat.habit.streakLabel.trim();
    final showStreak = streak.isNotEmpty && !streak.startsWith('0');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.habit.name,
                    style: TextStyle(
                        fontFamily: TaskEraTheme.of(context).fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: stat.badge.color)),
                Row(
                  children: [
                    Text(stat.freqShort,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
                    const SizedBox(width: 5),
                    Text('· ${stat.pct}%',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
                    if (showStreak) ...[
                      const SizedBox(width: 5),
                      Text('· $streak',
                          style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.successFg)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _BadgePill(badge: stat.badge),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final _Badge badge;
  const _BadgePill({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
      decoration: BoxDecoration(color: badge.bg, borderRadius: BorderRadius.circular(5)),
      child: Text(badge.label,
          style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: badge.color)),
    );
  }
}

class _Empty extends StatelessWidget {
  final TaskEraColors colors;
  const _Empty({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text('🔁', style: TextStyle(fontSize: 32, color: colors.ink3)),
          const SizedBox(height: 10),
          Text('No habits to analyse yet',
              style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.ink2)),
          const SizedBox(height: 4),
          Text('Create a few habits and TaskEra will suggest smarter frequencies as you log them.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3, height: 1.4)),
        ],
      ),
    );
  }
}
