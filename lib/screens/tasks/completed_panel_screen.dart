import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// Quadrant → (group label, accent color). Order controls section order.
const _quadOrder = [1, 2, 3, 4, 0];
const _quadLabels = {
  1: 'Q1 · DO NOW',
  2: 'Q2 · SCHEDULE',
  3: 'Q3 · DELEGATE',
  4: 'Q4 · ELIMINATE',
  0: 'BACKLOG',
};

Color _qColor(int q) => switch (q) {
      1 => KaalColors.q1,
      2 => KaalColors.q2,
      3 => KaalColors.q3,
      4 => KaalColors.q4,
      _ => KaalColors.acc2,
    };

String _whenLabel(DateTime? d) {
  if (d == null) return 'Done';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dd = DateTime(d.year, d.month, d.day);
  final diff = today.difference(dd).inDays;
  if (diff <= 0) return 'Done today';
  if (diff == 1) return 'Done yesterday';
  if (diff < 7) return 'Done ${diff}d ago';
  if (diff < 14) return 'Done last week';
  return 'Done ${(diff / 7).floor()}w ago';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CompletedPanelScreen extends ConsumerStatefulWidget {
  const CompletedPanelScreen({super.key});

  @override
  ConsumerState<CompletedPanelScreen> createState() => _CompletedPanelScreenState();
}

class _CompletedPanelScreenState extends ConsumerState<CompletedPanelScreen> {
  bool _confirmClear = false;

  Future<void> _restore(int id) =>
      ref.read(appDatabaseProvider).tasksDao.toggleDone(id, false);

  Future<void> _clearAll(List<Task> done) async {
    final dao = ref.read(appDatabaseProvider).tasksDao;
    for (final t in done) {
      await dao.deleteTask(t.id);
    }
    if (mounted) setState(() => _confirmClear = false);
  }

  void _export(List<Task> done) {
    final buf = StringBuffer('Completed tasks (${done.length})\n');
    for (final t in done) {
      buf.writeln('• ${t.title}  — ${_whenLabel(t.doneAt)}');
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completed list copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final List<Task> done = [...(ref.watch(doneTasksProvider).value ?? const [])]
      ..sort((a, b) => (b.doneAt ?? DateTime(0)).compareTo(a.doneAt ?? DateTime(0)));

    // Group by quadrant, preserving _quadOrder.
    final byQuad = <int, List<Task>>{};
    for (final t in done) {
      (byQuad[t.quadrant] ??= []).add(t);
    }
    final groups = [
      for (final q in _quadOrder)
        if (byQuad[q] != null) (q, byQuad[q]!),
    ];

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
                    Text('Completed',
                        style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: done.isEmpty
              ? _EmptyState(colors: colors)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${done.length} TASK${done.length == 1 ? '' : 'S'} COMPLETED',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.ink3),
                      ),
                      const SizedBox(height: 10),
                      for (final (q, list) in groups) ...[
                        _GroupLabel(
                            label: _quadLabels[q] ?? 'OTHER',
                            color: _qColor(q),
                            colors: colors),
                        const SizedBox(height: 4),
                        for (final task in list) ...[
                          _CompRow(
                            task: task,
                            color: _qColor(q),
                            colors: colors,
                            onRestore: () => _restore(task.id),
                          ),
                          const SizedBox(height: 4),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
        ),

        // Bottom bar
        if (done.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 0.5, color: colors.bdr))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_confirmClear) {
                      _clearAll(done);
                    } else {
                      setState(() => _confirmClear = true);
                    }
                  },
                  child: Text(
                    _confirmClear ? 'Tap again to confirm' : 'Clear all',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B6B)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _export(done),
                  child: Text('Export',
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final KaalColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 40, color: colors.ink3),
            const SizedBox(height: 10),
            Text('No completed tasks yet',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink2)),
            const SizedBox(height: 4),
            Text('Tasks you complete will be collected here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final Color color;
  final KaalColors colors;
  const _GroupLabel({required this.label, required this.color, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: color)),
      ],
    );
  }
}

class _CompRow extends StatelessWidget {
  final Task task;
  final Color color;
  final KaalColors colors;
  final VoidCallback onRestore;
  const _CompRow({
    required this.task,
    required this.color,
    required this.colors,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
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
            width: 15,
            height: 15,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.withAlpha(0x33),
                border: Border.all(width: 1.5, color: c)),
            child: Center(child: Icon(Icons.check, size: 8, color: c)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: c,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: c.withAlpha(0x80))),
                const SizedBox(height: 1),
                Text(_whenLabel(task.doneAt),
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRestore,
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
                  Text('Restore',
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 9, color: colors.ink3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
