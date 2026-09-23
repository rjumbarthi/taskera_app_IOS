import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/habits_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  // Longest run of consecutive calendar days in a habit's completion dates.
  static int _longestRun(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final days = dates.toSet().toList()..sort();
    var best = 1, cur = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 1;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;

    final habits = ref.watch(habitsProvider).valueOrNull ?? [];
    final logs = ref
            .watch(allHabitLogsInRangeProvider(
                (DateTime(2000), DateTime.now().add(const Duration(days: 1)))))
            .valueOrNull ??
        [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Per-habit set of completed (non-skipped) days.
    final byHabit = <int, Set<DateTime>>{};
    for (final l in logs) {
      if (l.isSkipped) continue;
      (byHabit[l.habitId] ??= {})
          .add(DateTime(l.logDate.year, l.logDate.month, l.logDate.day));
    }

    final habitCount = habits.length;
    final totalCompletions = byHabit.values.fold<int>(0, (a, s) => a + s.length);
    var maxStreak = 0;
    for (final h in habits) {
      final r = _longestRun((byHabit[h.id] ?? const <DateTime>{}).toList());
      if (r > maxStreak) maxStreak = r;
    }
    // Perfect week: every habit completed each of the last 7 days.
    var completedPairs = 0;
    for (var d = 0; d < 7; d++) {
      final day = today.subtract(Duration(days: d));
      for (final h in habits) {
        if (byHabit[h.id]?.contains(day) ?? false) completedPairs++;
      }
    }
    final perfectWeek = habitCount > 0 ? completedPairs / (habitCount * 7) : 0.0;

    double frac(num v, num d) => (v / d).clamp(0.0, 1.0).toDouble();

    // (emoji, title, desc, accent, progress 0–1, unlocked)
    final achievements = <(String, String, String, Color, double, bool)>[
      ('🌱', 'First Habit', 'Created your first habit', const Color(0xFF7FBA00),
          habitCount >= 1 ? 1.0 : 0.0, habitCount >= 1),
      ('🔥', '7 Day Streak', 'Complete a habit 7 days in a row',
          const Color(0xFFFF6B6B), frac(maxStreak, 7), maxStreak >= 7),
      ('⭐', '5 Habits', 'Track 5 habits at once', const Color(0xFF0A84FF),
          frac(habitCount, 5), habitCount >= 5),
      ('🚀', '10 Habits', 'Track 10 habits at once', const Color(0xFF0A84FF),
          frac(habitCount, 10), habitCount >= 10),
      ('🏆', '30 Day Streak', 'Maintain a streak for 30 days',
          const Color(0xFFFFB900), frac(maxStreak, 30), maxStreak >= 30),
      ('💎', 'Habit Master', 'Complete 50 habits total', const Color(0xFF5856D6),
          frac(totalCompletions, 50), totalCompletions >= 50),
      ('🎯', 'Perfect Week', 'Complete all habits for 7 days',
          const Color(0xFF7FBA00), perfectWeek, habitCount > 0 && perfectWeek >= 1.0),
      // Not yet derivable (logs have no time-of-day; no habit "type") — honestly locked.
      ('🌅', 'Early Bird', 'Complete a habit before 8 AM',
          const Color(0xFFFFB900), 0.0, false),
      ('🌙', 'Night Owl', 'Complete a habit after 10 PM',
          const Color(0xFF5856D6), 0.0, false),
      ('🎪', 'Variety Pack', 'Complete 5 different habit types',
          const Color(0xFFBF5AF2), 0.0, false),
    ];

    final unlocked = achievements.where((a) => a.$6).toList();
    final locked = achievements.where((a) => !a.$6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppL10n.of(context).achievements, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Unlocked section
              if (unlocked.isNotEmpty) ...[
                Text(
                  'UNLOCKED (${unlocked.length})',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 1.0,
                  children: unlocked.map((a) => _UnlockedCard(
                    emoji: a.$1, title: a.$2, desc: a.$3, accentColor: a.$4,
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              // Locked section
              if (locked.isNotEmpty) ...[
                Text(
                  'LOCKED (${locked.length})',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 0.9,
                  children: locked.map((a) => _LockedCard(
                    emoji: a.$1, title: a.$2, desc: a.$3, pct: a.$5, colors: colors,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final String emoji, title, desc;
  final Color accentColor;
  const _UnlockedCard({required this.emoji, required this.title, required this.desc, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(0x1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: accentColor.withAlpha(0x30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF2F2F7), height: 1.2)),
          const SizedBox(height: 3),
          Text(desc, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.labelMuted, height: 1.4)),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final String emoji, title, desc;
  final double pct;
  final TaskEraColors colors;
  const _LockedCard({required this.emoji, required this.title, required this.desc, required this.pct, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
            ),
            const SizedBox(height: 5),
            Text(title, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink, height: 1.2)),
            const SizedBox(height: 3),
            Text(desc, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3, height: 1.4)),
            const SizedBox(height: 6),
            if (pct > 0) ...[
              Container(
                height: 3,
                decoration: BoxDecoration(color: const Color(0x20FFFFFF), borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  widthFactor: pct, alignment: Alignment.centerLeft,
                  child: Container(decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(2))),
                ),
              ),
              const SizedBox(height: 3),
              Text('${(pct * 100).toInt()}%', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
            ] else
              Text('🔒 Locked', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
          ],
        ),
      ),
    );
  }
}
