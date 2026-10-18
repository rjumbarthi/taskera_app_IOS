import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reminder.dart';
import '../data/providers/reminders_provider.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_theme.dart';
import 'taskera_sheet.dart';

String fmtReminderWhen(DateTime d) {
  final now = DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = day.difference(today).inDays;
  const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final dayLabel = diff == 0
      ? 'Today'
      : diff == 1
          ? 'Tomorrow'
          : (diff > 1 && diff < 7)
              ? wd[d.weekday - 1]
              : '${wd[d.weekday - 1]}, ${mo[d.month - 1]} ${d.day}';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '$dayLabel · $h:${d.minute.toString().padLeft(2, '0')} $ampm';
}

/// Opens the "New reminder/alarm" sheet and persists the result via
/// [remindersProvider]. Pass [initialLabel] to pre-fill from a task/habit.
void showAddReminderSheet(
  BuildContext context,
  WidgetRef ref, {
  String? initialLabel,
  bool initialAlarm = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB3000000),
    builder: (_) => _AddReminderSheet(
      initialLabel: initialLabel,
      initialAlarm: initialAlarm,
      onSave: (r) => ref.read(remindersProvider.notifier).add(r),
    ),
  );
}

/// Inline "Reminders & Alarms" manager — lives directly on a parent screen
/// (the Calendar tab). Shows the list with delete + an Add button; no subscreen.
class RemindersSection extends ConsumerWidget {
  final TaskEraColors colors;
  const RemindersSection({super.key, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.bdr0,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Text('⏰', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reminders & Alarms',
                          style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                              height: 1.2)),
                      const SizedBox(height: 2),
                      Text(reminders.isEmpty ? 'None set' : '${reminders.length} set',
                          style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => showAddReminderSheet(context, ref),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    child: Text('+ Add',
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.ink2,
                            height: 1)),
                  ),
                ),
              ],
            ),

            if (reminders.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (int i = 0; i < reminders.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, thickness: 0.5, color: colors.bdr),
                _InlineReminderRow(
                  reminder: reminders[i],
                  colors: colors,
                  onDelete: () =>
                      ref.read(remindersProvider.notifier).remove(reminders[i].id),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineReminderRow extends StatelessWidget {
  final Reminder reminder;
  final TaskEraColors colors;
  final VoidCallback onDelete;
  const _InlineReminderRow({
    required this.reminder,
    required this.colors,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final past = reminder.isPast;
    final accent = reminder.isAlarm ? const Color(0xFFFF453A) : TaskEraColors.acc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(reminder.isAlarm ? '⏰' : '🔔', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.label.isEmpty
                      ? (reminder.isAlarm ? 'Alarm' : 'Reminder')
                      : reminder.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: past ? colors.ink3 : colors.ink,
                      height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fmtReminderWhen(reminder.when)}'
                  '${reminder.repeat != ReminderRepeat.none ? ' · ${reminder.repeatLabel}' : ''}'
                  '${past ? ' · passed' : ''}',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily,
                      fontSize: 11,
                      color: past ? colors.ink4 : accent,
                      height: 1.2),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close_rounded, size: 18, color: colors.ink3),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add reminder/alarm sheet ──────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  final ValueChanged<Reminder> onSave;
  final String? initialLabel;
  final bool initialAlarm;
  const _AddReminderSheet({
    required this.onSave,
    this.initialLabel,
    this.initialAlarm = false,
  });

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  late final _ctrl = TextEditingController(text: widget.initialLabel ?? '');
  late DateTime _when = _defaultWhen();
  late bool _isAlarm = widget.initialAlarm;
  ReminderRepeat _repeat = ReminderRepeat.none;

  static DateTime _defaultWhen() {
    final n = DateTime.now().add(const Duration(hours: 1));
    return DateTime(n.year, n.month, n.day, n.hour, 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) {
      setState(() => _when = DateTime(d.year, d.month, d.day, _when.hour, _when.minute));
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_when));
    if (t != null) {
      setState(() => _when = DateTime(_when.year, _when.month, _when.day, t.hour, t.minute));
    }
  }

  void _save() {
    final r = Reminder(
      id: DateTime.now().millisecondsSinceEpoch,
      label: _ctrl.text.trim(),
      whenMs: _when.millisecondsSinceEpoch,
      isAlarm: _isAlarm,
      repeat: _repeat,
    );
    widget.onSave(r);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final safeBot =
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom;
    final valid = !_when.isBefore(DateTime.now());

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: TaskEraSheetSurface(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 16, 18, 16 + safeBot),
            decoration: BoxDecoration(
              color: colors.surf,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: colors.bdr2, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('New reminder',
                    style: TextStyle(
                        fontFamily: TaskEraTheme.of(context).fontFamily,
                        fontVariations: const [FontVariation('wght', 600)],
                        fontSize: 18,
                        color: colors.ink,
                        height: 1.1)),
                const SizedBox(height: 14),

                // Type toggle
                Row(children: [
                  _TypeBtn(
                      label: '🔔 Reminder',
                      selected: !_isAlarm,
                      colors: colors,
                      onTap: () => setState(() => _isAlarm = false)),
                  const SizedBox(width: 8),
                  _TypeBtn(
                      label: '⏰ Alarm',
                      selected: _isAlarm,
                      colors: colors,
                      onTap: () => setState(() => _isAlarm = true)),
                ]),
                const SizedBox(height: 14),

                // Label
                Container(
                  decoration: BoxDecoration(
                      color: colors.surf2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: colors.bdr0)),
                  child: TextField(
                    controller: _ctrl,
                    style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink),
                    decoration: InputDecoration(
                      hintText: _isAlarm ? 'Alarm label (e.g. Wake up)' : 'Reminder (e.g. Call the bank)',
                      hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, color: colors.ink3),
                      contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    cursorColor: TaskEraColors.acc,
                  ),
                ),
                const SizedBox(height: 10),

                // Date + time
                Row(children: [
                  Expanded(
                      child: _PickField(
                          icon: Icons.calendar_today_outlined,
                          label: _dateLabel(_when),
                          colors: colors,
                          onTap: _pickDate)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _PickField(
                          icon: Icons.schedule,
                          label: _timeLabel(_when),
                          colors: colors,
                          onTap: _pickTime)),
                ]),
                const SizedBox(height: 10),

                // Repeat
                Row(children: [
                  for (final rep in ReminderRepeat.values) ...[
                    if (rep != ReminderRepeat.values.first) const SizedBox(width: 8),
                    _TypeBtn(
                      label: switch (rep) {
                        ReminderRepeat.none => 'Once',
                        ReminderRepeat.daily => 'Daily',
                        ReminderRepeat.weekly => 'Weekly',
                      },
                      selected: _repeat == rep,
                      colors: colors,
                      onTap: () => setState(() => _repeat = rep),
                    ),
                  ],
                ]),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: valid ? _save : null,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: valid ? TaskEraColors.acc : colors.surf2,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                        valid ? 'Set ${_isAlarm ? 'alarm' : 'reminder'}' : 'Pick a future time',
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: valid ? Colors.white : colors.ink3,
                            height: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${mo[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _timeLabel(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$h:${d.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _TypeBtn(
      {required this.label, required this.selected, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? TaskEraColors.accBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                width: 0.5, color: selected ? const Color(0x4D0A84FF) : colors.bdr),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontFamily: TaskEraTheme.of(context).fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? TaskEraColors.acc2 : colors.ink3,
                  height: 1)),
        ),
      ),
    );
  }
}

class _PickField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _PickField(
      {required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
            color: colors.surf2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5, color: colors.bdr0)),
        child: Row(children: [
          Icon(icon, size: 15, color: colors.ink3),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink, height: 1))),
        ]),
      ),
    );
  }
}
