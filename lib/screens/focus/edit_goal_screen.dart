import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show GoalsCompanion, Habit;
import '../../data/providers/database_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../util/kaal_dialogs.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/goal_link_pickers.dart';
import '../../l10n/app_l10n.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final String goalId;
  const EditGoalScreen({super.key, required this.goalId});

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  final _nameCtrl       = TextEditingController();
  final _whyCtrl        = TextEditingController();
  final _milestoneCtrl  = TextEditingController();
  final _notesCtrl      = TextEditingController();
  String _emoji         = '🎯';
  int?   _catIdx;
  int?   _quadIdx;
  bool   _loading       = false;
  DateTime? _deadline;
  final List<String> _milestones = [];
  final Set<int> _habitIds = {}; // habits to link to this goal

  bool get _isNew => widget.goalId.isEmpty;
  int? get _id    => int.tryParse(widget.goalId);

  static const _cats = [
    ('🚀 Launch',   Color(0xFFBF5AF2)),
    ('💪 Health',   Color(0xFFFF8080)),
    ('📚 Learning', KaalColors.acc2),
    ('💰 Finance',  KaalColors.success),
    ('🎯 Career',   KaalColors.q4),
    ('🌱 Other',    Color(0xFF8E8E93)),
  ];

  static const _quads = [
    ('Q1 · Do Now',    KaalColors.q1),
    ('Q2 · Schedule',  KaalColors.q2),
    ('Q3 · Delegate',  KaalColors.q3),
  ];

  static const _emojiOptions = [
    '🎯', '🚀', '💪', '📚', '💰', '🌱', '🏆', '🔥', '⭐', '💡',
    '🧠', '❤️', '🏃', '🧘', '✍️', '🎨', '🎵', '🌍', '📈', '🛠️',
    '🏠', '✈️', '🍎', '💼', '🎓', '⏰', '📱', '💻', '🤝', '🙏',
  ];

  @override
  void initState() {
    super.initState();
    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoal());
    }
  }

  Future<void> _loadGoal() async {
    final id = _id;
    if (id == null) return;
    final db = ref.read(appDatabaseProvider);
    final goal = await db.goalsDao.getGoal(id);
    final habitLinks = await db.goalsDao.getHabitLinks(id);
    if (goal != null && mounted) {
      setState(() {
        _nameCtrl.text = goal.title;
        _whyCtrl.text  = goal.subtitle;
        _notesCtrl.text = goal.notes ?? '';
        _emoji         = goal.emoji;
        _deadline      = goal.deadline;
        _milestones
          ..clear()
          ..addAll(goal.milestones.split('\n').where((s) => s.isNotEmpty));
        _habitIds
          ..clear()
          ..addAll(habitLinks.map((l) => l.habitId));
      });
    }
  }

  void _showEmojiPicker() {
    final colors = KaalTheme.of(context).colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      isScrollControlled: true,
      builder: (sheetCtx) {
        final safeBot = MediaQuery.of(sheetCtx).padding.bottom;
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
              Text('Choose an icon', style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojiOptions.map((e) {
                  final selected = _emoji == e;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _emoji = e);
                      Navigator.pop(sheetCtx);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0x33BF5AF2) : colors.surf2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: selected ? 1.5 : 0.5,
                          color: selected ? const Color(0xFFBF5AF2) : colors.bdr0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final title = _nameCtrl.text.trim();
    if (title.isEmpty) return;
    // Flush a milestone typed into the field but not yet committed with the
    // "+Add" button — otherwise it's silently lost on save.
    final pendingMilestone = _milestoneCtrl.text.trim();
    if (pendingMilestone.isNotEmpty &&
        _milestones.length < 5 &&
        !_milestones.contains(pendingMilestone)) {
      _milestones.add(pendingMilestone);
      _milestoneCtrl.clear();
    }
    setState(() => _loading = true);
    try {
      final color    = _catIdx != null ? _cats[_catIdx!].$2 : const Color(0xFF0A84FF);
      final colorInt = color.toARGB32();
      final quadLabel = _quadIdx != null ? _quads[_quadIdx!].$1.toUpperCase() : '';
      final linkedLabel = quadLabel.isNotEmpty ? 'LINKED $quadLabel · 0/0' : 'LINKED TASKS · 0/0';

      final companion = GoalsCompanion(
        emoji:            Value(_emoji),
        emojiBg:          Value('0x1F${colorInt.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
        title:            Value(title),
        subtitle:         Value(_whyCtrl.text.trim()),
        accentColorValue: Value(colorInt),
        barColorValue:    Value(color.withAlpha(0xE5).toARGB32()),
        borderColorValue: Value(color.withAlpha(0x33).toARGB32()),
        linkedLabel:      Value(linkedLabel),
        dotColorValue:    Value(colorInt),
        deadline:         Value(_deadline),
        milestones:       Value(_milestones.join('\n')),
        notes:            Value(_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      );

      final db = ref.read(appDatabaseProvider);
      final int gid;
      if (_isNew) {
        gid = await db.goalsDao.insertGoal(companion);
      } else {
        gid = _id!;
        await db.goalsDao.updateGoal(gid, companion);
      }
      // Sync linked habits.
      final current = (await db.goalsDao.getHabitLinks(gid)).map((l) => l.habitId).toSet();
      for (final id in _habitIds.difference(current)) { await db.goalsDao.linkHabit(gid, id); }
      for (final id in current.difference(_habitIds)) { await db.goalsDao.unlinkHabit(gid, id); }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whyCtrl.dispose();
    _milestoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final allHabits = ref.watch(habitsProvider).value ?? const <Habit>[];
    final selectedHabits = allHabits.where((h) => _habitIds.contains(h.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  _isNew ? 'Add goal' : 'Edit goal',
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontVariations: [FontVariation('wght', 600)],
                    fontSize: 19,
                    letterSpacing: -0.5,
                    color: Color(0xFFF2F2F7),
                    height: 1.1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _loading ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _loading ? const Color(0xFF636366) : KaalColors.acc,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _loading
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text(
                          'Save',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),

        // Form body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Goal name
                _FormRow(
                  label: 'GOAL NAME',
                  required: true,
                  colors: colors,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Input(
                          controller: _nameCtrl,
                          hint: 'e.g. Hit \$100k MRR',
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showEmojiPicker,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0x1ABF5AF2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.5, color: const Color(0xFFBF5AF2)),
                          ),
                          alignment: Alignment.center,
                          child: Text(_emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Category
                _FormRow(
                  label: 'CATEGORY',
                  colors: colors,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(_cats.length, (i) => GestureDetector(
                      onTap: () => setState(() => _catIdx = i),
                      child: _Chip(
                        label: _cats[i].$1,
                        color: _cats[i].$2,
                        active: _catIdx == i,
                        colors: colors,
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 10),

                // Why this matters
                _FormRow(
                  label: 'WHY THIS MATTERS',
                  labelSuffix: ' · keeps you anchored',
                  colors: colors,
                  child: _Input(
                    controller: _whyCtrl,
                    hint: 'e.g. "Financial freedom by 35 → time with family"',
                    maxLines: 3,
                    colors: colors,
                  ),
                ),
                const SizedBox(height: 10),

                // Notes — freeform, surfaced in the Notes tab
                _FormRow(
                  label: 'NOTES',
                  colors: colors,
                  child: _Input(
                    controller: _notesCtrl,
                    hint: 'Add notes…',
                    maxLines: 4,
                    colors: colors,
                  ),
                ),
                const SizedBox(height: 10),

                // Measurable outcome
                _FormRow(
                  label: 'MEASURABLE OUTCOME',
                  required: true,
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: _Input(hint: '100', centered: true, colors: colors),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: _Input(hint: 'unit (k MRR / kg / books)', colors: colors),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(child: _Input(hint: 'start: 12', centered: true, small: true, colors: colors)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('→', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3)),
                          ),
                          Expanded(child: _Input(hint: 'now: 28', centered: true, small: true, colors: colors)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Deadline
                _FormRow(
                  label: 'DEADLINE',
                  required: true,
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (picked != null && mounted) setState(() => _deadline = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: _deadline != null ? KaalColors.acc : colors.bdr2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14,
                                  color: _deadline != null ? KaalColors.acc2 : colors.ink3),
                              const SizedBox(width: 8),
                              Text(
                                _deadline != null
                                    ? '${_deadline!.month.toString().padLeft(2, '0')}/${_deadline!.day.toString().padLeft(2, '0')}/${_deadline!.year}'
                                    : 'Select deadline…',
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 14,
                                  color: _deadline != null ? colors.ink : colors.ink3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _DeadlineChip(label: '30 days',   days: 30,   deadline: _deadline, onSet: (d) => setState(() => _deadline = d)),
                          _DeadlineChip(label: 'Q (90d)',   days: 90,   deadline: _deadline, onSet: (d) => setState(() => _deadline = d)),
                          _DeadlineChip(label: '6 months',  days: 180,  deadline: _deadline, onSet: (d) => setState(() => _deadline = d)),
                          _DeadlineChip(label: '1 year',    days: 365,  deadline: _deadline, onSet: (d) => setState(() => _deadline = d)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Linked quadrant
                _FormRow(
                  label: 'LINKED QUADRANT',
                  colors: colors,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(_quads.length, (i) => GestureDetector(
                      onTap: () => setState(() => _quadIdx = i),
                      child: _Chip(
                        label: _quads[i].$1,
                        color: _quads[i].$2,
                        active: _quadIdx == i,
                        colors: colors,
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 10),

                // Milestones
                _FormRow(
                  label: 'MILESTONES',
                  labelSuffix: ' · break into ≤ 5',
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._milestones.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 14, height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 1.5, color: colors.bdr2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.value,
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink))),
                            GestureDetector(
                              onTap: () => setState(() => _milestones.removeAt(e.key)),
                              child: Icon(Icons.close_rounded, size: 14, color: colors.ink3),
                            ),
                          ],
                        ),
                      )),
                      if (_milestones.length < 5)
                        Row(
                          children: [
                            Expanded(
                              child: _Input(
                                controller: _milestoneCtrl,
                                hint: AppL10n.of(context).addMilestoneHint,
                                colors: colors,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final text = _milestoneCtrl.text.trim();
                                if (text.isNotEmpty) {
                                  setState(() {
                                    _milestones.add(text);
                                    _milestoneCtrl.clear();
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                                decoration: BoxDecoration(
                                  color: KaalColors.accBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                                ),
                                child: Text('＋ ${AppL10n.of(context).add}',
                                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                                        fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Supporting tasks
                _FormRow(
                  label: 'SUPPORTING TASKS',
                  labelSuffix: ' · concrete next steps',
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Input(hint: AppL10n.of(context).addLinkedTaskHint, colors: colors),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                            decoration: BoxDecoration(
                              color: KaalColors.accBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                            ),
                            child: const Text(
                              '＋ Add',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: KaalColors.acc2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '＋ Create full task →',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: KaalColors.acc2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Supporting habits — link recurring routines to this goal
                _FormRow(
                  label: 'SUPPORTING HABITS',
                  labelSuffix: ' · recurring routines',
                  colors: colors,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final h in selectedHabits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text(h.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(h.name,
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.3)),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _habitIds.remove(h.id)),
                                child: Icon(Icons.close_rounded, size: 14, color: colors.ink3),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            showHabitLinkPicker(
                              context: context,
                              habits: ref.read(habitsProvider).value ?? const <Habit>[],
                              initial: Set<int>.from(_habitIds),
                              colors: colors,
                              onSave: (selected) => setState(() {
                                _habitIds
                                  ..clear()
                                  ..addAll(selected);
                              }),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x1ABF5AF2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 0.5, color: const Color(0x4DBF5AF2)),
                            ),
                            child: Text('＋ ${AppL10n.of(context).linkHabit}',
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                                    fontWeight: FontWeight.w700, color: Color(0xFFBF5AF2))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isNew) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await kaalConfirmDelete(context);
                      if (confirmed && context.mounted) {
                        await ref.read(appDatabaseProvider).goalsDao.deleteGoal(_id!);
                        if (context.mounted) context.pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x12FF453A),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(width: 0.5, color: const Color(0x33FF453A)),
                      ),
                      alignment: Alignment.center,
                      child: Text(AppL10n.of(context).deleteGoal, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Deadline quick-set chip ───────────────────────────────────────────────────

class _DeadlineChip extends StatelessWidget {
  final String label;
  final int days;
  final DateTime? deadline;
  final void Function(DateTime) onSet;
  const _DeadlineChip({required this.label, required this.days, required this.deadline, required this.onSet});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final target = DateTime.now().add(Duration(days: days));
    final isActive = deadline != null &&
        deadline!.year == target.year &&
        deadline!.month == target.month &&
        deadline!.day == target.day;
    return GestureDetector(
      onTap: () => onSet(target),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: isActive ? const Color(0x660A84FF) : colors.bdr),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? KaalColors.acc2 : colors.ink3,
          ),
        ),
      ),
    );
  }
}

// ── Form widgets ──────────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final String label;
  final String? labelSuffix;
  final bool required;
  final Widget child;
  final KaalColors colors;
  const _FormRow({
    required this.label,
    required this.child,
    required this.colors,
    this.labelSuffix,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.ink3,
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: KaalColors.warn),
                ),
              if (labelSuffix != null)
                TextSpan(
                  text: labelSuffix,
                  style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final bool centered;
  final bool small;
  final int maxLines;
  final KaalColors colors;
  const _Input({
    this.controller,
    required this.hint,
    this.centered = false,
    this.small = false,
    this.maxLines = 1,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: small ? 12 : 14,
        color: colors.ink,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: small ? 12 : 14,
          color: colors.ink3,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: small ? 7 : 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 0.5, color: colors.bdr2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(width: 0.5, color: colors.bdr2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 1, color: KaalColors.acc),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final KaalColors colors;
  const _Chip({required this.label, required this.color, required this.active, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 0.5,
          color: active ? const Color(0x660A84FF) : colors.bdr,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
