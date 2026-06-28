import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart' show Task, TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Apple-restrained, web-only "Today" surface. Ranked List (default) + 2x2 Grid
// (toggle). The Eisenhower matrix is the engine, not the surface — the List
// never shows Q-labels/scores; the only matrix trace is the colored flag bar.
// System font (no Inter/Fraunces). Dark-first to match the reference design.
// Quadrant + accent colours from kaal_pkg/tokens.json core_colors.
// ─────────────────────────────────────────────────────────────────────────────

class _Tok {
  static const q1 = Color(0xFFF25022); // core_colors.q1 — Do Now (red)
  static const q2 = Color(0xFF7FBA00); // core_colors.q2 — Schedule (green)
  static const q3 = Color(0xFF00A4EF); // core_colors.q3 — Delegate (blue)
  static const q4 = Color(0xFF8E8E93); // Eliminate → muted gray (de-emphasised)
  static const acc = Color(0xFF0A84FF); // core_colors.acc
  static const warn = Color(0xFFFF453A); // overdue red

  static Color quad(int q) => switch (q) {
        1 => q1,
        2 => q2,
        3 => q3,
        _ => q4,
      };
}

class _Palette {
  final bool dark;
  const _Palette(this.dark);

  Color get bg        => dark ? const Color(0xFF0E0E10) : const Color(0xFFFFFFFF);
  Color get card      => dark ? const Color(0xFF1A1A1C) : const Color(0xFFF2F2F7);
  Color get label     => dark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  Color get secondary => dark ? const Color(0xFF8E8E93) : const Color(0xFF6B6B70);
  Color get tertiary  => dark ? const Color(0xFF5A5A60) : const Color(0xFFA0A0A6);
  Color get checkBdr  => dark ? const Color(0xFF48484A) : const Color(0xFFC4C4C8);
  Color get divider   => dark ? const Color(0xFF2A2A2C) : const Color(0xFFE5E5EA);
  Color get hover     => dark ? const Color(0x14FFFFFF) : const Color(0x0A000000);
  Color get tagBg     => dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
}

class TodayWebView extends ConsumerStatefulWidget {
  const TodayWebView({super.key});

  @override
  ConsumerState<TodayWebView> createState() => _TodayWebViewState();
}

class _TodayWebViewState extends ConsumerState<TodayWebView> {
  bool _grid = false;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _overdue(Task t) {
    final d = t.dueDate;
    if (d == null) return false;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  int _section(Task t) {
    final now = DateTime.now();
    final dueToday = t.dueDate != null && _sameDay(t.dueDate!, now);
    if (_overdue(t) || t.quadrant == 1) return 0; // Now
    if (dueToday || t.quadrant == 2) return 1; // Later today
    return 2; // Can wait
  }

  double _rank(Task t) {
    var k = 0.0;
    if (_overdue(t)) k -= 1000;
    k -= (t.urgencyScore ?? 0) * 10;
    k += t.quadrant.toDouble();
    if (t.dueDate != null) k -= 1;
    return k;
  }

  // Quiet meta line for a task row.
  String _meta(Task t) {
    if (_overdue(t)) {
      final d = t.dueDate!;
      final now = DateTime.now();
      final wasToday = d.year == now.year && d.month == now.month;
      return wasToday ? 'Overdue · was due today' : 'Overdue';
    }
    if (t.dueLabel != null && t.dueLabel!.trim().isNotEmpty) return t.dueLabel!;
    final d = t.dueDate;
    final now = DateTime.now();
    if (d != null && _sameDay(d, now) && (d.hour != 0 || d.minute != 0)) {
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final ampm = d.hour < 12 ? 'AM' : 'PM';
      return '$h:${d.minute.toString().padLeft(2, '0')} $ampm';
    }
    if (t.timeAllocatedMin != null && t.timeAllocatedMin! > 0) {
      return 'Focus block · ${t.timeAllocatedMin} min';
    }
    return switch (t.quadrant) {
      3 => 'No rush',
      4 => 'Someday',
      _ => 'Anytime',
    };
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness != Brightness.light;
    final p = _Palette(dark);

    final activeId = ref.watch(timeTrackerProvider.select((s) => s.taskId));
    final all = (ref.watch(allTasksProvider).value ?? const <Task>[])
        .where((t) => !t.isDone && t.id != activeId)
        .toList();

    return Container(
      color: p.bg,
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(40, 30, 36, 56),
            children: [
              _header(p, all),
              const SizedBox(height: 22),
              if (_grid) _gridView(p, all) else _listView(p, all),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _header(_Palette p, List<Task> all) {
    final now = DateTime.now();
    const wd = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const mo = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December'];
    final eyebrow = '${wd[now.weekday - 1]}, ${mo[now.month]} ${now.day}';

    final nowItems = all.where((t) => _section(t) == 0).toList();
    final overdue = all.where(_overdue).toList();

    // Plain-language glance with one bold task reference.
    final glance = <InlineSpan>[];
    final baseStyle = TextStyle(fontSize: 15.5, color: p.secondary, height: 1.45);
    if (all.isEmpty) {
      glance.add(const TextSpan(text: 'Nothing on your plate — a clear day.'));
    } else if (overdue.isNotEmpty) {
      final n = nowItems.length;
      glance.addAll([
        TextSpan(text: '$n thing${n == 1 ? '' : 's'} need${n == 1 ? 's' : ''} you now. '),
        TextSpan(text: overdue.first.title, style: TextStyle(color: p.label, fontWeight: FontWeight.w600)),
        const TextSpan(text: ' is overdue — start there.'),
      ]);
    } else if (nowItems.isNotEmpty) {
      glance.add(TextSpan(text: '${nowItems.length} to tackle now, then the rest can wait.'));
    } else {
      glance.add(const TextSpan(text: 'Nothing urgent — work at your own pace today.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: TextStyle(fontSize: 14, color: p.secondary, height: 1)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: p.label, height: 1.05)),
                    const SizedBox(height: 10),
                    RichText(text: TextSpan(style: baseStyle, children: glance)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            _SegToggle(grid: _grid, palette: p, onChanged: (g) => setState(() => _grid = g)),
          ],
        ),
      ],
    );
  }

  // ── List view ──────────────────────────────────────────────────────────────
  Widget _listView(_Palette p, List<Task> all) {
    final sorted = [...all]..sort((a, b) {
        final s = _section(a).compareTo(_section(b));
        return s != 0 ? s : _rank(a).compareTo(_rank(b));
      });
    final buckets = <int, List<Task>>{0: [], 1: [], 2: []};
    for (final t in sorted) {
      buckets[_section(t)]!.add(t);
    }
    final movedUp = all.where(_overdue).length;

    const labels = ['Now', 'Later today', 'Can wait'];
    const suffixes = ['', '', ' · handle later or drop'];

    final kids = <Widget>[];
    if (movedUp > 0) {
      kids
        ..add(_aiCard(p, movedUp))
        ..add(const SizedBox(height: 26));
    }
    if (all.isEmpty) {
      kids.add(_empty(p));
    }
    for (var s = 0; s < 3; s++) {
      final items = buckets[s]!;
      if (items.isEmpty) continue;
      kids.add(Opacity(
        opacity: s == 2 ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 0, 10),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: labels[s],
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: p.secondary)),
                  TextSpan(text: suffixes[s],
                      style: TextStyle(fontSize: 13.5, color: p.tertiary)),
                ]),
              ),
            ),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Divider(height: 0.5, thickness: 0.5, color: p.divider),
                ),
              _TaskRow(task: items[i], palette: p, ref: ref, meta: _meta(items[i])),
            ],
          ],
        ),
      ));
      kids.add(const SizedBox(height: 30));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kids);
  }

  Widget _aiCard(_Palette p, int n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0x330A84FF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('✦', style: TextStyle(fontSize: 16, color: _Tok.acc)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.5, color: p.secondary, height: 1.4),
                children: [
                  const TextSpan(text: 'I moved '),
                  TextSpan(text: '$n task${n == 1 ? '' : 's'}',
                      style: TextStyle(color: p.label, fontWeight: FontWeight.w600)),
                  TextSpan(text: ' up — ${n == 1 ? "it's" : "they're"} due sooner than ${n == 1 ? 'it' : 'they'} looked.'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right, size: 20, color: p.tertiary),
        ],
      ),
    );
  }

  Widget _empty(_Palette p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text('✦', style: TextStyle(fontSize: 30, color: p.tertiary)),
          const SizedBox(height: 12),
          Text('All clear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: p.label)),
          const SizedBox(height: 4),
          Text('No open tasks for today.', style: TextStyle(fontSize: 14, color: p.secondary)),
        ],
      ),
    );
  }

  // ── Grid view ──────────────────────────────────────────────────────────────
  Widget _gridView(_Palette p, List<Task> all) {
    final byQuad = <int, List<Task>>{1: [], 2: [], 3: [], 4: []};
    for (final t in all) {
      final q = (t.quadrant >= 1 && t.quadrant <= 4) ? t.quadrant : 4;
      byQuad[q]!.add(t);
    }
    const meta = {
      1: ('Do Now', 'Urgent & important'),
      2: ('Schedule', 'Important, not urgent'),
      3: ('Delegate', 'Urgent, not important'),
      4: ('Eliminate', 'Neither'),
    };
    Widget cell(int q) => _QuadCell(
          quadrant: q,
          title: meta[q]!.$1,
          subtitle: meta[q]!.$2,
          tasks: byQuad[q]!,
          palette: p,
          metaOf: _meta,
          onDropTask: (id) => ref
              .read(appDatabaseProvider)
              .tasksDao
              .updateTask(id, TasksCompanion(quadrant: Value(q))),
        );
    return Column(children: [
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: cell(1)),
        const SizedBox(width: 16),
        Expanded(child: cell(2)),
      ])),
      const SizedBox(height: 16),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: cell(3)),
        const SizedBox(width: 16),
        Expanded(child: cell(4)),
      ])),
    ]);
  }
}

// ── Segmented List / Grid toggle ──────────────────────────────────────────────

class _SegToggle extends StatelessWidget {
  final bool grid;
  final _Palette palette;
  final ValueChanged<bool> onChanged;
  const _SegToggle({required this.grid, required this.palette, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    Widget seg(String label, IconData icon, bool isGrid) {
      final active = grid == isGrid;
      return GestureDetector(
        onTap: () => onChanged(isGrid),
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? (p.dark ? const Color(0xFF3A3A3C) : Colors.white) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 15, color: active ? p.label : p.secondary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: active ? p.label : p.secondary)),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.dark ? const Color(0xFF1C1C1E) : const Color(0xFFE9E9EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('List', Icons.density_medium_rounded, false),
        seg('Grid', Icons.grid_view_rounded, true),
      ]),
    );
  }
}

// ── Task row (flat, divider-separated) ────────────────────────────────────────

class _TaskRow extends StatefulWidget {
  final Task task;
  final _Palette palette;
  final WidgetRef ref;
  final String meta;
  const _TaskRow({required this.task, required this.palette, required this.ref, required this.meta});

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _hover = false;

  bool get _overdue {
    final d = widget.task.dueDate;
    if (d == null) return false;
    final now = DateTime.now();
    return DateTime(d.year, d.month, d.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get _isHabit => (widget.task.recurrenceLabel ?? '').isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final t = widget.task;
    final flag = _Tok.quad(t.quadrant);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // Tapping a task starts a focus session (shown in the global pill).
        onTap: () => widget.ref
            .read(timeTrackerProvider.notifier)
            .startNew(t.title, taskId: t.id, quadrant: t.quadrant),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _hover ? p.hover : Colors.transparent,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 3px flag — the only Eisenhower trace
                Container(width: 3, color: flag),
                const SizedBox(width: 17),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: GestureDetector(
                    onTap: () => widget.ref
                        .read(appDatabaseProvider)
                        .tasksDao
                        .toggleDone(t.id, true),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 21, height: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.6, color: p.checkBdr),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: p.label, height: 1.25)),
                        const SizedBox(height: 3),
                        Row(children: [
                          Text(widget.meta,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _overdue ? FontWeight.w600 : FontWeight.w400,
                                  color: _overdue ? _Tok.warn : p.secondary,
                                  height: 1.1)),
                          if (_isHabit) ...[
                            const SizedBox(width: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: p.tagBg, borderRadius: BorderRadius.circular(5)),
                              child: Text('Habit',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: p.secondary, height: 1)),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quadrant cell (grid) ──────────────────────────────────────────────────────

class _QuadCell extends StatefulWidget {
  final int quadrant;
  final String title, subtitle;
  final List<Task> tasks;
  final _Palette palette;
  final String Function(Task) metaOf;
  final void Function(int taskId) onDropTask;
  const _QuadCell({
    required this.quadrant,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.palette,
    required this.metaOf,
    required this.onDropTask,
  });

  @override
  State<_QuadCell> createState() => _QuadCellState();
}

class _QuadCellState extends State<_QuadCell> {
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final color = _Tok.quad(widget.quadrant);
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) {
        setState(() => _over = true);
        return true;
      },
      onLeave: (_) => setState(() => _over = false),
      onAcceptWithDetails: (d) {
        setState(() => _over = false);
        widget.onDropTask(d.data);
      },
      builder: (context, cand, rej) => AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        decoration: BoxDecoration(
          color: _over ? color.withValues(alpha: 0.12) : p.card,
          borderRadius: BorderRadius.circular(16),
          border: _over ? Border.all(width: 1, color: color) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 9),
              Text(widget.title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.label)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: p.secondary)),
              ),
              Text('${widget.tasks.length}',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: p.tertiary)),
            ]),
            const SizedBox(height: 12),
            for (final t in widget.tasks) _DraggableChip(task: t, color: color, palette: p, meta: widget.metaOf(t)),
            if (widget.tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Drop a task here', style: TextStyle(fontSize: 12, color: p.tertiary)),
              ),
          ],
        ),
      ),
    );
  }
}

class _DraggableChip extends StatelessWidget {
  final Task task;
  final Color color;
  final _Palette palette;
  final String meta;
  const _DraggableChip({required this.task, required this.color, required this.palette, required this.meta});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final chip = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: p.dark ? const Color(0xFF101012) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 19, height: 19,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: p.checkBdr)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, color: p.label, height: 1.2)),
            const SizedBox(height: 1),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: p.secondary, height: 1.1)),
          ]),
        ),
      ]),
    );
    return Draggable<int>(
      data: task.id,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.95, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 280), child: chip)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip),
    );
  }
}
