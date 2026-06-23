import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _CompTask {
  final String title, when;
  final String quad; // 'q1'|'q2'|'q3'|'q4'
  const _CompTask(this.title, this.when, this.quad);
}

class _CompGroup {
  final String label;
  final Color color;
  final List<_CompTask> tasks;
  const _CompGroup(this.label, this.color, this.tasks);
}

const _groups = [
  _CompGroup('Q2 · SCHEDULE', KaalColors.q2, [
    _CompTask('Morning journaling',          'Done yesterday', 'q2'),
    _CompTask('Weekly review',               'Done yesterday', 'q2'),
    _CompTask('Pay gym membership fees',     'Done 4d ago',    'q2'),
    _CompTask('Study for exam — Chapter 4',  'Done 4d ago',    'q2'),
  ]),
  _CompGroup('Q1 · DO NOW', KaalColors.q1, [
    _CompTask('Fix server migration',        'Done today', 'q1'),
    _CompTask('Emergency client call',       'Done today', 'q1'),
  ]),
  _CompGroup('Q3 · DELEGATE', KaalColors.q3, [
    _CompTask('Reply to group project messages', 'Done today',      'q3'),
    _CompTask('Send thank-you email to coach',   'Done yesterday',  'q3'),
  ]),
];

Color _qColor(String q) => switch (q) {
  'q1' => KaalColors.q1,
  'q2' => KaalColors.q2,
  'q3' => KaalColors.q3,
  _    => KaalColors.q4,
};

// ── Screen ────────────────────────────────────────────────────────────────────

class CompletedPanelScreen extends StatelessWidget {
  const CompletedPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: KaalColors.q2),
                    const SizedBox(width: 6),
                    Text(
                      'Completed',
                      style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '8 TASKS COMPLETED',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3),
                ),
                const SizedBox(height: 10),
                for (final group in _groups) ...[
                  _GroupLabel(group: group, colors: colors),
                  const SizedBox(height: 4),
                  for (final task in group.tasks) ...[
                    _CompRow(task: task, colors: colors),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),

        // Bottom bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: colors.bdr))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text('Clear all', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFFF6B6B))),
              ),
              GestureDetector(
                onTap: () {},
                child: Text('Export', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  final _CompGroup group;
  final KaalColors colors;
  const _GroupLabel({required this.group, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: group.color)),
        const SizedBox(width: 6),
        Text(group.label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: group.color)),
      ],
    );
  }
}

class _CompRow extends StatelessWidget {
  final _CompTask task;
  final KaalColors colors;
  const _CompRow({required this.task, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = _qColor(task.quad);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          // Done circle with checkmark
          Container(
            width: 15, height: 15,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.withAlpha(0x33), border: Border.all(width: 1.5, color: c)),
            child: Center(child: Icon(Icons.check, size: 8, color: c)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: c, decoration: TextDecoration.lineThrough, decorationColor: c.withAlpha(0x80))),
                const SizedBox(height: 1),
                Text(task.when, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: colors.bdr2),
              ),
              child: Row(
                children: [
                  Icon(Icons.restore, size: 10, color: colors.ink3),
                  const SizedBox(width: 3),
                  Text('Restore', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
