import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _PresetData {
  final String name, sub;
  final Color quadColor;
  final List<Task> matches;
  const _PresetData(this.name, this.sub, this.quadColor, this.matches);
}

Color _qColor(int q) => switch (q) {
      1 => TaskEraColors.q1,
      2 => TaskEraColors.q2,
      3 => TaskEraColors.q3,
      4 => TaskEraColors.q4,
      _ => TaskEraColors.acc2,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class FiltersScreen extends ConsumerStatefulWidget {
  const FiltersScreen({super.key});

  @override
  ConsumerState<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends ConsumerState<FiltersScreen> {
  int? _selected; // index of the active preset whose results are shown

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final tasks = ref.watch(allTasksProvider).value ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isToday(DateTime? d) =>
        d != null && d.year == today.year && d.month == today.month && d.day == today.day;
    bool isOverdue(DateTime? d) =>
        d != null && DateTime(d.year, d.month, d.day).isBefore(today);

    final presets = <_PresetData>[
      _PresetData('Overdue tasks', 'Past due · All quads', TaskEraColors.q1,
          tasks.where((t) => !t.isDone && isOverdue(t.dueDate)).toList()),
      _PresetData('High score Q2', 'Q2 · Score > 7', TaskEraColors.q2,
          tasks.where((t) => !t.isDone && t.quadrant == 2 && (t.urgencyScore ?? 0) > 7).toList()),
      _PresetData('Today\'s Q2 focus', 'Q2 · Due today', TaskEraColors.q2,
          tasks.where((t) => !t.isDone && t.quadrant == 2 && isToday(t.dueDate)).toList()),
    ];

    // Keep selection in range as data changes.
    final sel = (_selected != null && _selected! < presets.length) ? _selected : null;
    final results = sel != null ? presets[sel].matches : null;

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
                    Text('Filters',
                        style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink,
                            height: 1.1)),
                    Text('Custom task views',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
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
                // PRESETS
                Text('PRESETS',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.ink3)),
                const SizedBox(height: 6),
                for (int i = 0; i < presets.length; i++) ...[
                  _PresetRow(
                    preset: presets[i],
                    colors: colors,
                    active: sel == i,
                    onTap: () => setState(() => _selected = sel == i ? null : i),
                  ),
                  const SizedBox(height: 4),
                ],

                // RESULTS for the selected preset
                if (sel != null) ...[
                  const SizedBox(height: 8),
                  Text('${presets[sel].name.toUpperCase()} · ${results!.length}',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: presets[sel].quadColor)),
                  const SizedBox(height: 6),
                  if (results.isEmpty)
                    Text('No tasks match this filter right now.',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12, color: colors.ink3))
                  else
                    for (final t in results) ...[
                      _ResultRow(task: t, colors: colors),
                      const SizedBox(height: 4),
                    ],
                ],

                const SizedBox(height: 16),

                // BUILD A FILTER
                Text('BUILD A FILTER',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: colors.ink3)),
                const SizedBox(height: 6),

                _ConditionRow(
                    prefix: 'When', field: 'Quadrant', op: 'is', value: 'Q2', colors: colors),
                const SizedBox(height: 4),
                _ConditionRow(
                    prefix: 'And', field: 'Score', op: '≥', value: '7.0', colors: colors),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () => _snack('Custom conditions coming soon'),
                  child: const Text('+ Add condition',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: TaskEraColors.acc)),
                ),
                const SizedBox(height: 12),

                // Run + Focus — both run the built filter (Q2 · Score ≥ 7 = preset 1)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                              color: TaskEraColors.acc, borderRadius: BorderRadius.circular(9)),
                          alignment: Alignment.center,
                          child: const Text('Run',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(width: 0.5, color: TaskEraColors.acc),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Focus',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TaskEraColors.acc2)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => _snack('Saved filters coming soon'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    alignment: Alignment.center,
                    child: const Text('+ Save as Filter',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: TaskEraColors.acc)),
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

// ── Preset row ────────────────────────────────────────────────────────────────

class _PresetRow extends StatelessWidget {
  final _PresetData preset;
  final TaskEraColors colors;
  final bool active;
  final VoidCallback onTap;
  const _PresetRow({
    required this.preset,
    required this.colors,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = preset.matches.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: active ? TaskEraColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 0.5, color: active ? const Color(0x660A84FF) : colors.bdr),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preset.name,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: preset.quadColor)),
                  Text(preset.sub,
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration:
                  const BoxDecoration(color: TaskEraColors.accBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('$count',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: TaskEraColors.acc2)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              decoration: BoxDecoration(
                  color: TaskEraColors.acc, borderRadius: BorderRadius.circular(6)),
              child: Text(active ? 'Hide' : 'View',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result row ────────────────────────────────────────────────────────────────

class _ResultRow extends StatelessWidget {
  final Task task;
  final TaskEraColors colors;
  const _ResultRow({required this.task, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = _qColor(task.quadrant);
    final meta = task.dueLabel ??
        (task.urgencyScore != null
            ? 'Q${task.quadrant} · Score ${task.urgencyScore!.toStringAsFixed(1)}'
            : 'Q${task.quadrant}');
    return GestureDetector(
      onTap: () => context.push('/tasks/taskdetail/${task.id}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border(left: BorderSide(width: 3, color: c)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  Text(meta,
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: colors.ink3),
          ],
        ),
      ),
    );
  }
}

// ── Condition row ─────────────────────────────────────────────────────────────

class _ConditionRow extends StatelessWidget {
  final String prefix, field, op, value;
  final TaskEraColors colors;
  const _ConditionRow(
      {required this.prefix,
      required this.field,
      required this.op,
      required this.value,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(prefix,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.ink3)),
          ),
          const SizedBox(width: 8),
          _Pill(label: field, colors: colors),
          const SizedBox(width: 6),
          Text(op, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          const SizedBox(width: 6),
          _Pill(label: value, colors: colors, active: true),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final TaskEraColors colors;
  final bool active;
  const _Pill({required this.label, required this.colors, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: active ? TaskEraColors.accBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            width: 0.5, color: active ? const Color(0x660A84FF) : colors.bdr),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? TaskEraColors.acc2 : colors.ink2)),
    );
  }
}
