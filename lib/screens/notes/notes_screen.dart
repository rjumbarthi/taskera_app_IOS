import 'package:flutter/material.dart';
import '../../widgets/ai_insight_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;
import '../../data/database.dart' show Note, NoteTag, NotesCompanion, Task, Habit, Goal;
import '../../data/models/note_block.dart';
import '../../data/providers/database_provider.dart';
import '../../data/providers/notes_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/habits_provider.dart';
import '../../data/providers/goals_provider.dart';
import '../../services/activity_log_service.dart';
import '../../routing/routes.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';

// Source chips for notes that live on a task / habit / goal rather than the
// notes table. Tapping such a card opens the source item, not the note editor.
const _kTaskTag  = _Tag('📋 Task',  bg: Color(0x1A0A84FF), fg: TaskEraColors.acc2);
const _kHabitTag = _Tag('🔁 Habit', bg: Color(0x1A7FBA00), fg: Color(0xFF9FCD44));
const _kGoalTag  = _Tag('🎯 Goal',  bg: Color(0x1ABF5AF2), fg: Color(0xFFCF7BFF));

// ── Data ──────────────────────────────────────────────────────────────────────

class _Tag {
  const _Tag(this.label, {required this.bg, required this.fg});
  final String label;
  final Color  bg;
  final Color  fg;
}

class _Note {
  const _Note({
    required this.id,
    required this.title,
    required this.preview,
    required this.time,
    this.aiLabel,
    this.tags = const [],
    this.isPinned = false,
    this.route,
  });
  final int          id;
  final String       title;
  final String       preview;
  final String       time;
  final String?      aiLabel;  // e.g. '✦ AI summary'
  final List<_Tag>   tags;
  final bool         isPinned;
  // When set, this note lives on a task/habit/goal — tapping opens [route]
  // instead of the note editor, and the pin/delete menu is suppressed.
  final String?      route;
}

String _previewOf(String body) =>
    body.length > 120 ? '${body.substring(0, 120)}…' : body;

// ── DB → display model mapping ─────────────────────────────────────────────

// One-line preview: collapse block newlines to spaces and clip to 120 chars.
String _preview(String plain) {
  final flat = plain.replaceAll('\n', ' ').trim();
  return flat.length > 120 ? '${flat.substring(0, 120)}…' : flat;
}

_Note _rowToNote(Note n, List<NoteTag> tags) => _Note(
      id: n.id,
      title: n.title,
      preview: _preview(BlockDocument.plainTextOf(n.body)),
      time: n.timeLabel,
      aiLabel: n.aiLabel,
      isPinned: n.isPinned,
      tags: tags
          .map((t) => _Tag(t.label,
              bg: Color(t.bgColorValue), fg: Color(t.fgColorValue)))
          .toList(),
    );

// ── Screen ────────────────────────────────────────────────────────────────────

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = TaskEraTheme.of(context).colors;
    final noteRows = ref.watch(notesProvider).value ?? [];

    final pinned = <_Note>[];
    final recent = <_Note>[];
    for (final n in noteRows) {
      final tags = ref.watch(noteTagsProvider(n.id)).value ?? [];
      final note = _rowToNote(n, tags);
      if (n.isPinned) {
        pinned.add(note);
      } else {
        recent.add(note);
      }
    }

    // Notes that live on a task / habit / goal — surfaced read-only here so the
    // Notes tab is the single place to see everything you've jotted down.
    String? clean(String? s) {
      final t = s?.trim() ?? '';
      return t.isEmpty ? null : t;
    }
    final linked = <_Note>[];
    for (final t in (ref.watch(allTasksProvider).value ?? const <Task>[])) {
      final body = clean(t.notes);
      if (body != null) {
        linked.add(_Note(id: t.id, title: t.title, preview: _previewOf(body),
            time: '', tags: const [_kTaskTag], route: '/tasks/taskdetail/${t.id}'));
      }
    }
    for (final h in (ref.watch(habitsProvider).value ?? const <Habit>[])) {
      final body = clean(h.notes);
      if (body != null) {
        linked.add(_Note(id: h.id, title: h.name, preview: _previewOf(body),
            time: '', tags: const [_kHabitTag], route: '/habits/habitdetail/${h.id}'));
      }
    }
    for (final g in (ref.watch(goalsProvider).value ?? const <Goal>[])) {
      final body = clean(g.notes);
      if (body != null) {
        linked.add(_Note(id: g.id, title: g.title, preview: _previewOf(body),
            time: '', tags: const [_kGoalTag], route: '/focus/goals/${g.id}'));
      }
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: TaskEraColors.acc,
          backgroundColor: const Color(0xFF1C1C1E),
          onRefresh: () async {
            ref.invalidate(notesProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          children: [
            AiInsightCard(
              input: noteRows.isEmpty
                  ? 'The user has no notes yet.'
                  : 'My notes:\n${noteRows.take(20).map((n) {
                      final t = BlockDocument.plainTextOf(n.body).replaceAll('\n', ' ');
                      return '- ${n.title}: ${t.length > 160 ? t.substring(0, 160) : t}';
                    }).join('\n')}',
              hint: 'See what TaskEra AI notices across your notes',
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push(TaskEraRoutes.databases),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0x120A84FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                ),
                child: Row(children: [
                  const Text('🗂️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Databases',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14.5, fontWeight: FontWeight.w600, color: colors.ink)),
                        Text('Tables, boards & lists — Notion-style',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 20, color: colors.ink3),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            if (pinned.isNotEmpty) ...[
              _SectionLabel(label: 'Pinned', colors: colors),
              const SizedBox(height: 4),
              for (var i = 0; i < pinned.length; i++) ...[
                _NoteCard(note: pinned[i], prominent: i == 0, colors: colors),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 3),
            ],
            if (recent.isNotEmpty) ...[
              _SectionLabel(label: 'Recent', colors: colors),
              const SizedBox(height: 4),
              for (final n in recent) ...[
                _NoteCard(note: n, colors: colors),
                const SizedBox(height: 4),
              ],
            ],
            if (linked.isNotEmpty) ...[
              const SizedBox(height: 3),
              _SectionLabel(label: 'From your tasks, habits & goals', colors: colors),
              const SizedBox(height: 4),
              for (final n in linked) ...[
                _NoteCard(note: n, colors: colors),
                const SizedBox(height: 4),
              ],
            ],
          ],
        )),
        Positioned(
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          child: GestureDetector(
            onTap: () => context.push(TaskEraRoutes.notesEditor),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: TaskEraColors.acc,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x8C000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final TaskEraColors colors;
  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink3,
        height: 1,
      ),
    );
  }
}

// ── Note card ─────────────────────────────────────────────────────────────────

class _NoteCard extends ConsumerWidget {
  final _Note note;
  final bool  prominent;
  final TaskEraColors colors;

  const _NoteCard({required this.note, this.prominent = false, required this.colors});

  void _showMenu(BuildContext context, WidgetRef ref) {
    final dao = ref.read(appDatabaseProvider).notesDao;
    final logNotifier = ref.read(activityLogProvider.notifier);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _NoteMenuSheet(note: note, dao: dao, colors: colors,
        onEdit: () { Navigator.pop(sheetCtx); context.push('${TaskEraRoutes.notesEditor}/${note.id}'); },
        onLog: (msg) => logNotifier.add(msg, type: 'note'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLinked = note.route != null;
    return GestureDetector(
      onTap: () => context.push(note.route ?? '${TaskEraRoutes.notesEditor}/${note.id}'),
      onLongPress: isLinked ? null : () => _showMenu(context, ref),
      onSecondaryTap: isLinked ? null : () => _showMenu(context, ref),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 0.5,
            color: prominent ? colors.bdr2 : colors.bdr,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + optional AI badge + timestamp
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink, height: 1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.aiLabel != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.fromLTRB(5, 1.5, 5, 1.5),
                    decoration: BoxDecoration(color: TaskEraColors.accBg, borderRadius: BorderRadius.circular(4)),
                    child: Text(note.aiLabel!, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: TaskEraColors.acc2, height: 1)),
                  ),
                ],
                const SizedBox(width: 6),
                Text(note.time, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1)),
              ],
            ),
            const SizedBox(height: 5),
            // Preview body (2-line clamp)
            Text(
              note.preview,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Tags
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  for (int i = 0; i < note.tags.length; i++) ...[
                    _TagChip(tag: note.tags[i]),
                    if (i < note.tags.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Note context menu sheet ───────────────────────────────────────────────────

class _NoteMenuSheet extends StatelessWidget {
  final _Note note;
  final dynamic dao;
  final TaskEraColors colors;
  final VoidCallback onEdit;
  final void Function(String msg) onLog;

  const _NoteMenuSheet({required this.note, required this.dao, required this.colors,
      required this.onEdit, required this.onLog});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(width: 0.5, color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0x40FFFFFF), borderRadius: BorderRadius.circular(2))),
          Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
          const SizedBox(height: 14),
          _MenuItem(icon: Icons.edit_rounded, label: 'Edit note', colors: colors, onTap: onEdit),
          _MenuItem(
            icon: note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
            label: note.isPinned ? 'Unpin' : 'Pin to top',
            colors: colors,
            onTap: () async {
              await dao.updateNote(note.id, NotesCompanion(isPinned: Value(!note.isPinned)));
              onLog(note.isPinned ? 'Note "${note.title}" unpinned' : 'Note "${note.title}" pinned');
              if (context.mounted) Navigator.pop(context);
            },
          ),
          _MenuItem(
            icon: Icons.delete_rounded,
            label: 'Delete note',
            colors: colors,
            textColor: const Color(0xFFFF453A),
            onTap: () async {
              await dao.deleteNote(note.id);
              onLog('Note "${note.title}" deleted');
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final TaskEraColors colors;
  final Color? textColor;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.colors, this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? colors.ink2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(4, 11, 4, 11),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr0))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: color, height: 1)),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final _Tag tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(color: tag.bg, borderRadius: BorderRadius.circular(4)),
      child: Text(tag.label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: tag.fg, height: 1)),
    );
  }
}
