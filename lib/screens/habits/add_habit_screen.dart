import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart';
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/reminders_section.dart';
import '../../services/activity_log_service.dart';

class _Suggestion {
  final String emoji, name;
  final int accent;
  const _Suggestion(this.emoji, this.name, this.accent);
}

// Editable draft of a sub-habit (routine step). [id] is null for steps added
// in this session that don't yet exist in the DB.
class _StepDraft {
  final int? id;
  String title;
  bool isDone;
  _StepDraft({this.id, required this.title, this.isDone = false});
}

const _kSuggestions = [
  _Suggestion('🌅', 'Morning Routine', 0xFF0A84FF),
  _Suggestion('💪', 'Exercise',        0xFF34C759),
  _Suggestion('🧘', 'Meditation',      0xFFBF5AF2),
  _Suggestion('📚', 'Reading',         0xFFFF9F0A),
  _Suggestion('💧', 'Hydration',       0xFF5AC8FA),
  _Suggestion('😴', 'Early Sleep',     0xFF5856D6),
  _Suggestion('✍️', 'Journaling',      0xFFFFCC00),
  _Suggestion('📵', 'No Phone',        0xFFFF453A),
  _Suggestion('🙏', 'Gratitude',       0xFFFF2D55),
  _Suggestion('🚶', 'Walk',            0xFF30D158),
  _Suggestion('🚿', 'Cold Shower',     0xFF64D2FF),
  _Suggestion('🎯', 'Deep Work',       0xFF636366),
];

class AddHabitScreen extends ConsumerStatefulWidget {
  final String? habitId;
  const AddHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameCtrl  = TextEditingController();
  final _whenCtrl  = TextEditingController();
  final _whereCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _stepCtrl  = TextEditingController();

  // Routine steps (sub-habits) being edited in this screen.
  final List<_StepDraft> _steps = [];

  bool get _isEdit => widget.habitId != null && widget.habitId!.isNotEmpty;

  String _icon = '🏃';
  bool _showIconPicker = false;
  int  _colorIdx   = 0;
  int  _freqIdx    = 0;
  bool _reminderOn = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 6, minute: 30);
  bool _isLoading  = false;

  // Cached values from DB (needed when updating to keep unchanged fields)
  String _existingStreakLabel    = '0 days';
  int    _existingStreakColor    = 0xFF8E8E93;
  int    _existingWeeklyFilled   = 0;

  static const _icons = ['🏃','💧','📚','🧘','💪','✍️','🎯','🍎','😴','☕','🎵','🌿','🧠','💊','🚴','🌅'];
  static const _habitColors = [
    Color(0xFF7FBA00), Color(0xFFFF8080), Color(0xFF0A84FF),
    Color(0xFFBF5AF2), Color(0xFFFFB900), Color(0xFFFF6B00),
  ];
  static const _freqChips  = ['Daily','Weekdays','Weekends','Mon · Wed · Fri','Tue · Thu · Sat','Weekly','Custom'];
  static const _labelChips = ['#gym','#fitness','#work','#personal','#mindset'];
  final Set<int> _selLabels = {0};

  int _closestColorIdx(int accentArgb) {
    int best = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < _habitColors.length; i++) {
      final ca = _habitColors[i].toARGB32();
      final dr = ((ca >> 16 & 0xFF) - (accentArgb >> 16 & 0xFF)).toDouble();
      final dg = ((ca >>  8 & 0xFF) - (accentArgb >>  8 & 0xFF)).toDouble();
      final db = ((ca       & 0xFF) - (accentArgb       & 0xFF)).toDouble();
      final dist = dr * dr + dg * dg + db * db;
      if (dist < bestDist) { bestDist = dist; best = i; }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadHabit());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _whenCtrl.dispose(); _whereCtrl.dispose(); _notesCtrl.dispose();
    _stepCtrl.dispose();
    super.dispose();
  }

  void _addStep() {
    final t = _stepCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _steps.add(_StepDraft(title: t));
      _stepCtrl.clear();
    });
  }

  Future<void> _loadHabit() async {
    final id = int.tryParse(widget.habitId!);
    if (id == null) return;
    final dao   = ref.read(appDatabaseProvider).habitsDao;
    final habit = await dao.getHabit(id);
    if (habit == null || !mounted) return;
    final subs = await dao.getSubHabits(id);
    final ci = _habitColors.indexWhere((c) => c.toARGB32() == habit.accentColorValue);
    final fi = _freqChips.indexWhere((f) => habit.frequencyLabel.startsWith(f));
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = habit.name;
      _notesCtrl.text = habit.notes ?? '';
      _icon  = habit.emoji;
      if (ci >= 0) _colorIdx = ci;
      if (fi >= 0) _freqIdx  = fi;
      _existingStreakLabel  = habit.streakLabel;
      _existingStreakColor  = habit.streakColorValue;
      _existingWeeklyFilled = habit.weeklyFilledCount;
      if (habit.scheduledTime != null) {
        _reminderOn   = true;
        _reminderTime = TimeOfDay(hour: habit.scheduledTime! ~/ 60, minute: habit.scheduledTime! % 60);
      } else {
        _reminderOn = false;
      }
      _steps
        ..clear()
        ..addAll(subs.map((s) => _StepDraft(id: s.id, title: s.title, isDone: s.isDone)));
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final dao = ref.read(appDatabaseProvider).habitsDao;
      final schedMin = _reminderOn ? _reminderTime.hour * 60 + _reminderTime.minute : null;
      if (_isEdit) {
        final id = int.parse(widget.habitId!);
        await dao.updateHabit(id, HabitsCompanion(
          emoji: Value(_icon),
          name:  Value(name),
          frequencyLabel: Value(_freqChips[_freqIdx]),
          scheduledTime: Value(schedMin),
          accentColorValue: Value(_habitColors[_colorIdx].toARGB32()),
          streakLabel: Value(_existingStreakLabel),
          streakColorValue: Value(_existingStreakColor),
          weeklyFilledCount: Value(_existingWeeklyFilled),
          notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        ));
        await _syncSteps(dao, id);
        ref.logActivity('Habit "$name" updated', type: 'habit');
      } else {
        final id = await dao.insertHabit(HabitsCompanion(
          emoji: Value(_icon),
          name:  Value(name),
          frequencyLabel: Value(_freqChips[_freqIdx]),
          scheduledTime: Value(schedMin),
          streakLabel: const Value('0 days'),
          streakColorValue: Value(const Color(0xFF8E8E93).toARGB32()),
          accentColorValue: Value(_habitColors[_colorIdx].toARGB32()),
          weeklyFilledCount: const Value(0),
          notes: Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        ));
        await _syncSteps(dao, id);
        ref.logActivity('Habit "$name" created', type: 'habit');
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Replace the habit's sub-habits with the current draft list, preserving
  // each step's done state. Simple delete-and-reinsert keeps ordering correct.
  Future<void> _syncSteps(HabitsDao dao, int habitId) async {
    await dao.deleteSubHabitsForHabit(habitId);
    for (var i = 0; i < _steps.length; i++) {
      await dao.insertSubHabit(SubHabitsCompanion(
        habitId:   Value(habitId),
        title:     Value(_steps[i].title),
        isDone:    Value(_steps[i].isDone),
        sortOrder: Value(i),
      ));
    }
  }

  Future<void> _delete() async {
    final id = int.tryParse(widget.habitId ?? '');
    if (id == null) return;
    await ref.read(appDatabaseProvider).habitsDao.deleteHabit(id);
    ref.logActivity('Habit "${_nameCtrl.text.trim()}" deleted', type: 'habit');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SubBar(
          title: _isEdit ? 'Edit habit' : 'New habit',
          colors: colors,
          trailing: _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: TaskEraColors.acc)),
                )
              : _SaveBtn(onTap: _save),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Habit name + icon
              _FormRow(
                label: 'Habit name',
                colors: colors,
                child: Row(
                  children: [
                    Expanded(child: _InputField(controller: _nameCtrl, hint: 'e.g. Morning journaling', colors: colors)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showIconPicker = !_showIconPicker),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0x120A84FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1.5, color: TaskEraColors.acc),
                        ),
                        child: Center(child: Text(_icon, style: TextStyle(fontSize: 20, height: 1))),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showIconPicker)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surf2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    child: Wrap(
                      spacing: 4, runSpacing: 4,
                      children: _icons.map((e) => GestureDetector(
                        onTap: () => setState(() { _icon = e; _showIconPicker = false; }),
                        child: Padding(padding: const EdgeInsets.all(4), child: Text(e, style: TextStyle(fontSize: 22, height: 1))),
                      )).toList(),
                    ),
                  ),
                ),
              // Suggestions (new habit only)
              if (!_isEdit)
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('SUGGESTIONS', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4, color: colors.ink3, height: 1)),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 7, runSpacing: 7,
                        children: [
                          for (final s in _kSuggestions)
                            GestureDetector(
                              onTap: () => setState(() {
                                _nameCtrl.text = s.name;
                                _icon = s.emoji;
                                _colorIdx = _closestColorIdx(s.accent);
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Color(s.accent).withAlpha(0x18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(width: 0.5, color: Color(s.accent).withAlpha(0x44)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(s.emoji, style: TextStyle(fontSize: 13, height: 1)),
                                    const SizedBox(width: 5),
                                    Text(s.name, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: colors.ink, height: 1)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Colour
              _FormRow(
                label: 'Colour',
                colors: colors,
                child: Row(
                  children: [
                    for (int i = 0; i < _habitColors.length; i++) ...[
                      GestureDetector(
                        onTap: () => setState(() => _colorIdx = i),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _habitColors[i],
                            border: _colorIdx == i ? Border.all(width: 2.5, color: Colors.white) : null,
                          ),
                        ),
                      ),
                      if (i < _habitColors.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              // Labels
              _FormRow(
                label: 'Labels',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _labelChips.length; i++)
                      _Chip(label: _labelChips[i], selected: _selLabels.contains(i), colors: colors,
                        onTap: () => setState(() { if (_selLabels.contains(i)) {
                          _selLabels.remove(i);
                        } else {
                          _selLabels.add(i);
                        } }),
                      ),
                    _Chip(label: '+ New', selected: false, colors: colors, onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom labels coming soon')));
                    }),
                  ],
                ),
              ),
              // Frequency
              _FormRow(
                label: 'Frequency',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _freqChips.length; i++)
                      _Chip(label: _freqChips[i], selected: _freqIdx == i, colors: colors, onTap: () => setState(() => _freqIdx = i)),
                  ],
                ),
              ),
              // Routine steps (sub-habits)
              _FormRow(
                label: 'Routine steps',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _steps[i].isDone = !_steps[i].isDone),
                              child: Container(
                                width: 16, height: 16,
                                decoration: BoxDecoration(
                                  color: _steps[i].isDone ? TaskEraColors.acc.withAlpha(0x33) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(width: 0.5, color: _steps[i].isDone ? TaskEraColors.acc : colors.bdr),
                                ),
                                child: _steps[i].isDone ? const Icon(Icons.check_rounded, size: 11, color: TaskEraColors.acc) : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_steps[i].title, style: TextStyle(
                                fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                                color: _steps[i].isDone ? colors.ink3 : colors.ink,
                                decoration: _steps[i].isDone ? TextDecoration.lineThrough : null,
                                decorationColor: colors.ink3,
                              )),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _steps.removeAt(i)),
                              child: Icon(Icons.close_rounded, size: 16, color: colors.ink3),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(child: _InputField(controller: _stepCtrl, hint: 'Add a step e.g. Warm up 5 min', colors: colors)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addStep,
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0x120A84FF),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(width: 0.5, color: TaskEraColors.acc.withAlpha(0x55)),
                            ),
                            child: const Icon(Icons.add_rounded, size: 18, color: TaskEraColors.acc),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Reminder / scheduled time
              _FormRow(
                label: 'Reminder · time',
                colors: colors,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _reminderOn
                            ? () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _reminderTime,
                                );
                                if (picked != null && mounted) {
                                  setState(() => _reminderTime = picked);
                                }
                              }
                            : null,
                        child: Text(
                          _reminderOn ? _reminderTime.format(context) : 'Off',
                          style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                            color: _reminderOn ? colors.ink : colors.ink3,
                          ),
                        ),
                      ),
                    ),
                    _Toggle(value: _reminderOn, onChanged: (v) => setState(() => _reminderOn = v)),
                  ],
                ),
              ),
              // Remind me — schedules a real reminder/alarm that fires
              _FormRow(
                label: 'Remind me',
                colors: colors,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showAddReminderSheet(context, ref,
                      initialLabel: _nameCtrl.text.trim()),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('+ Set reminder or alarm',
                            style: TextStyle(
                                fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3)),
                      ),
                      Icon(Icons.alarm, size: 14, color: colors.ink3),
                    ],
                  ),
                ),
              ),
              // When & Where
              _FormRow(
                label: 'When & Where · cue',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputField(controller: _whenCtrl, hint: '"After morning coffee"', colors: colors),
                    const SizedBox(height: 5),
                    _InputField(controller: _whereCtrl, hint: '"At my desk / gym / kitchen"', colors: colors),
                    const SizedBox(height: 5),
                    Text(
                      'Habits stick when tied to a specific time + place cue.',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3.withAlpha(0xB3), height: 1.4),
                    ),
                  ],
                ),
              ),
              // Notes
              _FormRow(
                label: 'Notes',
                colors: colors,
                child: _InputField(controller: _notesCtrl, hint: AppL10n.of(context).optionalNotesHint, colors: colors),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _delete,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFF453A),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(width: 0.5, color: const Color(0x4DFF453A)),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppL10n.of(context).deleteHabit,
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SubBar extends StatelessWidget {
  final String title;
  final TaskEraColors colors;
  final Widget? trailing;
  const _SubBar({required this.title, required this.colors, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
      child: Row(
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _SaveBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
        child: Text(AppL10n.of(context).save, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final TaskEraColors colors;
  const _FormRow({required this.label, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink3, letterSpacing: 0.4, height: 1)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TaskEraColors colors;
  const _InputField({required this.controller, required this.hint, required this.colors});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink, height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
        filled: false,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(width: 0.5, color: TaskEraColors.acc)),
        contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        isDense: true,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TaskEraColors colors;
  const _Chip({required this.label, required this.selected, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
        decoration: BoxDecoration(
          color: selected ? TaskEraColors.acc : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: selected ? TaskEraColors.acc : colors.bdr),
        ),
        child: Text(label,
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : colors.ink2, height: 1)),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 21,
        decoration: BoxDecoration(
          color: value ? TaskEraColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}
