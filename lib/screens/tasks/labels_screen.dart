import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

// Stable accent per label name (the editor's palette), with a fallback rotation.
const _labelColors = {
  'work': TaskEraColors.acc2,
  'personal': TaskEraColors.q4,
  'health': TaskEraColors.q2,
  'finance': Color(0xFF9FCD44),
  'learning': TaskEraColors.q3,
};
const _fallbackPalette = [
  TaskEraColors.acc2, TaskEraColors.q2, TaskEraColors.q3, TaskEraColors.q4, Color(0xFF9FCD44),
];

Color _labelColor(String name, int idx) =>
    _labelColors[name] ?? _fallbackPalette[idx % _fallbackPalette.length];

Color _quadColor(int q) => switch (q) {
      1 => TaskEraColors.q1,
      2 => TaskEraColors.q2,
      3 => TaskEraColors.q3,
      _ => TaskEraColors.q4,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final tasks = ref.watch(allTasksProvider).value ?? [];

    // Build label → tasks map from real task label strings.
    final map = <String, List<Task>>{};
    for (final t in tasks) {
      for (final l in (t.labels ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)) {
        (map[l] ??= []).add(t);
      }
    }
    final names = map.keys.toList()..sort();

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
                    Text('Labels',
                        style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink,
                            height: 1.1)),
                    Text(
                        names.isEmpty
                            ? 'No labels yet'
                            : '${names.length} label${names.length == 1 ? '' : 's'} · tap to expand',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: names.isEmpty
              ? _Empty(colors: colors)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: names.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, i) => _LabelRow(
                    name: names[i],
                    color: _labelColor(names[i], i),
                    tasks: map[names[i]]!,
                    colors: colors,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _Empty extends StatelessWidget {
  final TaskEraColors colors;
  const _Empty({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('#', style: TextStyle(fontFamily: 'Fraunces', fontSize: 36, color: colors.ink3)),
            const SizedBox(height: 10),
            Text('No labels yet',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink2)),
            const SizedBox(height: 4),
            Text('Add labels to a task from its editor and they\'ll be grouped here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _LabelRow extends StatefulWidget {
  final String name;
  final Color color;
  final List<Task> tasks;
  final TaskEraColors colors;
  const _LabelRow({
    required this.name,
    required this.color,
    required this.tasks,
    required this.colors,
  });

  @override
  State<_LabelRow> createState() => _LabelRowState();
}

class _LabelRowState extends State<_LabelRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final count = widget.tasks.length;
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
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${widget.name}',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.color)),
                      Text('$count task${count == 1 ? '' : 's'}',
                          style: TextStyle(
                              fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                    ],
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16, color: colors.ink3),
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
              children: widget.tasks
                  .map((t) => _LabelTaskRow(task: t, colors: colors))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _LabelTaskRow extends StatelessWidget {
  final Task task;
  final TaskEraColors colors;
  const _LabelTaskRow({required this.task, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = _quadColor(task.quadrant);
    return GestureDetector(
      onTap: () => context.push('/tasks/taskdetail/${task.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
        ),
        child: Row(
          children: [
            Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: c))),
            const SizedBox(width: 10),
            Expanded(
                child: Text(task.title,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: task.isDone ? colors.ink3 : colors.ink))),
          ],
        ),
      ),
    );
  }
}
