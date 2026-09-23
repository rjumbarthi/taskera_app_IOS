import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/tasks_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../settings/prefs_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/ai_insight_card.dart';

class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  final _biggestWinCtrl = TextEditingController();
  final _drainCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController();

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  DateTime get _monday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  int get _weekNum {
    final d = _monday;
    final dayOfYear = d.difference(DateTime(d.year, 1, 1)).inDays + 1;
    return ((dayOfYear - 1) ~/ 7) + 1;
  }

  String get _weekKey => '${_monday.year}-W$_weekNum';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = ref.read(sharedPreferencesProvider);
      final k = _weekKey;
      setState(() {
        _biggestWinCtrl.text = p.getString('taskera.wr.win.$k') ?? '';
        _drainCtrl.text      = p.getString('taskera.wr.drain.$k') ?? '';
        _priorityCtrl.text   = p.getString('taskera.wr.priority.$k') ?? '';
      });
    });
  }

  Future<void> _save() async {
    final p = ref.read(sharedPreferencesProvider);
    final k = _weekKey;
    await p.setString('taskera.wr.win.$k',      _biggestWinCtrl.text.trim());
    await p.setString('taskera.wr.drain.$k',    _drainCtrl.text.trim());
    await p.setString('taskera.wr.priority.$k', _priorityCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Review saved ✓', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
      backgroundColor: Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _biggestWinCtrl.dispose();
    _drainCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final l = AppL10n.of(context);

    // ── Live week data ────────────────────────────────────────────────────────
    final monday     = _monday;
    final sunday     = monday.add(const Duration(days: 6));
    final nextMonday = monday.add(const Duration(days: 7));
    final dateRange  = 'Week $_weekNum · ${_months[monday.month - 1]} ${monday.day}–'
        '${monday.month == sunday.month ? '${sunday.day}' : '${_months[sunday.month - 1]} ${sunday.day}'}';

    final done    = ref.watch(doneTasksProvider).valueOrNull ?? const [];
    final q1a     = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? const [];
    final q2a     = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? const [];
    final q3a     = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? const [];
    final q4a     = ref.watch(quadrantTasksProvider(4)).valueOrNull ?? const [];
    final active  = [...q1a, ...q2a, ...q3a, ...q4a];
    final habits  = ref.watch(habitsProvider).valueOrNull ?? const [];
    final sessions = ref.watch(weeklyFocusSessionsProvider).valueOrNull ?? const [];

    final doneThisWeek = done.where((t) =>
        t.doneAt != null && !t.doneAt!.isBefore(monday) && t.doneAt!.isBefore(nextMonday)).toList();
    final doneCount   = doneThisWeek.length;
    final missedCount = active.where((t) => t.isOverdue).length;
    final habitsTotal = habits.length;
    final habitsHit   = habits.where((h) => h.streakLabel.contains('🔥')).length;
    final loggedSec   = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
    final loggedStr   = loggedSec >= 3600
        ? '${(loggedSec / 3600) >= 10 ? (loggedSec / 3600).round() : (loggedSec / 3600).toStringAsFixed(1)}h'
        : (loggedSec >= 60 ? '${(loggedSec / 60).round()}m' : '0h');

    ({double frac, int count}) quadStat(int q) {
      final dq  = doneThisWeek.where((t) => t.quadrant == q).length;
      final aq  = active.where((t) => t.quadrant == q).length;
      final tot = dq + aq;
      return (frac: tot == 0 ? 0.0 : dq / tot, count: dq);
    }
    final qs = [quadStat(1), quadStat(2), quadStat(3), quadStat(4)];
    final pct = qs.map((q) => (q.frac.clamp(0, 1) * 100).round()).toList();
    final aiInput = (StringBuffer()
          ..writeln('Weekly review data ($dateRange):')
          ..writeln('- Tasks completed: $doneCount')
          ..writeln('- Tasks overdue/missed: $missedCount')
          ..writeln('- Habits hit: $habitsHit of $habitsTotal')
          ..writeln('- Focus time logged: $loggedStr')
          ..writeln('- Quadrant completion: Q1 ${pct[0]}%, Q2 ${pct[1]}%, Q3 ${pct[2]}%, Q4 ${pct[3]}%')
          ..write(_biggestWinCtrl.text.trim().isNotEmpty ? '- Biggest win: ${_biggestWinCtrl.text.trim()}\n' : '')
          ..write(_drainCtrl.text.trim().isNotEmpty ? '- What drained energy: ${_drainCtrl.text.trim()}\n' : '')
          ..write(_priorityCtrl.text.trim().isNotEmpty ? "- Next week's priority: ${_priorityCtrl.text.trim()}\n" : ''))
        .toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header — matches profile branch sub-screen pattern
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.weeklyReviewLabel,
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontVariations: [FontVariation('wght', 600)],
                      fontSize: 19,
                      letterSpacing: -0.5,
                      color: colors.ink,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    dateRange,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: colors.ink3,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Biggest Win
                _SectionCard(
                  bgColor: const Color(0x147FBA00),
                  borderColor: const Color(0x407FBA00),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🏆 BIGGEST WIN',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colors.successFg,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _biggestWinCtrl,
                        hint: l.weeklyWinHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Week Summary
                _SectionCard(
                  bgColor: Colors.transparent,
                  borderColor: colors.bdr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'WEEK SUMMARY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colors.ink3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(child: _StatBox(value: '$doneCount',   label: 'Done',   valueColor: TaskEraColors.q2,           colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: '$missedCount', label: 'Missed', valueColor: TaskEraColors.q1,           colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: '$habitsHit/$habitsTotal', label: 'Habits', valueColor: const Color(0xFFBF5AF2), colors: colors)),
                          const SizedBox(width: 5),
                          Expanded(child: _StatBox(value: loggedStr, label: 'Logged', valueColor: TaskEraColors.acc2,         colors: colors)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _QuadBar(label: 'Q1', color: TaskEraColors.q1, fraction: qs[0].frac, count: '${qs[0].count}', colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q2', color: TaskEraColors.q2, fraction: qs[1].frac, count: '${qs[1].count}', colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q3', color: TaskEraColors.q3, fraction: qs[2].frac, count: '${qs[2].count}', colors: colors),
                      const SizedBox(height: 5),
                      _QuadBar(label: 'Q4', color: TaskEraColors.q4, fraction: qs[3].frac, count: '${qs[3].count}', colors: colors),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // What drained energy?
                _SectionCard(
                  bgColor: const Color(0x0FFF453A),
                  borderColor: const Color(0x33FF453A),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚡ WHAT DRAINED ENERGY?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFFFF8080),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _drainCtrl,
                        hint: l.weeklyBlockerHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Next week's #1 priority
                _SectionCard(
                  bgColor: TaskEraColors.accBg,
                  borderColor: const Color(0x400A84FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 NEXT WEEK\'S #1 PRIORITY',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: TaskEraColors.acc2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _ExpandingField(
                        controller: _priorityCtrl,
                        hint: l.weeklySuccessHint,
                        colors: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // TaskEra AI insight — on-demand, real LLM
                AiInsightCard(
                  input: aiInput,
                  hint: 'Reflect on my week with TaskEra AI',
                  margin: EdgeInsets.zero,
                ),
                const SizedBox(height: 10),

                // Save button
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0x127FBA00),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Save review ✓',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.successFg,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared section card wrapper ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final Widget child;

  const _SectionCard({
    required this.bgColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: borderColor),
      ),
      child: child,
    );
  }
}

// ── Auto-expanding text field (transparent, borderless) ───────────────────────

class _ExpandingField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TaskEraColors colors;

  const _ExpandingField({
    required this.controller,
    required this.hint,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1.5),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Stat box — tinted with the value's semantic color ────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final TaskEraColors colors;

  const _StatBox({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 7, 4, 7),
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(width: 0.5, color: valueColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1.2),
          ),
        ],
      ),
    );
  }
}

// ── Quad progress bar row ─────────────────────────────────────────────────────

class _QuadBar extends StatelessWidget {
  final String label;
  final Color color;
  final double fraction;
  final String count;
  final TaskEraColors colors;

  const _QuadBar({
    required this.label,
    required this.color,
    required this.fraction,
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: color, height: 1),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: Stack(
                children: [
                  Container(color: colors.surf3),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 20,
          child: Text(
            count,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1),
          ),
        ),
      ],
    );
  }
}
