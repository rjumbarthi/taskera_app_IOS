import 'package:flutter/material.dart';

import '../data/database.dart' show Task, Habit;
import '../theme/kaal_colors.dart';
import '../l10n/app_l10n.dart';

/// Opens a bottom-sheet to pick which [tasks] are linked.
/// Calls [onSave] with the final selected task-id set when the user taps Save.
void showTaskLinkPicker({
  required BuildContext context,
  required List<Task> tasks,
  required Set<int> initial,
  required KaalColors colors,
  required void Function(Set<int> selected) onSave,
  String? title,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    isScrollControlled: true,
    builder: (_) => _TaskPickerSheet(
      tasks: tasks,
      initial: initial,
      colors: colors,
      onSave: onSave,
      title: title,
    ),
  );
}

/// Opens a bottom-sheet to pick which [habits] are linked.
/// Calls [onSave] with the final selected habit-id set when the user taps Save.
void showHabitLinkPicker({
  required BuildContext context,
  required List<Habit> habits,
  required Set<int> initial,
  required KaalColors colors,
  required void Function(Set<int> selected) onSave,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    isScrollControlled: true,
    builder: (_) => _HabitPickerSheet(
      habits: habits,
      initial: initial,
      colors: colors,
      onSave: onSave,
    ),
  );
}

// ── Shared sheet chrome ────────────────────────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback onSave;
  final KaalColors colors;
  const _SheetScaffold({
    required this.title,
    required this.body,
    required this.onSave,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final safeBot = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + safeBot),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(width: 0.5, color: Color(0x33FFFFFF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2)),
          ),
          Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
          const SizedBox(height: 12),
          ConstrainedBox(constraints: const BoxConstraints(maxHeight: 320), child: body),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Text(AppL10n.of(context).save, style: const TextStyle(fontFamily: 'Inter',
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _checkbox(bool on) => Container(
      width: 16, height: 16,
      decoration: BoxDecoration(
        color: on ? KaalColors.acc : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: on ? null : Border.all(width: 1.5, color: const Color(0x40FFFFFF)),
      ),
      alignment: Alignment.center,
      child: on ? const Icon(Icons.check_rounded, size: 10, color: Colors.white) : null,
    );

// ── Task picker ────────────────────────────────────────────────────────────────

class _TaskPickerSheet extends StatefulWidget {
  final List<Task> tasks;
  final Set<int> initial;
  final KaalColors colors;
  final void Function(Set<int>) onSave;
  final String? title;
  const _TaskPickerSheet({
    required this.tasks,
    required this.initial,
    required this.colors,
    required this.onSave,
    this.title,
  });

  @override
  State<_TaskPickerSheet> createState() => _TaskPickerSheetState();
}

class _TaskPickerSheetState extends State<_TaskPickerSheet> {
  late final Set<int> _pending = Set.from(widget.initial);

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return _SheetScaffold(
      title: widget.title ?? AppL10n.of(context).linkTasksToGoal,
      colors: colors,
      onSave: () {
        widget.onSave(_pending);
        Navigator.pop(context);
      },
      body: widget.tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(AppL10n.of(context).noActiveTasksFound,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
            )
          : ListView(
              shrinkWrap: true,
              children: widget.tasks.map((t) {
                final on = _pending.contains(t.id);
                return GestureDetector(
                  onTap: () => setState(() => on ? _pending.remove(t.id) : _pending.add(t.id)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr0))),
                    child: Row(children: [
                      _checkbox(on),
                      const SizedBox(width: 10),
                      Expanded(child: Text(t.title,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1))),
                      Text('Q${t.quadrant}',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
                    ]),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ── Habit picker ───────────────────────────────────────────────────────────────

class _HabitPickerSheet extends StatefulWidget {
  final List<Habit> habits;
  final Set<int> initial;
  final KaalColors colors;
  final void Function(Set<int>) onSave;
  const _HabitPickerSheet({
    required this.habits,
    required this.initial,
    required this.colors,
    required this.onSave,
  });

  @override
  State<_HabitPickerSheet> createState() => _HabitPickerSheetState();
}

class _HabitPickerSheetState extends State<_HabitPickerSheet> {
  late final Set<int> _pending = Set.from(widget.initial);

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return _SheetScaffold(
      title: AppL10n.of(context).linkHabitsToGoal,
      colors: colors,
      onSave: () {
        widget.onSave(_pending);
        Navigator.pop(context);
      },
      body: widget.habits.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(AppL10n.of(context).noHabitsFound,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
            )
          : ListView(
              shrinkWrap: true,
              children: widget.habits.map((h) {
                final on = _pending.contains(h.id);
                return GestureDetector(
                  onTap: () => setState(() => on ? _pending.remove(h.id) : _pending.add(h.id)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr0))),
                    child: Row(children: [
                      _checkbox(on),
                      const SizedBox(width: 10),
                      Text(h.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(h.name,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1))),
                      Text(h.frequencyLabel,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
                    ]),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
