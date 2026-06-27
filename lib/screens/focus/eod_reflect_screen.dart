import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/habits_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class EodReflectScreen extends ConsumerStatefulWidget {
  const EodReflectScreen({super.key});

  @override
  ConsumerState<EodReflectScreen> createState() => _EodReflectScreenState();
}

class _EodReflectScreenState extends ConsumerState<EodReflectScreen> {
  final _bestMomentController = TextEditingController();

  @override
  void dispose() {
    _bestMomentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrow = todayStart.add(const Duration(days: 1));

    // Done tasks today + a productive-day streak.
    final doneTasks = ref.watch(doneTasksProvider).value ?? [];
    final doneDays = doneTasks
        .where((t) => t.doneAt != null)
        .map((t) => DateTime(t.doneAt!.year, t.doneAt!.month, t.doneAt!.day))
        .toSet();
    final doneToday = doneDays.contains(todayStart)
        ? doneTasks.where((t) =>
            t.doneAt != null && !t.doneAt!.isBefore(todayStart) && t.doneAt!.isBefore(tomorrow)).length
        : 0;
    var streak = 0;
    var anchor = doneDays.contains(todayStart) ? todayStart : todayStart.subtract(const Duration(days: 1));
    while (doneDays.contains(anchor)) {
      streak++;
      anchor = anchor.subtract(const Duration(days: 1));
    }

    // Habits checked off today (distinct non-skipped logs).
    final todayLogs = ref.watch(habitWeekLogsProvider((todayStart, tomorrow))).value ?? [];
    final habitsToday = todayLogs.map((l) => l.habitId).toSet().length;

    // Focus time tracked today.
    final sessions = ref.watch(weeklyFocusSessionsProvider).value ?? [];
    final focusSecs = sessions
        .where((s) => !s.startedAt.isBefore(todayStart))
        .fold<int>(0, (a, s) => a + s.durationSeconds);
    final fm = focusSecs ~/ 60;
    final fh = fm ~/ 60;
    final focusedLabel = fh > 0 ? (fm % 60 > 0 ? '${fh}h ${fm % 60}m' : '${fh}h') : '${fm}m';

    const wd = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    final h12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    final dateLabel = '${wd[now.weekday - 1]} · $h12:${now.minute.toString().padLeft(2, '0')} $ampm';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.go(KaalRoutes.focus)),
              const SizedBox(width: 8),
              Text(
                'EOD Reflect',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: colors.ink,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xEB0A0A0C),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _ReflectCard(
                  colors: colors,
                  controller: _bestMomentController,
                  dateLabel: dateLabel,
                  doneCount: doneToday,
                  habitCount: habitsToday,
                  focusedLabel: focusedLabel,
                  streak: streak,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reflect card ──────────────────────────────────────────────────────────────

class _ReflectCard extends StatelessWidget {
  final KaalColors colors;
  final TextEditingController controller;
  final String dateLabel;
  final int doneCount;
  final int habitCount;
  final String focusedLabel;
  final int streak;

  const _ReflectCard({
    required this.colors,
    required this.controller,
    required this.dateLabel,
    required this.doneCount,
    required this.habitCount,
    required this.focusedLabel,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => context.go(KaalRoutes.focus),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      color: Color(0x66FFFFFF),
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text('🌙', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, height: 1)),
          const SizedBox(height: 9),
          Text(
            dateLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Color(0xFF5A5A62),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(value: '$doneCount',  label: 'done',    valueColor: colors.successFg),
                _VertDivider(color: colors.bdr),
                _StatItem(value: '$habitCount',  label: 'habits',  valueColor: KaalColors.q4),
                _VertDivider(color: colors.bdr),
                _StatItem(value: focusedLabel, label: 'focused', valueColor: KaalColors.acc2),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"Did you do meaningful work today?"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 19,
              fontWeight: FontWeight.w500,
              color: colors.ink,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Not urgent tasks — important ones. The Q2 work that moves your life forward.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: colors.ink3,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: const Color(0x0AFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEST MOMENT TODAY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.ink3,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'e.g. "Shipped the new onboarding flow"',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: colors.ink3,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go(KaalRoutes.focus),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: KaalColors.q2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Yes ✓',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go(KaalRoutes.focus),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: colors.surf3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Not really',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.ink2,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current streak: ',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1),
              ),
              Text(
                '$streak day${streak == 1 ? '' : 's'} 🔥',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.go(KaalRoutes.focus),
            child: Text(
              'Skip for tonight',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: colors.ink3,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat item (done / habits / focused) ───────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              color: Color(0xFF5A5A62),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  final Color color;
  const _VertDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.5,
      child: ColoredBox(color: color),
    );
  }
}
