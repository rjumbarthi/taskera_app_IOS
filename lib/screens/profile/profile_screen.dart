import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_l10n.dart';
import '../../data/providers/auth_provider.dart'
    show displayNameProvider, currentUserProvider,
         profileImagePathProvider, profileDisplayNameProvider;
import '../../widgets/taskera_avatar.dart';
import '../../widgets/goal_meta_label.dart';
import '../../services/auth_service.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/ai_access_provider.dart';
import '../../data/providers/notes_provider.dart';
import '../../data/providers/calendar_provider.dart';
import '../../data/providers/goals_provider.dart';
import '../../routing/routes.dart';
import '../../settings/prefs_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';

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
    // Actually end the Supabase session, then clear local profile overrides
    // so the next user (or a re-sign-in) doesn't inherit stale name/avatar.
    await ref.read(authServiceProvider).signOut();
    await ref.read(profileImagePathProvider.notifier).clear();
    await ref.read(profileDisplayNameProvider.notifier).setName('');
    if (mounted) context.go(TaskEraRoutes.signin);
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
      children: [
        _HeroCard(colors: colors, onTap: () => context.push(TaskEraRoutes.profileEdit)),
        _PersonaCard(colors: colors), // self-spaces / hides when no onboarding data
        SizedBox(height: 8),
        _StreakBanner(colors: colors),
        SizedBox(height: 16),
        _ReviewAchievementsStats(colors: colors),
        SizedBox(height: 16),
        _LifetimeStatsCard(colors: colors),
        SizedBox(height: 16),
        _QuadrantBalanceCard(colors: colors),
        SizedBox(height: 16),
        _FocusCard(colors: colors),
        SizedBox(height: 16),
        _GoalsList(colors: colors),
        SizedBox(height: 16),
        _HabitsThisWeek(colors: colors),
        SizedBox(height: 16),
        _CalendarThisWeek(colors: colors),
        SizedBox(height: 16),
        _NotesSection(colors: colors),
        SizedBox(height: 16),
        _AccountCard(colors: colors),
        SizedBox(height: 24),
        _InviteButton(colors: colors, onTap: () => context.push(TaskEraRoutes.referral)),
        SizedBox(height: 10),
        _SignOutButton(busy: _signingOut, onTap: _signOut),
      ],
    );
  }
}

// ── Hero: avatar + name ───────────────────────────────────────────────────────

class _HeroCard extends ConsumerWidget {
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _HeroCard({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name    = ref.watch(displayNameProvider);
    final user    = ref.watch(currentUserProvider);
    final isPro   = ref.watch(isProProvider);
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
          const TaskEraAvatar(size: 44),
          SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(display,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(memberSince,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.3)),
          ]),
        ]),
      ),
      const Spacer(),
      if (isPro)
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('✦ PRO',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                  fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
        )
      else
        GestureDetector(
          onTap: () => context.push(TaskEraRoutes.paywall),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(AppL10n.of(context).goPro,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
          ),
        ),
    ]);
  }
}

// ── Weekly Review + Achievements + Stats (merged card) ────────────────────────

class _ReviewAchievementsStats extends ConsumerWidget {
  final TaskEraColors colors;
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

    // ── Live achievements + Q2 rate ───────────────────────────────────────────
    final totalFocusSec = allTasks.fold<int>(0, (s, t) => s + t.totalFocusSeconds);
    final q1Done    = doneTasks.where((t) => t.quadrant == 1).length;
    final q2Done    = doneTasks.where((t) => t.quadrant == 2).length;
    final q2Active  = allTasks.where((t) => !t.isDone && t.quadrant == 2).length;
    final q2Total   = q2Done + q2Active;
    final q2RateStr = q2Total > 0 ? '${(q2Done / q2Total * 100).round()}%' : '0%';
    final earnStreak  = maxStreak >= 14;          // 🔥 14-day streak
    final earnQ1      = q1Done >= 10;             // ⚡ Q1 slayer
    final earnFocus   = totalFocusSec >= 5 * 3600; // 🎯 5h+ deep work
    final earnCentury = done >= 100;             // ✅ 100 tasks done

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
              Text(l.weeklyReviewLabel.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(TaskEraRoutes.weeklyReview),
                child: Text(l.startLabel, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                    color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
              ),
            ]),
            SizedBox(height: 6),
            Text('${l.week} $weekNum · $weekLabel',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            SizedBox(height: 8),
            Row(children: [
              _StatCell('$weekDone', l.completedLabel, colors.ink, colors),
              _StatCell('$carriedOv', l.carriedOver, TaskEraColors.q4, colors),
              _StatCell(streakStr, l.streak, colors.successFg, colors),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: const Color(0x1F7FBA00),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(width: 0.5, color: const Color(0x337FBA00)),
                ),
                child: Text('$weekRate%', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                    fontWeight: FontWeight.w700, color: colors.successFg, height: 1)),
              ),
            ]),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push(TaskEraRoutes.weeklyReview),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0x1F0A84FF),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                ),
                alignment: Alignment.center,
                child: Text(l.startWeeklyReview,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
                        fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
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
              Text(l.achievementsLabel.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(TaskEraRoutes.habitsAchievements),
                child: Text(l.viewAllArrow, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                    color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
              ),
            ]),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AchieveBadge('🔥', l.badge14DaysStreak, TaskEraColors.q4, colors, earned: earnStreak),
                _AchieveBadge('⚡', l.badgeQ1Slayer, TaskEraColors.q1, colors, earned: earnQ1),
                _AchieveBadge('🎯', l.badgeDeepWork, TaskEraColors.acc, colors, earned: earnFocus),
                _AchieveBadge('✅', l.badgeCentury, TaskEraColors.success, colors, earned: earnCentury),
              ],
            ),
          ]),
        ),

        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),

        // ── Stats ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(children: [
            _StatCard(streakStr, l.streak, TaskEraColors.q4, colors),
            SizedBox(width: 6),
            _StatCard(q2RateStr, l.q2RateLabel, TaskEraColors.q2, colors),
            SizedBox(width: 6),
            _StatCard('$done', l.done, TaskEraColors.acc, colors),
            SizedBox(width: 6),
            _StatCard('$todayDone', l.today, TaskEraColors.acc2, colors),
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
  final TaskEraColors colors;
  final bool earned;
  const _AchieveBadge(this.emoji, this.label, this.color, this.colors, {this.earned = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Column(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: earned ? color.withValues(alpha: 0.15) : colors.surf2,
            shape: BoxShape.circle,
            border: Border.all(width: 1, color: earned ? color.withValues(alpha: 0.4) : colors.bdr),
          ),
          alignment: Alignment.center,
          child: Text(earned ? emoji : '🔒', style: TextStyle(fontSize: 18)),
        ),
        SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                color: colors.ink3, height: 1.3)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  final TaskEraColors colors;
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
          Text(value, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16,
              fontWeight: FontWeight.w700, color: accent, height: 1.2)),
          Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
              color: colors.ink3, height: 1.3)),
        ]),
      ),
    );
  }
}

// ── Tasks card (Peak Hours + DTN + Tasks This Week + Quad Completion) ─────────

class _FocusCard extends ConsumerWidget {
  final TaskEraColors colors;
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

    // DTN rate: completion across Q1–Q3 (the quadrants DTN draws from).
    final dtnDone    = q1Done + q2Done + q3Done;
    final dtnTotal   = dtnDone + q1Active + q2Active + q3Active;
    final dtnRateStr = dtnTotal > 0 ? '${(dtnDone / dtnTotal * 100).round()}%' : '—';

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

    // Peak hours: the hour-of-day with the most task completions → a 2h window.
    final hourCounts = <int, int>{};
    for (final t in doneTasks) {
      if (t.doneAt != null) {
        hourCounts[t.doneAt!.hour] = (hourCounts[t.doneAt!.hour] ?? 0) + 1;
      }
    }
    String fmtHour(int h) {
      final period = h >= 12 ? 'PM' : 'AM';
      final hr = h % 12 == 0 ? 12 : h % 12;
      return '$hr$period';
    }
    final peakHoursStr = hourCounts.isEmpty
        ? '—'
        : () {
            final peak = hourCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
            return '${fmtHour(peak)}–${fmtHour((peak + 2) % 24)}';
          }();

    String qRate(int d, int a) {
      final total = d + a;
      return total == 0 ? '${l.avgLabel} 0%' : '${l.avgLabel} ${(d / total * 100).round()}%';
    }
    double qFrac(int d, int a) {
      final total = d + a;
      return total == 0 ? 0.0 : d / total;
    }

    const q1c = TaskEraColors.q1; const q2c = TaskEraColors.q2;
    const q3c = TaskEraColors.q3; const q4c = TaskEraColors.q4;
    final quads = <(String, Color, double, String)>[
      ('Q1', TaskEraColors.q1, qFrac(q1Done, q1Active), qRate(q1Done, q1Active)),
      ('Q2', TaskEraColors.q2, qFrac(q2Done, q2Active), qRate(q2Done, q2Active)),
      ('Q3', TaskEraColors.q3, qFrac(q3Done, q3Active), qRate(q3Done, q3Active)),
      ('Q4', TaskEraColors.q4, qFrac(q4Done, q4Active), qRate(q4Done, q4Active)),
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
          child: Text(l.tasks.toUpperCase(),
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        ),
        // Peak Hours + DTN
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
                  Text(l.peakHours.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                      fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.4, height: 1)),
                  SizedBox(height: 4),
                  Text(peakHoursStr, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16,
                      fontWeight: FontWeight.w700, color: colors.textOrPlain(TaskEraColors.acc2), height: 1.2)),
                  Text(activeDays > 0
                      ? '${l.basedOnLabel} $activeDays ${l.daysLabel}'
                      : '—',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                          color: colors.ink3, height: 1.3)),
                ]),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0x12BF5AF2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 0.5, color: const Color(0x33BF5AF2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DTN RATE', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                      fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.4, height: 1)),
                  SizedBox(height: 4),
                  Text(dtnRateStr, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16,
                      fontWeight: FontWeight.w700, color: Color(0xFFBF5AF2), height: 1.2)),
                  Text(dtnTotal > 0 ? '$dtnDone/$dtnTotal ${l.done.toLowerCase()}' : '—',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                          color: colors.ink3, height: 1.3)),
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
              Text(l.tasksThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                  fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              Text('$totalActive ${l.total}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                  color: colors.ink3, height: 1)),
            ]),
            SizedBox(height: 10),
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
                            SizedBox(height: 3),
                            Text(dayLabels[i], style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                                color: colors.ink3, height: 1)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(children: [
              _QuadBit('Q1', '$q1Active', q1c), SizedBox(width: 6),
              _QuadBit('Q2', '$q2Active', q2c), SizedBox(width: 6),
              _QuadBit('Q3', '$q3Active', q3c), SizedBox(width: 6),
              _QuadBit('Q4', '$q4Active', q4c),
            ]),
          ]),
        ),
        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
        // Quadrant Completion
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.quadrantCompletion.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: quads.map((q) => _QuadDonut(q.$1, q.$2, q.$3, q.$4, colors)).toList(),
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
      SizedBox(width: 3),
      Text('$label: $value',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
              color: color, fontWeight: FontWeight.w600, height: 1)),
    ]);
  }
}

class _QuadDonut extends StatelessWidget {
  final String quad;
  final Color color;
  final double fraction; // 0–1 completion for this quadrant
  final String sub;
  final TaskEraColors colors;
  const _QuadDonut(this.quad, this.color, this.fraction, this.sub, this.colors);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 48, height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring (faint track + completion arc)
            SizedBox(
              width: 48, height: 48,
              child: CircularProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: color.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(quad, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                fontWeight: FontWeight.w700, color: color, height: 1)),
          ],
        ),
      ),
      SizedBox(height: 4),
      Text(sub, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 8,
          color: colors.ink3, height: 1.3), textAlign: TextAlign.center),
    ]);
  }
}

// ── Goals list ────────────────────────────────────────────────────────────────

class _GoalsList extends ConsumerWidget {
  final TaskEraColors colors;
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
              Text(l.goals.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w700, fontSize: 9,
                  color: colors.ink3, letterSpacing: 0.5, height: 1)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(TaskEraRoutes.goals),
                child: Text(l.viewAllArrow, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                    color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
              ),
            ]),
          ),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(l.noGoalsYet,
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1.5)),
            )
          else
            for (int i = 0; i < goals.length; i++) ...[
              if (i > 0) Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(child: Text('${goals[i].emoji} ${goals[i].title}',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w500, fontSize: 12,
                            color: colors.ink, height: 1.2))),
                    Text('${(goals[i].progressPct * 100).round()}%',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w700,
                            fontSize: 12, color: Color(goals[i].accentColorValue), height: 1)),
                  ]),
                  SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: goals[i].progressPct.clamp(0.0, 1.0),
                      backgroundColor: const Color(0x1F7FBA00),
                      valueColor: AlwaysStoppedAnimation(Color(goals[i].barColorValue)),
                      minHeight: 3,
                    ),
                  ),
                  SizedBox(height: 4),
                  GoalCountsLabel(
                    goalId: goals[i].id,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                        color: colors.ink3, height: 1.3),
                  ),
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
  final TaskEraColors colors;
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
          Text(AppL10n.of(context).habitsThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w700, fontSize: 9,
              color: colors.ink3, letterSpacing: 0.5, height: 1)),
          const Spacer(),
          if (maxStreak > 0)
            Container(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              decoration: BoxDecoration(
                color: const Color(0x1F7FBA00),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$maxStreak${AppL10n.of(context).dStreakSuffix}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 9, color: colors.successFg, height: 1)),
            ),
        ]),
        if (habits.isEmpty) ...[
          SizedBox(height: 8),
          Text(AppL10n.of(context).noHabitsYet, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
              color: colors.ink3, height: 1.5)),
        ] else ...[
          SizedBox(height: 10),
          for (int i = 0; i < habits.take(3).length; i++) ...[
            if (i > 0) SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${habits[i].emoji} ${habits[i].name}',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w500, fontSize: 12,
                          color: colors.ink, height: 1.2)),
                  Text(habits[i].frequencyLabel,
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                          color: colors.ink3, height: 1.3)),
                ]),
              ),
              Text('${habits[i].weeklyFilledCount}/7',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontWeight: FontWeight.w600, fontSize: 12,
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
  final TaskEraColors colors;
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
        Text(l.calendarThisWeekLabel.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
            fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        SizedBox(height: 10),
        Row(children: [
          _StatCell('$totalEvents', l.eventsLabel, colors.ink, colors),
          _StatCell('—', l.deepWorkLabel, TaskEraColors.acc, colors),
          _StatCell('—', l.conflicts, TaskEraColors.q1, colors),
        ]),
      ]),
    );
  }
}

// ── Notes section ─────────────────────────────────────────────────────────────

class _NotesSection extends ConsumerWidget {
  final TaskEraColors colors;
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
        Text(l.notes.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
            fontWeight: FontWeight.w700, color: colors.ink3, letterSpacing: 0.5, height: 1)),
        SizedBox(height: 10),
        Row(children: [
          _StatCell('$total', l.total, colors.ink, colors),
          _StatCell('$ai', l.aiActionsLabel, TaskEraColors.acc2, colors),
          _StatCell('$pinned', l.pinnedLabel, TaskEraColors.q4, colors),
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
  final TaskEraColors colors;
  const _StatCell(this.value, this.label, this.valueColor, this.colors);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 15,
            fontWeight: FontWeight.w700, color: colors.textOrPlain(valueColor), height: 1.2)),
        Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
            color: colors.ink3, height: 1.3)),
      ]),
    );
  }
}

// ── Invite button ─────────────────────────────────────────────────────────────

class _InviteButton extends StatelessWidget {
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _InviteButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr0),
        ),
        alignment: Alignment.center,
        child: Text('🎁 ${AppL10n.of(context).inviteFriends}',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                fontWeight: FontWeight.w600, color: colors.accent2, height: 1)),
      ),
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
            ? SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFFF453A)))
            : Text(AppL10n.of(context).signOut,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                    fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
      ),
    );
  }
}

// ── Persona card — surfaces the onboarding answers (role / focus / peak) ───────

class _PersonaCard extends ConsumerWidget {
  final TaskEraColors colors;
  const _PersonaCard({required this.colors});

  static const _roles = [
    ('💼', 'Professional / Founder'), ('📚', 'Student'),
    ('🚀', 'Freelancer / Solopreneur'), ('⚡', 'ADHD / Overwhelmed'),
    ('💪', 'Building discipline'),
  ];
  static const _focus = [
    ('🎯', 'Deep work blocks'), ('🍅', 'Pomodoro · 25/5'),
    ('✅', 'Task-by-task'), ('🌊', 'Flexible / Flow'),
  ];
  static const _peak = [
    ('🌅', 'Early bird · 5–9 AM'), ('☀️', 'Morning · 9 AM–12 PM'),
    ('🌤', 'Afternoon · 1–5 PM'), ('🌙', 'Night owl · 6 PM–midnight'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(sharedPreferencesProvider);
    (String, String)? pick(List<(String, String)> opts, String key) {
      final i = p.getInt(key);
      return (i != null && i >= 0 && i < opts.length) ? opts[i] : null;
    }
    final rows = <(String, (String, String))>[];
    final r = pick(_roles, 'taskera.onboard.role');
    if (r != null) rows.add(('You are', r));
    final f = pick(_focus, 'taskera.onboard.focusStyle');
    if (f != null) rows.add(('Focus style', f));
    final pk = pick(_peak, 'taskera.onboard.peakHours');
    if (pk != null) rows.add(('Peak hours', pk));
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('YOUR STYLE',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 0.5, color: colors.ink3, height: 1)),
          SizedBox(height: 10),
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: 9),
            Row(children: [
              Text(rows[i].$2.$1, style: TextStyle(fontSize: 15, height: 1)),
              SizedBox(width: 9),
              Expanded(
                child: Text(rows[i].$2.$2,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w500,
                        color: colors.ink, height: 1.1)),
              ),
              Text(rows[i].$1,
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink3, height: 1)),
            ]),
          ],
        ]),
      ),
    );
  }
}

// ── Productivity streak banner ────────────────────────────────────────────────

class _StreakBanner extends ConsumerWidget {
  final TaskEraColors colors;
  const _StreakBanner({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(doneTasksProvider).value ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = done
        .where((t) => t.doneAt != null)
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet();

    // Current streak: consecutive days back from today (or yesterday).
    var current = 0;
    var a = days.contains(today) ? today : today.subtract(const Duration(days: 1));
    while (days.contains(a)) {
      current++;
      a = a.subtract(const Duration(days: 1));
    }
    // Best streak ever.
    var best = 0;
    if (days.isNotEmpty) {
      final sorted = days.toList()..sort();
      var run = 1;
      best = 1;
      for (var i = 1; i < sorted.length; i++) {
        if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
          run++;
          if (run > best) best = run;
        } else {
          run = 1;
        }
      }
    }
    final activeMonth =
        days.where((d) => d.year == today.year && d.month == today.month).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0x12FF6B35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: const Color(0x33FF6B35)),
      ),
      child: Row(children: [
        Text('🔥', style: TextStyle(fontSize: 26, height: 1)),
        SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$current day${current == 1 ? '' : 's'} streak',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 16,
                    fontWeight: FontWeight.w700, color: colors.ink, height: 1.1)),
            SizedBox(height: 2),
            Text(
                current > 0
                    ? 'Best $best d · $activeMonth active this month'
                    : 'Complete a task today to start a streak',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

// ── At-a-glance lifetime totals ───────────────────────────────────────────────

class _LifetimeStatsCard extends ConsumerWidget {
  final TaskEraColors colors;
  const _LifetimeStatsCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(doneTasksProvider).value ?? [];
    final allTasks = ref.watch(allTasksProvider).value ?? [];
    final goals = ref.watch(goalsProvider).value ?? [];

    final totalDone = done.length;
    final focusSecs = allTasks.fold<int>(0, (s, t) => s + t.totalFocusSeconds);
    final fh = focusSecs ~/ 3600;
    final fm = (focusSecs % 3600) ~/ 60;
    final focusLabel = fh > 0 ? '${fh}h' : '${fm}m';
    final goalsHit = goals.where((g) => g.progressPct >= 1.0).length;
    final activeDays = done
        .where((t) => t.doneAt != null)
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet()
        .length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('AT A GLANCE',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 0.5, color: colors.ink3, height: 1)),
        SizedBox(height: 12),
        Row(children: [
          _StatCell('$totalDone', 'Tasks done', colors.successFg, colors),
          _StatCell(focusLabel, 'Focus time', TaskEraColors.acc2, colors),
          _StatCell('$goalsHit', 'Goals hit', TaskEraColors.q2, colors),
          _StatCell('$activeDays', 'Active days', colors.ink, colors),
        ]),
      ]),
    );
  }
}

// ── Quadrant balance (lifetime completion distribution) ───────────────────────

class _QuadrantBalanceCard extends ConsumerWidget {
  final TaskEraColors colors;
  const _QuadrantBalanceCard({required this.colors});

  static Color _qc(int q) => switch (q) {
        1 => TaskEraColors.q1,
        2 => TaskEraColors.q2,
        3 => TaskEraColors.q3,
        _ => TaskEraColors.q4,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(doneTasksProvider).value ?? [];
    final counts = {1: 0, 2: 0, 3: 0, 4: 0};
    for (final t in done) {
      final q = (t.quadrant >= 1 && t.quadrant <= 4) ? t.quadrant : 4;
      counts[q] = counts[q]! + 1;
    }
    final total = done.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('QUADRANT BALANCE',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
                    letterSpacing: 0.5, color: colors.ink3, height: 1)),
          ),
          Text('lifetime',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink3, height: 1)),
        ]),
        SizedBox(height: 12),
        if (total == 0)
          Text('No completed tasks yet',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3))
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(children: [
                for (final q in [1, 2, 3, 4])
                  if (counts[q]! > 0)
                    Expanded(flex: counts[q]!, child: Container(color: _qc(q))),
              ]),
            ),
          ),
          SizedBox(height: 10),
          Row(children: [
            for (final q in [1, 2, 3, 4]) ...[
              if (q > 1) SizedBox(width: 8),
              Expanded(
                child: Row(children: [
                  Container(width: 7, height: 7,
                      decoration: BoxDecoration(color: _qc(q), shape: BoxShape.circle)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text('Q$q ${(counts[q]! / total * 100).round()}%',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink2, height: 1)),
                  ),
                ]),
              ),
            ],
          ]),
        ],
      ]),
    );
  }
}

// ── Account details ───────────────────────────────────────────────────────────

class _AccountCard extends ConsumerWidget {
  final TaskEraColors colors;
  const _AccountCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPro = ref.watch(isProProvider);
    final l = AppL10n.of(context);

    final email = user?.email ?? 'Local storage (this device)';
    final signIn = () {
      if (user == null) return 'Local — no account';
      final p = user.appMetadata['provider'] as String?;
      switch (p) {
        case 'google':
          return 'Google';
        case 'apple':
          return 'Apple';
        case 'azure':
        case 'microsoft':
          return 'Microsoft';
        case 'email':
          return 'Email';
        default:
          return (p != null && p.isNotEmpty) ? '${p[0].toUpperCase()}${p.substring(1)}' : 'Email';
      }
    }();
    final memberSince = () {
      final c = user?.createdAt;
      final dt = c == null ? null : DateTime.tryParse(c);
      if (dt == null) return '—';
      final months = l.monthsAbbr.split(',');
      return '${months[dt.month - 1]} ${dt.year}';
    }();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('ACCOUNT',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 0.5, color: colors.ink3, height: 1)),
        SizedBox(height: 8),
        _AccountRow(label: 'Email', value: email, colors: colors),
        _AccountRow(label: 'Sign-in', value: signIn, colors: colors),
        _AccountRow(label: 'Member since', value: memberSince, colors: colors),
        _AccountRow(label: 'Plan', value: isPro ? 'Pro' : 'Free', colors: colors),
      ]),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label, value;
  final TaskEraColors colors;
  const _AccountRow({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 96,
          child: Text(label,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3, height: 1.2)),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
                  color: colors.ink, height: 1.2)),
        ),
      ]),
    );
  }
}
