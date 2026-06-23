import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _LabelTask {
  final String title;
  final Color quadColor;
  const _LabelTask(this.title, this.quadColor);
}

class _Label {
  final String name;
  final Color color;
  final List<_LabelTask> tasks;
  const _Label(this.name, this.color, this.tasks);
  int get count => tasks.length;
}

const _labels = [
  _Label('work', KaalColors.acc2, [
    _LabelTask('Fix production bug #482',         KaalColors.q1),
    _LabelTask('Q1 performance review prep',      KaalColors.q2),
    _LabelTask('Team standup prep',               KaalColors.q2),
    _LabelTask('Forward meeting notes to team',   KaalColors.q3),
    _LabelTask('Reply to group project messages', KaalColors.q3),
    _LabelTask('Book hotel for conference',       KaalColors.q3),
    _LabelTask('Clean desktop folders',           KaalColors.q4),
  ]),
  _Label('personal', KaalColors.q4, [
    _LabelTask('Renew passport — expires Friday', KaalColors.q1),
    _LabelTask('Hospital prescription refill',    KaalColors.q1),
    _LabelTask('Annual health checkup',           KaalColors.q2),
    _LabelTask('Organize old photos',             KaalColors.q4),
  ]),
  _Label('health', KaalColors.q2, [
    _LabelTask('Hospital prescription refill',    KaalColors.q1),
    _LabelTask('Annual health checkup',           KaalColors.q2),
    _LabelTask('Morning journaling',              KaalColors.q2),
    _LabelTask('Confirm dentist appointment',     KaalColors.q3),
    _LabelTask('Update playlist',                 KaalColors.q4),
  ]),
  _Label('finance', Color(0xFF9FCD44), [
    _LabelTask('Submit tax return',               KaalColors.q1),
    _LabelTask('Review investment portfolio',     KaalColors.q2),
    _LabelTask('Pay gym membership fees',         KaalColors.q2),
  ]),
  _Label('learning', KaalColors.q3, [
    _LabelTask('Write blog post on focus',        KaalColors.q2),
    _LabelTask('Learn new framework (2hr)',        KaalColors.q2),
  ]),
  _Label('deep-work', KaalColors.acc, [
    _LabelTask('Submit assignment before deadline', KaalColors.q1),
    _LabelTask('Study for exam — Chapter 4',        KaalColors.q2),
    _LabelTask('Product Roadmap Review',            KaalColors.q2),
    _LabelTask('Write blog post on focus',          KaalColors.q2),
  ]),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class LabelsScreen extends StatelessWidget {
  const LabelsScreen({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Labels', style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('${_labels.length} labels · tap to filter', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
            itemCount: _labels.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              if (i == _labels.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 0.5, color: colors.bdr),
                      ),
                      alignment: Alignment.center,
                      child: const Text('+ New Label', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: KaalColors.acc)),
                    ),
                  ),
                );
              }
              final lbl = _labels[i];
              return _LabelRow(label: lbl, colors: colors);
            },
          ),
        ),
      ],
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _LabelRow extends StatefulWidget {
  final _Label label;
  final KaalColors colors;
  const _LabelRow({required this.label, required this.colors});

  @override
  State<_LabelRow> createState() => _LabelRowState();
}

class _LabelRowState extends State<_LabelRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lbl = widget.label;
    final colors = widget.colors;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: _expanded
                  ? const BorderRadius.vertical(top: Radius.circular(10))
                  : BorderRadius.circular(10),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: lbl.color)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${lbl.name}', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: lbl.color)),
                      Text('${lbl.count} tasks', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    ],
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 16, color: colors.ink3),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              border: Border(
                left: BorderSide(width: 0.5, color: colors.bdr),
                right: BorderSide(width: 0.5, color: colors.bdr),
                bottom: BorderSide(width: 0.5, color: colors.bdr),
              ),
            ),
            child: Column(
              children: lbl.tasks.map((t) => _LabelTaskRow(task: t, colors: colors)).toList(),
            ),
          ),
      ],
    );
  }
}

class _LabelTaskRow extends StatelessWidget {
  final _LabelTask task;
  final KaalColors colors;
  const _LabelTaskRow({required this.task, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
      ),
      child: Row(
        children: [
          Container(width: 13, height: 13, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: task.quadColor))),
          const SizedBox(width: 10),
          Expanded(child: Text(task.title, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: task.quadColor))),
        ],
      ),
    );
  }
}
