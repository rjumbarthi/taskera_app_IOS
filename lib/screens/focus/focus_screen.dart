import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routing/routes.dart';
import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_motion.dart';
import '../../theme/kaal_shape.dart';
import '../../theme/kaal_theme.dart';
import '../../theme/kaal_type.dart';
import '../../data/database.dart' show Task;
import '../../data/providers/database_provider.dart';
import '../../data/providers/goals_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';
import '../../widgets/quadrant_card.dart';
import '../../widgets/task_meta_row.dart';
import '../../l10n/app_l10n.dart';
import '../../data/repositories/focus_session_repository.dart';

// SVG constants — stroke="white" so colorFilter drives the final color
const _kStarSvg = '<svg width="16" height="16" viewBox="0 0 22 22" fill="none" '
    'stroke="white" stroke-width="1.8" stroke-linecap="round">'
    '<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 '
    '5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>';

const _kInfoSvg = '<svg width="18" height="18" viewBox="0 0 22 22" fill="none" '
    'xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="11" cy="11" r="9" stroke="white" stroke-width="1.8"/>'
    '<line x1="11" y1="10" x2="11" y2="15" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="11" y1="7.5" x2="11" y2="7.5" stroke="white" stroke-width="2.5" stroke-linecap="round"/>'
    '</svg>';


class FocusDashboardScreen extends ConsumerWidget {
  const FocusDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(kaalSettingsProvider);
    final utilGrid = _UtilGrid(
      showPeak:  s.sw('focusPeak'),
      showBrain: s.sw('focusBrain'),
    );

    return LayoutBuilder(
      builder: (context, c) {
        // Wide (desktop/web sidebar) → two-column dashboard; else single column.
        final wide = c.maxWidth >= 600;
        final Widget content = wide
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TaskMetaRow(),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main column — hero action + the Eisenhower matrix.
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            _DoThisNowCard(),
                            SizedBox(height: 8),
                            _QuadGrid(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Side column — goals, utilities, progress.
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _GoalsStrip(),
                            const SizedBox(height: 8),
                            utilGrid,
                            const SizedBox(height: 8),
                            const _ProgressCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _GoalsStrip(),
                  const SizedBox(height: 5),
                  const TaskMetaRow(),
                  const SizedBox(height: 5),
                  const _DoThisNowCard(),
                  const SizedBox(height: 5),
                  const _QuadGrid(),
                  const SizedBox(height: 5),
                  utilGrid,
                  const SizedBox(height: 5),
                  const _ProgressCard(),
                ],
              );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          child: content,
        );
      },
    );
  }
}

// ── Goals card (unified) ──────────────────────────────────────────────────────

class _GoalsStrip extends ConsumerWidget {
  const _GoalsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final goals = ref.watch(goalsProvider).valueOrNull ?? [];
    final shown = goals.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header — taps to goals list
          GestureDetector(
            onTap: () => context.go(KaalRoutes.goals),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Text(
                    AppL10n.of(context).goals.toUpperCase(),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5,
                        color: colors.ink3, height: 1),
                  ),
                  const Spacer(),
                  Text(
                    '${goals.length} ${AppL10n.of(context).active.toLowerCase()}  ›',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                        color: colors.ink3, height: 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Goal columns — each taps to that goal's detail
          if (shown.isEmpty)
            GestureDetector(
              onTap: () => context.go(KaalRoutes.goals),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  AppL10n.of(context).noGoalsTapAdd,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    for (int i = 0; i < shown.length; i++) ...[
                      if (i > 0) VerticalDivider(width: 1, thickness: 0.5, color: colors.bdr),
                      Expanded(child: GestureDetector(
                        onTap: () => context.push('/focus/goals/${shown[i].id}'),
                        behavior: HitTestBehavior.opaque,
                        child: _GoalCol(
                          pct: '${(shown[i].progressPct * 100).round()}%',
                          color: Color(shown[i].accentColorValue),
                          label: shown[i].title,
                          colors: colors,
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalCol extends StatelessWidget {
  final String pct;
  final Color color;
  final String label;
  final KaalColors colors;
  const _GoalCol({required this.pct, required this.color, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          pct,
          style: TextStyle(
            fontFamily: 'Fraunces',
            fontVariations: const [FontVariation('wght', 700)],
            fontSize: 16,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              color: colors.ink3, height: 1.2),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── DO THIS NOW card ──────────────────────────────────────────────────────────

class _DoThisNowCard extends ConsumerStatefulWidget {
  const _DoThisNowCard();

  @override
  ConsumerState<_DoThisNowCard> createState() => _DoThisNowCardState();
}

class _DoThisNowCardState extends ConsumerState<_DoThisNowCard> {
  int  _i       = 0;
  bool _started = false;
  bool _paused  = false;
  Timer? _ticker;
  int _total     = 0; // session length (seconds), from the task's allocated time
  int _remaining = 0; // counts down to 0
  int get _elapsed => _total - _remaining;

  // Default minutes when a task has no allocated time (matches the focus modal).
  static int _defaultMins(int q) => switch (q) { 1 => 25, 2 => 50, _ => 15 };

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // Start the inline focus countdown on the card (one tap — no extra screens).
  void _start(Task task) {
    final mins = task.timeAllocatedMin ?? _defaultMins(task.quadrant);
    _ticker?.cancel();
    setState(() {
      _started = true;
      _paused = false;
      _total = mins * 60;
      _remaining = _total;
    });
    // Mirror into the shared tracker so the Time Log shows this exact task.
    ref.read(timeTrackerProvider.notifier).startNew(task.title);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused || !mounted) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        setState(() => _remaining = 0);
        _ticker?.cancel();
      }
    });
  }

  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    ref.read(timeTrackerProvider.notifier).stop();
    if (mounted) setState(() { _started = false; _paused = false; _total = 0; _remaining = 0; });
  }

  // Persist the elapsed time as a focus session so the weekly review captures it.
  void _logSession(Task task) {
    if (_elapsed <= 0) return;
    ref.read(focusSessionRepositoryProvider).logSession(FocusSessionRecord(
      taskId: task.id,
      quadrant: task.quadrant,
      startedAt: DateTime.now().subtract(Duration(seconds: _elapsed)),
      durationSeconds: _elapsed,
      completed: true,
    ));
  }

  void _markDone(Task task) {
    ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, true);
    final navBottom = MediaQuery.viewPaddingOf(context).bottom + 50 + 8;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(SnackBar(
      content: Text(
        '✓  ${task.title}',
        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.fromLTRB(12, 0, 12, navBottom),
      duration: const Duration(milliseconds: 2000),
      action: SnackBarAction(
        label: AppL10n.of(context).undo,
        textColor: KaalColors.acc2,
        onPressed: () {
          ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, false);
        },
      ),
    ));
    // Safety net: guarantee the toast clears after 2s even if the per-second
    // focus-timer rebuilds interfere with the SnackBar's internal timer.
    Timer(const Duration(milliseconds: 2100), () {
      try { controller.close(); } catch (_) {}
    });
  }


  static ({Color color, Color bg, Color border, Color iconBg, String label})
      _themeFor(int q) => switch (q) {
            1 => (
                color: KaalColors.q1,
                bg: const Color(0x12F25022),
                border: const Color(0x4DF25022),
                iconBg: const Color(0x1FF25022),
                label: 'Q1 · Urgent'
              ),
            2 => (
                color: KaalColors.q2,
                bg: const Color(0x127FBA00),
                border: const Color(0x4D7FBA00),
                iconBg: const Color(0x1F7FBA00),
                label: 'Q2 · Important'
              ),
            _ => (
                color: KaalColors.q3,
                bg: const Color(0x1200A4EF),
                border: const Color(0x4D00A4EF),
                iconBg: const Color(0x1F00A4EF),
                label: 'Q3 · Delegate'
              ),
          };

  static List<Task> _filteredSorted(
      List<Task> q1, List<Task> q2, List<Task> q3, {bool useScore = true}) {
    final all = [...q1, ...q2, ...q3];
    all.sort((a, b) {
      if (useScore) {
        final cmp = (b.urgencyScore ?? 0.0).compareTo(a.urgencyScore ?? 0.0);
        return cmp != 0 ? cmp : a.quadrant.compareTo(b.quadrant);
      }
      return a.quadrant.compareTo(b.quadrant);
    });
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final q1 = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [];
    final q2 = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [];
    final q3 = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [];
    final scoreRec = ref.watch(kaalSettingsProvider.select((s) => s.sw('scoreRec')));

    final tasks = _filteredSorted(q1, q2, q3, useScore: scoreRec);
    if (tasks.isEmpty) return const _DtnEmpty();

    final idx = _i.clamp(0, tasks.length - 1);
    final t = tasks[idx];
    final th = _themeFor(t.quadrant);

    // "Q1 · Urgent · Overdue · Score 9.2 · 25 min"
    final metaParts = [th.label];
    if (t.isOverdue) metaParts.add(AppL10n.of(context).overdue);
    if (t.urgencyScore != null) metaParts.add('Score ${t.urgencyScore!.toStringAsFixed(1)}');
    if (t.timeAllocatedMin != null) metaParts.add('${t.timeAllocatedMin} min');
    final metaLine = metaParts.join(' · ');

    return SizedBox(
      height: 178,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: th.bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            // ── Header row — star icon · title · info icon ───────────────────
            Positioned(
              top: 10, left: 14, right: 14,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: th.iconBg,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.string(
                      _kStarSvg, width: 15, height: 15,
                      colorFilter: ColorFilter.mode(th.color, BlendMode.srcIn),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppL10n.of(context).doThisNow,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: KaalType.xl,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.45,
                        color: th.color,
                        height: 1,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('${KaalRoutes.focusList}?f=today'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: th.iconBg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.string(
                        _kInfoSvg, width: 16, height: 16,
                        colorFilter: ColorFilter.mode(th.color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Task title — centered block, top: 50 ────────────────────────
            Positioned(
              top: 50, left: 14, right: 14,
              child: GestureDetector(
                onTap: () => context.push('/focus/taskdetail/${t.id}'),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 230),
                    child: Text(
                      t.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: KaalType.lg,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                        height: 1.28,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Meta + action row — pinned to bottom ─────────────────────────
            Positioned(
              bottom: 7, left: 14, right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _started ? _fmt(_remaining) : metaLine,
                    textAlign: TextAlign.center,
                    style: _started
                        ? TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: th.color,
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          )
                        : TextStyle(
                            fontFamily: 'Inter',
                            fontSize: KaalType.sm,
                            fontWeight: FontWeight.w500,
                            color: th.color,
                            height: 1,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(
                        width: 58,
                        child: _DtnSideBtn(
                          label: AppL10n.of(context).skip,
                          colors: colors,
                          onTap: tasks.length > 1
                              ? () {
                                  _ticker?.cancel();
                                  ref.read(timeTrackerProvider.notifier).stop();
                                  setState(() {
                                    _i = (_i + 1) % tasks.length;
                                    _started = false;
                                    _paused = false;
                                    _total = 0;
                                    _remaining = 0;
                                  });
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _started
                              ? Row(
                                  key: const ValueKey('active'),
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _paused = !_paused);
                                          final tracker = ref.read(timeTrackerProvider.notifier);
                                          _paused ? tracker.pause() : tracker.resume();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 7),
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0.5, color: colors.bdr),
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _paused ? AppL10n.of(context).resume : AppL10n.of(context).pauseLabel,
                                            style: TextStyle(fontFamily: 'Inter', fontSize: KaalType.sm, fontWeight: FontWeight.w600, color: colors.ink2, height: 1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          _logSession(t);
                                          _markDone(t);
                                          _stopTimer();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 7),
                                          decoration: BoxDecoration(
                                            color: KaalColors.success.withAlpha(0x1A),
                                            border: Border.all(width: 0.5, color: KaalColors.success),
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(AppL10n.of(context).done,
                                              style: TextStyle(fontFamily: 'Inter', fontSize: KaalType.sm, fontWeight: FontWeight.w700, color: colors.successFg, height: 1)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  key: const ValueKey('idle'),
                                  onTap: () => _start(t),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                      color: th.color.withAlpha(0x1A),
                                      border: Border.all(width: 0.5, color: th.color),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppL10n.of(context).startNow,
                                      style: TextStyle(fontFamily: 'Inter', fontSize: KaalType.sm, fontWeight: FontWeight.w700, color: th.color, height: 1),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 82,
                        child: _DtnSideBtn(
                          label: AppL10n.of(context).viewAll,
                          colors: colors,
                          onTap: () => context.go('${KaalRoutes.focusList}?f=today'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// dtn-side-action: min-width 52, padding 7 8, radius 11, bdr border, ink2 text
class _DtnSideBtn extends StatelessWidget {
  final String label;
  final KaalColors colors;
  final VoidCallback? onTap;
  const _DtnSideBtn({required this.label, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: colors.bdr),
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.ink2,
            height: 1,
          ),
        ),
      ),
    );
  }
}


class _DtnEmpty extends StatelessWidget {
  const _DtnEmpty();

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppL10n.of(context).doThisNow,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.ink3,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppL10n.of(context).noTasksDueToday,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: colors.ink3,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quadrant 2×2 grid ─────────────────────────────────────────────────────────

class _QuadGrid extends ConsumerWidget {
  const _QuadGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q1 = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [];
    final q2 = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [];
    final q3 = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [];
    final q4 = ref.watch(quadrantTasksProvider(4)).valueOrNull ?? [];
    final done = ref.watch(doneTasksProvider).valueOrNull ?? [];

    double prog(List<Task> active, int quad) {
      final d = done.where((t) => t.quadrant == quad).length;
      final total = active.length + d;
      return total > 0 ? d / total : 0.0;
    }

    final now = DateTime.now();
    final tomorrowStart = DateTime(now.year, now.month, now.day + 1);
    int dueToday(List<Task> tasks) => tasks.where((t) {
          final d = t.dueDate;
          return d != null && d.isBefore(tomorrowStart);
        }).length;

    final q1Overdue = q1.where((t) => t.isOverdue).length;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _FocusQuadCard(
              quadrant: KaalQuadrant.q1, action: AppL10n.of(context).doNow, emoji: '⚡',
              count: q1.length, overdue: q1Overdue, today: dueToday(q1),
              progressFraction: prog(q1, 1),
              minHeight: 96,
              onTap: () => context.push('/tasks/quad/q1'),
            )),
            const SizedBox(width: 6),
            Expanded(child: _FocusQuadCard(
              quadrant: KaalQuadrant.q2, action: AppL10n.of(context).scheduleLabel, emoji: '🎯',
              count: q2.length, today: dueToday(q2),
              progressFraction: prog(q2, 2),
              minHeight: 96,
              onTap: () => context.push('/tasks/quad/q2'),
            )),
          ]),
        ),
        const SizedBox(height: 6),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: _FocusQuadCard(
              quadrant: KaalQuadrant.q3, action: AppL10n.of(context).delegate, emoji: '🤝',
              count: q3.length, today: dueToday(q3),
              progressFraction: prog(q3, 3),
              onTap: () => context.push('/tasks/quad/q3'),
            )),
            const SizedBox(width: 6),
            Expanded(child: _FocusQuadCard(
              quadrant: KaalQuadrant.q4, action: AppL10n.of(context).eliminate, emoji: '🗑',
              count: q4.length,
              progressFraction: prog(q4, 4),
              onTap: () => context.push('/tasks/quad/q4'),
            )),
          ]),
        ),
      ],
    );
  }
}

// ── Focus-specific quad card ──────────────────────────────────────────────────
//
// Layout:
//   Row 1 — [emoji icon]  [action name]  [count]
//   Row 2 — [Q-label]  [⚠ overdue chip]  [📅 today chip]
//   Row 3 — [progress bar]

class _FocusQuadCard extends StatefulWidget {
  final KaalQuadrant quadrant;
  final String action;
  final String emoji;
  final int count;
  final int overdue;
  final int today;
  final double progressFraction;
  final double minHeight;
  final VoidCallback? onTap;

  const _FocusQuadCard({
    required this.quadrant,
    required this.action,
    required this.emoji,
    required this.count,
    this.overdue = 0,
    this.today = 0,
    required this.progressFraction,
    this.minHeight = 82,
    this.onTap,
  });

  @override
  State<_FocusQuadCard> createState() => _FocusQuadCardState();
}

class _FocusQuadCardState extends State<_FocusQuadCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.quadrant;

    final gradientColors = switch (q) {
      KaalQuadrant.q1 => const [Color(0xB89B1600), Color(0xFFF25022)],
      KaalQuadrant.q2 => const [Color(0xB8326E00), Color(0xFF7FBA00)],
      KaalQuadrant.q3 => const [Color(0xB8004080), Color(0xFF00A4EF)],
      KaalQuadrant.q4 => const [Color(0xB8784C00), Color(0xFFFFB900)],
    };

    final qNum = switch (q) {
      KaalQuadrant.q1 => 'Q1',
      KaalQuadrant.q2 => 'Q2',
      KaalQuadrant.q3 => 'Q3',
      KaalQuadrant.q4 => 'Q4',
    };

    final l = AppL10n.of(context);
    final metaText = switch (q) {
      KaalQuadrant.q1 => '${widget.overdue} ${l.overdue.toLowerCase()} · ${widget.count} ${l.tasks.toLowerCase()}',
      KaalQuadrant.q2 => '${widget.count} ${l.tasks.toLowerCase()} · ${l.onTrack}',
      _               => '${widget.count} ${l.tasks.toLowerCase()}',
    };

    final chipLabel = switch (q) {
      KaalQuadrant.q1 => widget.overdue > 0 ? l.overdue : null,
      KaalQuadrant.q2 => widget.today  > 0 ? l.focusToday : null,
      _               => null,
    };

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? KaalMotion.scalePressed : 1.0,
        duration: KaalMotion.fastPress,
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(minHeight: widget.minHeight),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5, color: q.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Top: emoji / title / meta — each on own row ───────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 11, 11, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(widget.emoji,
                          style: const TextStyle(fontSize: 20, height: 1)),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$qNum · ${widget.action}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: KaalType.md,
                              fontWeight: FontWeight.w800,
                              color: Color(0xE6000000),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            metaText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: KaalType.sm,
                              fontWeight: FontWeight.w700,
                              color: Color(0xCC000000),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // ── chip · count row ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 0, 11, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (chipLabel != null)
                      Text(
                        chipLabel,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: KaalType.sm,
                          fontWeight: FontWeight.w700,
                          color: Color(0xCC000000),
                          height: 1,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '${widget.count}',
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 700)],
                        fontSize: KaalType.md,
                        color: Color(0xD9000000),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // ── bar row: starts at chip-left, ends before count ────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 0, 11, 7),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1.5),
                        child: SizedBox(
                          height: 3,
                          child: Stack(
                            children: [
                              Container(color: const Color(0x26000000)),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: widget.progressFraction
                                    .clamp(0.0, 1.0),
                                child:
                                    Container(color: const Color(0x73000000)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Utility grid (Peak Hours + Brain Dump) ────────────────────────────────────

class _UtilGrid extends StatelessWidget {
  final bool showPeak;
  final bool showBrain;

  const _UtilGrid({required this.showPeak, required this.showBrain});

  @override
  Widget build(BuildContext context) {
    if (!showPeak && !showBrain) return const SizedBox.shrink();
    return Row(
      children: [
        if (showPeak) Expanded(child: Builder(builder: (context) => _UtilCard(
          emoji: '✦', label: AppL10n.of(context).peakHours, meta: AppL10n.of(context).notEnoughDataYet,
          accentColor: const Color(0xFF5856D6),
          iconBg: const Color(0x245856D6),
          borderColor: const Color(0x665856D6),
          compact: true,
          onTap: () => context.go(KaalRoutes.predictive),
        ))),
        if (showPeak && showBrain) const SizedBox(width: 6),
        if (showBrain) Expanded(child: Builder(builder: (context) => _UtilCard(
          emoji: '🧠', label: AppL10n.of(context).brainDump, meta: AppL10n.of(context).dumpSortLater,
          accentColor: const Color(0xFFBF5AF2),
          iconBg: const Color(0x24BF5AF2),
          borderColor: const Color(0x4DBF5AF2),
          compact: true,
          onTap: () => context.go(KaalRoutes.brainDump),
        ))),
      ],
    );
  }
}

// Generic utility card — mirrors qcard structure with custom accent theming.
class _UtilCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String meta;
  final Color accentColor;
  final Color iconBg;
  final Color borderColor;
  final bool compact;
  final VoidCallback? onTap;

  const _UtilCard({
    required this.emoji,
    required this.label,
    required this.meta,
    required this.accentColor,
    required this.iconBg,
    required this.borderColor,
    this.compact = false,
    this.onTap,
  });

  @override
  State<_UtilCard> createState() => _UtilCardState();
}

class _UtilCardState extends State<_UtilCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? KaalMotion.scalePressed : 1.0,
        duration: KaalMotion.fastPress,
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(minHeight: widget.compact ? 52 : 72),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: KaalShape.card,
            border: Border.all(width: 0.5, color: widget.borderColor),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(11, widget.compact ? 7 : 10, 11, widget.compact ? 7 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: widget.compact
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: widget.iconBg,
                            borderRadius: KaalShape.sgrpIcon,
                          ),
                          alignment: Alignment.center,
                          child: Text(widget.emoji, style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: widget.compact ? 0 : 4,
                            ),
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: widget.accentColor,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // meta line above progress bar, aligned with title
                    SizedBox(height: widget.compact ? 3 : 4),
                    Text(
                      widget.meta,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: colors.ink3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today's Progress card ─────────────────────────────────────────────────────

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = KaalTheme.of(context).colors;
    final l     = AppL10n.of(context);

    final q1 = ref.watch(quadrantTasksProvider(1)).valueOrNull ?? [];
    final q2 = ref.watch(quadrantTasksProvider(2)).valueOrNull ?? [];
    final q3 = ref.watch(quadrantTasksProvider(3)).valueOrNull ?? [];
    final q4 = ref.watch(quadrantTasksProvider(4)).valueOrNull ?? [];
    final done = ref.watch(doneTasksProvider).valueOrNull ?? [];

    final activeCount = q1.length + q2.length + q3.length + q4.length;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final doneToday = done
        .where((t) => t.doneAt != null && !t.doneAt!.isBefore(todayStart))
        .length;
    final total = activeCount + doneToday;
    final pct = total > 0 ? doneToday / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                l.todaysProgress.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colors.ink3,
                  height: 1,
                ),
              ),
              Expanded(
                child: Text(
                  '$doneToday / $total ${l.tasks.toLowerCase()}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.successFg,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 3,
              child: Stack(
                children: [
                  Container(color: colors.surf3),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: pct.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [KaalColors.q2, KaalColors.success],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
