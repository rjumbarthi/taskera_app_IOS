import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

enum _Badge { adapt, stretch, onTrack, watching }

extension _BadgeExt on _Badge {
  String get label => switch (this) {
    _Badge.adapt    => 'Adapt',
    _Badge.stretch  => 'Stretch',
    _Badge.onTrack  => 'On track',
    _Badge.watching => 'Watching',
  };
  Color get color => switch (this) {
    _Badge.adapt    => KaalColors.q4,
    _Badge.stretch  => KaalColors.acc2,
    _Badge.onTrack  => const Color(0xFF9FCD44),
    _Badge.watching => KaalColors.q3,
  };
  Color get bg => color.withAlpha(0x22);
}

class _RecurTask {
  final String title, current, pct, streakLabel;
  final _Badge badge;
  const _RecurTask(this.title, this.current, this.pct, this.streakLabel, this.badge);
}

const _recurTasks = [
  _RecurTask('Morning journaling', 'Daily',          '60%',  '',    _Badge.adapt),
  _RecurTask('Exercise',           'Weekdays',        '96%',  '',    _Badge.stretch),
  _RecurTask('Weekly review',      'Weekly Sun',      '100%', '5w',  _Badge.onTrack),
  _RecurTask('Team standup prep',  'Weekdays',        '72%',  '2w',  _Badge.watching),
];

class _Suggestion {
  final String title, current, pctLabel, body, action, keep;
  final _Badge badge;
  const _Suggestion(this.title, this.current, this.pctLabel, this.body, this.action, this.keep, this.badge);
}

const _suggestions = [
  _Suggestion(
    'Morning journaling',
    'Current: Daily · Completion: 60%',
    'Suggestion: Switch to Weekdays',
    'You miss weekends consistently. 60% → 85% predicted completion.',
    'Switch to weekdays',
    'Keep daily',
    _Badge.adapt,
  ),
  _Suggestion(
    'Exercise',
    'Current: Weekdays · Completion: 96%',
    'Suggestion: Switch to Saturdays',
    '96% streak for 3 weeks — you\'re ready to extend.',
    'Add Saturday',
    'Keep as is',
    _Badge.stretch,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SmartRecurrenceScreen extends StatelessWidget {
  const SmartRecurrenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
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
                    Text('Smart recurrence', style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('Adapts to your completion patterns', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // AI banner
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0x120A84FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
            ),
            child: Text(
              '✦ AI watches your completion rates and suggests smarter frequencies — never nags, always adapts.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc2, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          // FREQUENCY SUGGESTIONS
          Text('FREQUENCY SUGGESTIONS', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
          const SizedBox(height: 8),

          for (final s in _suggestions) ...[
            _SuggestionCard(s: s, colors: colors),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),

          // ALL RECURRING
          Row(
            children: [
              Text('ALL RECURRING', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              const SizedBox(width: 6),
              Text('· ${_recurTasks.length} TASKS', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
            ],
          ),
          const SizedBox(height: 6),

          for (final t in _recurTasks) ...[
            _RecurRow(task: t, colors: colors),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

// ── Suggestion card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final _Suggestion s;
  final KaalColors colors;
  const _SuggestionCard({required this.s, required this.colors});

  @override
  Widget build(BuildContext context) {
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
              Expanded(child: Text(s.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: s.badge.color))),
              _BadgePill(badge: s.badge),
            ],
          ),
          const SizedBox(height: 4),
          Text(s.current, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          Text(s.pctLabel, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: KaalColors.acc2)),
          const SizedBox(height: 6),
          Text(s.body, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink2, height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: KaalColors.accBg, borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: const Color(0x660A84FF))),
                    alignment: Alignment.center,
                    child: Text(s.action, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: colors.bdr)),
                    alignment: Alignment.center,
                    child: Text(s.keep, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
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

// ── Recurring task row ────────────────────────────────────────────────────────

class _RecurRow extends StatelessWidget {
  final _RecurTask task;
  final KaalColors colors;
  const _RecurRow({required this.task, required this.colors});

  @override
  Widget build(BuildContext context) {
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
                Text(task.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: task.badge.color)),
                Row(
                  children: [
                    Text(task.current, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    if (task.pct.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Text('· ${task.pct}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    ],
                    if (task.streakLabel.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Text('· ${task.streakLabel}', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.successFg)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _BadgePill(badge: task.badge),
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
      child: Text(badge.label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: badge.color)),
    );
  }
}
