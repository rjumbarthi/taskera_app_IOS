import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show NotesCompanion, Task;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../util/kaal_dialogs.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../services/activity_log_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/goal_link_pickers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  // Ids of tasks linked to this note (source of truth while editing).
  final Set<int> _linkedTaskIds = {};

  bool get _isEdit => widget.noteId != null;
  int? get _parsedId => widget.noteId != null ? int.tryParse(widget.noteId!) : null;

  @override
  void initState() {
    super.initState();
    if (_parsedId != null) _loadNote();
  }

  Future<void> _loadNote() async {
    final dao  = ref.read(appDatabaseProvider).notesDao;
    final note = await dao.getNote(_parsedId!);
    final links = await dao.getTaskLinks(_parsedId!);
    if (note != null && mounted) {
      _titleCtrl.text = note.title;
      _bodyCtrl.text  = note.body;
      setState(() {
        _pinned = note.isPinned;
        _linkedTaskIds
          ..clear()
          ..addAll(links.map((l) => l.taskId));
      });
    }
  }

  Future<void> _aiScan() async {
    final body = _bodyCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (body.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Write a note first to scan it')));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('✦ Scanning note…')));
    try {
      final summary = await ref.read(aiServiceProvider).summarizeNote(body);
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text((summary == null || summary.isEmpty)
            ? 'AI returned no summary. Try again.'
            : summary),
        duration: const Duration(seconds: 6),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  void _openTaskPicker(KaalColors colors) {
    final all = ref.read(allTasksProvider).value ?? const <Task>[];
    showTaskLinkPicker(
      context: context,
      tasks: all,
      initial: _linkedTaskIds,
      colors: colors,
      title: 'Link tasks to this note',
      onSave: (selected) => setState(() {
        _linkedTaskIds
          ..clear()
          ..addAll(selected);
      }),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final dao = ref.read(appDatabaseProvider).notesDao;
    if (_isEdit && _parsedId != null) {
      await dao.updateNote(
        _parsedId!,
        NotesCompanion(
          title: Value(title),
          body: Value(_bodyCtrl.text),
          isPinned: Value(_pinned),
          timeLabel: const Value('Just now'),
        ),
      );
      await dao.setTaskLinks(_parsedId!, _linkedTaskIds);
      ref.logActivity('Note "$title" updated', type: 'note');
    } else {
      final newId = await dao.insertNote(
        NotesCompanion(
          title: Value(title),
          body: Value(_bodyCtrl.text),
          isPinned: Value(_pinned),
          timeLabel: const Value('Just now'),
        ),
      );
      await dao.setTaskLinks(newId, _linkedTaskIds);
      ref.logActivity('Note "$title" created', type: 'note');
    }
    if (mounted) context.pop();
  }

  int        _quadIdx   = 1; // Q2
  int        _goalIdx   = 3; // None
  bool       _pinned    = false;
  final Set<int> _selLabels  = {0}; // #idea

  static const _quads  = ['Q1 · Do Now', 'Q2 · Schedule', 'Q3 · Delegate', 'Q4 · Eliminate', 'None'];
  static const _quadColors = [KaalColors.q1, KaalColors.q2, KaalColors.q3, KaalColors.q4, Color(0xFF8E8E93)];
  static const _goals  = ['🚀 Launch MVP', '💪 Fitness', '📚 Read 12 books', 'None'];
  static const _labels = ['#idea', '#meeting', '#research', '#journal', '#braindump', '+ New'];
  static const _fmtBtns = ['B', 'I', 'U', '• List', '1.'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final allTasks    = ref.watch(allTasksProvider).value ?? const <Task>[];
    final linkedTasks = allTasks.where((t) => _linkedTaskIds.contains(t.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEdit ? 'Edit note' : 'New note',
                  style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1),
                ),
              ),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text(AppL10n.of(context).save, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Title + camera/mic
              _FormRow(
                label: 'Title',
                colors: colors,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleCtrl,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: colors.ink, height: 1.3),
                        decoration: InputDecoration(
                          hintText: '"Product Roadmap thoughts"',
                          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15, color: colors.ink3),
                          filled: false,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(width: 0.5, color: KaalColors.acc)),
                          contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Camera btn
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo capture coming soon'))),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0x1F7FBA00),
                          shape: BoxShape.circle,
                          border: Border.all(width: 0.5, color: const Color(0x407FBA00)),
                        ),
                        child: Icon(Icons.camera_alt_rounded, size: 14, color: colors.successFg),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Mic btn
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice notes coming soon'))),
                      child: Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0x1AFF453A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic_rounded, size: 14, color: Color(0xFFFF6B6B)),
                      ),
                    ),
                  ],
                ),
              ),
              // Quadrant
              _FormRow(
                label: 'Quadrant',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _quads.length; i++)
                      _ColorChip(
                        label: _quads[i],
                        selected: _quadIdx == i,
                        activeColor: _quadColors[i],
                        colors: colors,
                        onTap: () => setState(() => _quadIdx = i),
                      ),
                  ],
                ),
              ),
              // Linked goal
              _FormRow(
                label: 'Linked goal · optional',
                colors: colors,
                child: Wrap(
                  spacing: 5, runSpacing: 5,
                  children: [
                    for (int i = 0; i < _goals.length; i++)
                      _Chip(
                        label: _goals[i],
                        selected: _goalIdx == i,
                        colors: colors,
                        onTap: () => setState(() => _goalIdx = i),
                      ),
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
                    for (int i = 0; i < _labels.length; i++)
                      _Chip(
                        label: _labels[i],
                        selected: _selLabels.contains(i),
                        colors: colors,
                        onTap: () => setState(() {
                          if (i == _labels.length - 1) return;
                          if (_selLabels.contains(i)) {
                            _selLabels.remove(i);
                          } else {
                            _selLabels.add(i);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              // Note body
              _FormRow(
                label: 'Note body',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Format toolbar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final btn in _fmtBtns) ...[
                            _FmtBtn(label: btn, colors: colors),
                            const SizedBox(width: 4),
                          ],
                          const SizedBox(width: 8),
                          // AI scan btn
                          GestureDetector(
                            onTap: _aiScan,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                              ),
                              child: const Text('✦ AI scan', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: KaalColors.acc2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Body text area
                    Container(
                      constraints: const BoxConstraints(minHeight: 140),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: colors.bdr2),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: TextField(
                        controller: _bodyCtrl,
                        maxLines: null,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink, height: 1.65),
                        decoration: InputDecoration(
                          hintText: AppL10n.of(context).startWritingHint,
                          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
                          border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Linked tasks
              _FormRow(
                label: 'Linked tasks · optional',
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (linkedTasks.isNotEmpty) ...[
                      Wrap(
                        spacing: 5, runSpacing: 5,
                        children: [
                          for (final t in linkedTasks)
                            _LinkedTaskChip(
                              label: t.title,
                              quadrant: t.quadrant,
                              colors: colors,
                              onRemove: () => setState(() => _linkedTaskIds.remove(t.id)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                    ],
                    GestureDetector(
                      onTap: () => _openTaskPicker(colors),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surf2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 0.5, color: colors.bdr),
                        ),
                        child: Text(
                          linkedTasks.isEmpty ? '+ Link tasks' : '+ Edit linked tasks',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                              fontWeight: FontWeight.w600, color: KaalColors.acc2, height: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Pin to top
              _FormRow(
                label: AppL10n.of(context).pinToTop,
                colors: colors,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppL10n.of(context).pinToTop, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2)),
                    _Toggle(value: _pinned, onChanged: (v) => setState(() => _pinned = v)),
                  ],
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final confirmed = await kaalConfirmDelete(context);
                    if (confirmed && context.mounted) {
                      await ref.read(appDatabaseProvider).notesDao.deleteNote(_parsedId!);
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
                    child: Text(AppL10n.of(context).deleteNote, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
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

// ── Local widgets ─────────────────────────────────────────────────────────────

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final KaalColors colors;
  const _FormRow({required this.label, required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink3, letterSpacing: 0.4, height: 1)),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final KaalColors colors;
  const _Chip({required this.label, required this.selected, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
        decoration: BoxDecoration(
          color: selected ? KaalColors.acc : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: selected ? KaalColors.acc : colors.bdr),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? Colors.white : colors.ink2, height: 1)),
      ),
    );
  }
}

class _LinkedTaskChip extends StatelessWidget {
  final String label;
  final int quadrant;
  final VoidCallback onRemove;
  final KaalColors colors;
  const _LinkedTaskChip({required this.label, required this.quadrant, required this.onRemove, required this.colors});

  @override
  Widget build(BuildContext context) {
    final qColor = quadrant >= 1 && quadrant <= 4
        ? [KaalColors.q1, KaalColors.q2, KaalColors.q3, KaalColors.q4][quadrant - 1]
        : const Color(0xFF8E8E93);
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 6, 5),
      decoration: BoxDecoration(
        color: qColor.withAlpha(0x1F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: qColor.withAlpha(0x80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                    color: colors.ink, height: 1)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close_rounded, size: 13, color: colors.ink3),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;
  final KaalColors colors;
  const _ColorChip({required this.label, required this.selected, required this.activeColor, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
        decoration: BoxDecoration(
          color: selected ? activeColor.withAlpha(0x1F) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(width: 0.5, color: selected ? activeColor.withAlpha(0x80) : colors.bdr),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? activeColor : colors.ink2, height: 1)),
      ),
    );
  }
}

class _FmtBtn extends StatelessWidget {
  final String label;
  final KaalColors colors;
  const _FmtBtn({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rich text formatting coming soon'))),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink2)),
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
          color: value ? KaalColors.acc : const Color(0x33FFFFFF),
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
