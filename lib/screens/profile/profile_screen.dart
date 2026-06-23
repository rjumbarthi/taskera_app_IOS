import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_l10n.dart';
import '../../data/providers/auth_provider.dart'
    show displayNameProvider, currentUserProvider;
import '../../widgets/kaal_avatar.dart';
import '../../services/auth_service.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/notes_provider.dart';
import '../../data/providers/calendar_provider.dart';
import '../../data/providers/goals_provider.dart';
import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';

// ── Date helpers ──────────────────────────────────────────────────────────────

DateTime _weekStart(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - 1));

int _isoWeekNumber(DateTime d) {
  final jan1 = DateTime(d.year, 1, 1);
  return ((d.difference(jan1).inDays + jan1.weekday - 1) / 7).floor() + 1;
}


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go(KaalRoutes.signin);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
      children: [
        _HeroCard(colors: colors, onTap: () => context.push(KaalRoutes.profileEdit)),
        const SizedBox(height: 8),
        _ReviewAchievementsStats(colors: colors),
        const SizedBox(height: 16),
        _FocusCard(colors: colors),
        const SizedBox(height: 16),
        _GoalsList(colors: colors),
        const SizedBox(height: 16),
        _HabitsThisWeek(colors: colors),
        const SizedBox(height: 16),
        _CalendarThisWeek(colors: colors),
        const SizedBox(height: 16),
        _NotesSection(colors: colors),
        const SizedBox(height: 24),
        _SignOutButton(busy: _signingOut, onTap: _signOut),
      ],
    );
  }
}

// ── Hero: avatar + name ───────────────────────────────────────────────────────

class _HeroCard extends ConsumerWidget {
  final KaalColors colors;
  final VoidCallback onTap;
  const _HeroCard({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name    = ref.watch(displayNameProvider);
    final user    = ref.watch(currentUserProvider);
    final display = name ?? 'User';
    final l = AppL10n.of(context);
    final memberSince = () {
      final created = user?.createdAt;
      if (created == null) return l.localStorageLabel;
      final dt = DateTime.tryParse(created);
      if (dt == null) return l.memberLabel;
      final months = l.monthsAbbr.split(',');
      return '${l.memberSinceLabel} ${months[dt.month - 1]} ${dt.year}';
    }();

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      GestureDetector(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const KaalAvatar(size: 44),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(display,
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(memberSince,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.3)),
          ]),
        ]),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () => context.push(KaalRoutes.paywall),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5856D6), KaalColors.acc]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(AppL10n.of(context).goPro,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
        ),
      ),
    ]);
  }
}

// ── Weekly Review + Achievements + Stats (merged card) ────────────────────────

class _ReviewAchievementsStats extends ConsumerWidget {
  final KaalColors colors;
  const _ReviewAchievementsStats({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l          = AppL10n.of(context);
    final allTasks   = ref.watch(allTasksProvider).value ?? [];
    final doneTasks  = ref.watch(doneTasksProvider).value ?? [];
    final done       = doneTasks.length;
    final habits     = ref.watch(habitsProvider).value ?? [];
    final maxStreak  = habits.fold<int>(0, (best, h) {
      final match = RegExp(r'(\d+)').firstMatch(h.streakLabel);
      final n = match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      return n > best ? n : best;
    });
    final streakStr  = maxStreak > 0 ? '$maxStreak🔥' : '0';
    final now        = DateTime.now();
    final todayDone  = doneTasks.where((t) =>
        t.doneAt != null &&
        t.doneAt!.year == now.year &&
        t.doneAt!.month == now.month &&
        t.doneAt!.day == now.day).length;
    // Current-week stats
    final weekStart    = _weekStart(now);
    final weekEndDay   = weekStart.add(const Duration(days: 6));
    final weekEndExcl  = weekStart.add(const Duration(days: 7));
    final weekDone     = doneTasks.where((t) =>
        t.doneAt != null &&
        !t.doneAt!.isBefore(weekStart) &&
        t.doneAt!.isBefore(weekEndExcl)).length;
    final activeCount  = allTasks.where((t) => !t.isDone).length;
    final carriedOv    = allTasks.where((t) =>
        !t.isDone && t.createdAt.isBefore(weekStart)).length;
    final weekTotal    = weekDone + activeCount;
    final weekRate     = weekTotal > 0
        ? (weekDone / weekTotal * 100).round() : 0;
    final weekNum      = _isoWeekNumber(now);
    final months       = l.monthsAbbr.split(',');
    final weekLabel    = weekStart.month == weekEndDay.month
        ? '${months[weekStart.month - 1]} ${weekStart.day}–${weekEndDay.day}'
        : '${months[weekStart.month - 1]} ${weekStart.day}–${months[weekEndDay.month - 1]} ${weekEndDay.day}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // ── Weekly Review ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(l.weeklyReviewLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(KaalRoutes.weeklyReview),
                child: Text(l.startLabel, style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: KaalColors.acc2, height: 1)),
              ),
            ]),
            const SizedBox(height: 6),
            Text('${l.week} $weekNum · $weekLabel',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            const SizedBox(height: 8),
            Row(children: [
              _StatCell('$weekDone', l.completedLabel, colors.ink, colors),
              _StatCell('$carriedOv', l.carriedOver, KaalColors.q4, colors),
              _StatCell(streakStr, l.streak, colors.successFg, colors),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: const Color(0x1F7FBA00),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                ),
                child: Text('$weekRate%', style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: colors.successFg, height: 1)),
              ),
            ]),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push(KaalRoutes.weeklyReview),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0x1F0A84FF),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                ),
                alignment: Alignment.center,
                child: Text(l.startWeeklyReview,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                        fontWeight: FontWeight.w600, color: KaalColors.acc2, height: 1)),
              ),
            ),
          ]),
        ),

        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),

        // ── Achievements ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(l.achievementsLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(KaalRoutes.habitsAchievements),
                child: Text(l.viewAllArrow, style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: KaalColors.acc2, height: 1)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AchieveBadge('🔥', l.badge14DaysStreak, KaalColors.q4, colors),
                _AchieveBadge('⚡', l.badgeQ1Slayer, KaalColors.q1, colors),
                _AchieveBadge('🎯', l.badgeDeepWork, KaalColors.acc, colors),
                _AchieveBadge('✅', l.badgeCentury, KaalColors.success, colors),
              ],
            ),
          ]),
        ),

        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),

        // ── Stats ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(children: [
            _StatCard(streakStr, l.streak, KaalColors.q4, colors),
            const SizedBox(width: 6),
            _StatCard('—', l.q2RateLabel, KaalColors.q2, colors),
            const SizedBox(width: 6),
            _StatCard('$done', l.done, KaalColors.acc, colors),
            const SizedBox(width: 6),
            _StatCard('$todayDone', l.today, KaalColors.acc2, colors),
          ]),
        ),
      ]),
    );
  }
}

class _AchieveBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final KaalColors colors;
  const _AchieveBadge(this.emoji, this.label, this.color, this.colors);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: color.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
      const SizedBox(height: 4),
      Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              color: colors.ink3, height: 1.3)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final KaalColors colors;
  const _StatCard(this.value, this.label, this.accent, this.colors);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 16,
              fontWeight: FontWeight.w700, color: accent, height: 1.2)),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              color: colors.ink3, height: 1.3)),
        ]),
      ),
    );
  }
}

// ── Focus card (Peak Hours + Q2 Rate + Tasks This Week + Quad Completion) ─────

class _FocusCard extends ConsumerWidget {
  final KaalColors colors;
  const _FocusCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l          = AppL10n.of(context);
    final allTasks   = ref.watch(allTasksProvider).value ?? [];
    final doneTasks  = ref.watch(doneTasksProvider).value ?? [];
    final now        = DateTime.now();

    final active     = allTasks.where((t) => !t.isDone).toList();
    final totalActive = active.length;
    final q1Active   = active.where((t) => t.quadrant == 1).length;
    final q2Active   = active.where((t) => t.quadrant == 2).length;
    final q3Active   = active.where((t) => t.quadrant == 3).length;
    final q4Active   = active.where((t) => t.quadrant == 4).length;

    final q1Done     = doneTasks.where((t) => t.quadrant == 1).length;
    final q2Done     = doneTasks.where((t) => t.quadrant == 2).length;
    final q3Done     = doneTasks.where((t) => t.quadrant == 3).length;
    final q4Done     = doneTasks.where((t) => t.quadrant == 4).length;

    final q2Total    = q2Active + q2Done;
    final q2RateStr  = q2Total > 0
        ? '${(q2Done / q2Total * 100).round()}%' : '—';

    // Bar chart: done tasks per day for last 6 days
    final dayLabels  = l.weekDayAbbrs6.split(',');
    final barCounts  = List.generate(6, (i) {
      final day      = now.subtract(Duration(days: 5 - i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd   = dayStart.add(const Duration(days: 1));
      return doneTasks.where((t) =>
          t.doneAt != null &&
          !t.doneAt!.isBefore(dayStart) &&
          t.doneAt!.isBefore(dayEnd)).length;
    });
    final maxCount   = barCounts.fold<int>(1, (m, c) => c > m ? c : m);
    final barHeights = barCounts.map((c) => (c / maxCount).clamp(0.05, 1.0)).toList();

    final activeDays = doneTasks
        .where((t) => t.doneAt != null)
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet()
        .length;

    String qRate(int d, int a) {
      final total = d + a;
      return total == 0 ? '${l.avgLabel} 0%' : '${l.avgLabel} ${(d / total * 100).round()}%';
    }

    const q1c = KaalColors.q1; const q2c = KaalColors.q2;
    const q3c = KaalColors.q3; const q4c = KaalColors.q4;
    final quads = <(String, Color, String)>[
      ('Q1', KaalColors.q1, qRate(q1Done, q1Active)),
      ('Q2', KaalColors.q2, qRate(q2Done, q2Active)),
      ('Q3', KaalColors.q3, qRate(q3Done, q3Active)),
      ('Q4', KaalColors.q4, qRate(q4Done, q4Active)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Text(l.focus.toUpperCase(),
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        ),
        // Peak Hours + Q2 Rate
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x120A84FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.peakHours.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.4, height: 1)),
                  const SizedBox(height: 4),
                  const Text('—', style: TextStyle(fontFamily: 'Inter', fontSize: 16,
                      fontWeight: FontWeight.w700, color: KaalColors.acc2, height: 1.2)),
                  Text(activeDays > 0
                      ? '${l.basedOnLabel} $activeDays ${l.daysLabel}'
                      : '—',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                          color: colors.ink3, height: 1.3)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x127FBA00),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.q2RateLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.4, height: 1)),
                  const SizedBox(height: 4),
                  Text(q2RateStr, style: TextStyle(fontFamily: 'Inter', fontSize: 16,
                      fontWeight: FontWeight.w700, color: colors.successFg, height: 1.2)),
                  Text('—', style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      color: colors.successFg, height: 1.3)),
                ]),
              ),
            ),
          ]),
        ),
        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
        // Tasks This Week
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(l.tasksThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              Text('$totalActive ${l.total}', style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: colors.ink3, height: 1)),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < 6; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 5 ? 3 : 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: barHeights[i],
                                widthFactor: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: i < 4 ? q1c : q2c,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(dayLabels[i], style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                                color: colors.ink3, height: 1)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _QuadBit('Q1', '$q1Active', q1c), const SizedBox(width: 6),
              _QuadBit('Q2', '$q2Active', q2c), const SizedBox(width: 6),
              _QuadBit('Q3', '$q3Active', q3c), const SizedBox(width: 6),
              _QuadBit('Q4', '$q4Active', q4c),
            ]),
          ]),
        ),
        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
        // Quadrant Completion
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.quadrantCompletion.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: quads.map((q) => _QuadDonut(q.$1, q.$2, q.$3, colors)).toList(),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _QuadBit extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QuadBit(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 3),
      Text('$label: $value',
          style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              color: color, fontWeight: FontWeight.w600, height: 1)),
    ]);
  }
}

class _QuadDonut extends StatelessWidget {
  final String quad;
  final Color color;
  final String sub;
  final KaalColors colors;
  const _QuadDonut(this.quad, this.color, this.sub, this.colors);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 4, color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(quad, style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w700, color: color, height: 1)),
        ),
      ),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(fontFamily: 'Inter', fontSize: 8,
          color: colors.ink3, height: 1.3), textAlign: TextAlign.center),
    ]);
  }
}

// ── Goals list ────────────────────────────────────────────────────────────────

class _GoalsList extends ConsumerWidget {
  final KaalColors colors;
  const _GoalsList({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l     = AppL10n.of(context);
    final goals = ref.watch(goalsProvider).value ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(children: [
              Text(l.goals.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 9,
                  color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(KaalRoutes.goals),
                child: Text(l.viewAllArrow, style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: KaalColors.acc2, height: 1)),
              ),
            ]),
          ),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(l.noGoalsYet,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5)),
            )
          else
            for (int i = 0; i < goals.length; i++) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text(goals[i].title,
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12,
                            color: colors.ink, height: 1.2))),
                    Text('${(goals[i].progressPct * 100).round()}%',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700,
                            fontSize: 12, color: Color(goals[i].accentColorValue), height: 1)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: goals[i].progressPct.clamp(0.0, 1.0),
                      backgroundColor: const Color(0x1F7FBA00),
                      valueColor: AlwaysStoppedAnimation(Color(goals[i].barColorValue)),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(goals[i].linkedLabel,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                          color: colors.ink3, height: 1.3)),
                ]),
              ),
            ],
        ],
      ),
    );
  }
}

// ── Habits this week ──────────────────────────────────────────────────────────

class _HabitsThisWeek extends ConsumerWidget {
  final KaalColors colors;
  const _HabitsThisWeek({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits    = ref.watch(habitsProvider).value ?? [];
    final maxStreak = habits.fold<int>(0, (best, h) {
      final match = RegExp(r'(\d+)').firstMatch(h.streakLabel);
      final n = match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      return n > best ? n : best;
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text(AppL10n.of(context).habitsThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 9,
              color: colors.ink3, letterSpacing: 0.5, height: 1)),
          const Spacer(),
          if (maxStreak > 0)
            Container(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              decoration: BoxDecoration(
                color: const Color(0x1F7FBA00),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$maxStreak${AppL10n.of(context).dStreakSuffix}', style: TextStyle(fontFamily: 'Inter',
                  fontSize: 9, color: colors.successFg, height: 1)),
            ),
        ]),
        if (habits.isEmpty) ...[
          const SizedBox(height: 8),
          Text(AppL10n.of(context).noHabitsYet, style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: colors.ink3, height: 1.5)),
        ] else ...[
          const SizedBox(height: 10),
          for (int i = 0; i < habits.take(3).length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${habits[i].emoji} ${habits[i].name}',
                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 12,
                          color: colors.ink, height: 1.2)),
                  Text(habits[i].frequencyLabel,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                          color: colors.ink3, height: 1.3)),
                ]),
              ),
              Text('${habits[i].weeklyFilledCount}/7',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12,
                      color: colors.successFg, height: 1)),
            ]),
          ],
        ],
      ]),
    );
  }
}

// ── Calendar this week ────────────────────────────────────────────────────────

class _CalendarThisWeek extends ConsumerWidget {
  final KaalColors colors;
  const _CalendarThisWeek({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l          = AppL10n.of(context);
    final allEvents  = ref.watch(calendarEventsProvider).value ?? [];
    final now        = DateTime.now();
    final weekStart  = _weekStart(now);
    final weekEnd    = weekStart.add(const Duration(days: 7));
    final weekEvents = allEvents.where((e) =>
        e.eventDate != null &&
        !e.eventDate!.isBefore(weekStart) &&
        e.eventDate!.isBefore(weekEnd)).toList();
    final totalEvents = weekEvents.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.calendarThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
            fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        const SizedBox(height: 10),
        Row(children: [
          _StatCell('$totalEvents', l.eventsLabel, colors.ink, colors),
          _StatCell('—', l.deepWorkLabel, KaalColors.acc, colors),
          _StatCell('—', l.conflicts, KaalColors.q1, colors),
        ]),
      ]),
    );
  }
}

// ── Notes section ─────────────────────────────────────────────────────────────

class _NotesSection extends ConsumerWidget {
  final KaalColors colors;
  const _NotesSection({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l      = AppL10n.of(context);
    final notes  = ref.watch(notesProvider).value ?? [];
    final total  = notes.length;
    final pinned = notes.where((n) => n.isPinned).length;
    final ai     = notes.where((n) => n.aiLabel != null).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.notes.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 9,
            fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        const SizedBox(height: 10),
        Row(children: [
          _StatCell('$total', l.total, colors.ink, colors),
          _StatCell('$ai', l.aiActionsLabel, KaalColors.acc2, colors),
          _StatCell('$pinned', l.pinnedLabel, KaalColors.q4, colors),
        ]),
      ]),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final KaalColors colors;
  const _StatCell(this.value, this.label, this.valueColor, this.colors);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w700, color: valueColor, height: 1.2)),
        Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
            color: colors.ink3, height: 1.3)),
      ]),
    );
  }
}

// ── Sign out button ───────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _SignOutButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0x14FF453A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: const Color(0x40FF453A)),
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFFF453A)))
            : Text(AppL10n.of(context).signOut,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
      ),
    );
  }
}
