import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart' show Task, Note, Habit;
import '../data/providers/tasks_provider.dart';
import '../data/providers/notes_provider.dart';
import '../data/providers/habits_provider.dart';
import '../routing/routes.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/add_back_button.dart';

// ── Result model ──────────────────────────────────────────────────────────────

class _Result {
  const _Result({
    required this.kind,
    required this.title,
    required this.sub,
    required this.route,
  });
  final String kind;   // 'Task' | 'Note' | 'Habit'
  final String title;
  final String sub;
  final String route;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  int _filter = 0;
  String _query = '';

  static const _filters = ['All', 'Tasks', 'Notes', 'Habits'];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_Result> _buildResults(
    List<Task> tasks,
    List<Note> notes,
    List<Habit> habits,
  ) {
    final q = _query.toLowerCase();
    final results = <_Result>[];

    if (_filter == 0 || _filter == 1) {
      for (final t in tasks) {
        if (t.title.toLowerCase().contains(q)) {
          results.add(_Result(
            kind: 'Task',
            title: t.title,
            sub: 'Q${t.quadrant}${t.isDone ? ' · Done' : ''}',
            route: KaalRoutes.tasks,
          ));
        }
      }
    }

    if (_filter == 0 || _filter == 2) {
      for (final n in notes) {
        if (n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q)) {
          results.add(_Result(
            kind: 'Note',
            title: n.title,
            sub: n.body.length > 60 ? '${n.body.substring(0, 60)}…' : n.body,
            route: '${KaalRoutes.notesEditor}/${n.id}',
          ));
        }
      }
    }

    if (_filter == 0 || _filter == 3) {
      for (final h in habits) {
        if (h.name.toLowerCase().contains(q)) {
          results.add(_Result(
            kind: 'Habit',
            title: '${h.emoji} ${h.name}',
            sub: h.frequencyLabel,
            route: KaalRoutes.habits,
          ));
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final colors  = KaalTheme.of(context).colors;
    final tasks   = ref.watch(allTasksProvider).value ?? [];
    final notes   = ref.watch(notesProvider).value ?? [];
    final habits  = ref.watch(habitsProvider).value ?? [];
    final results = _query.isNotEmpty ? _buildResults(tasks, notes, habits) : <_Result>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Row(
          children: [
            AddBackButton(
              onTap: () =>
                  context.canPop() ? context.pop() : context.go(KaalRoutes.focus),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SearchInput(
                ctrl: _ctrl,
                query: _query,
                colors: colors,
                onChange: (v) => setState(() => _query = v),
                onClear: () {
                  _ctrl.clear();
                  setState(() => _query = '');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FilterRow(
          selected: _filter,
          colors: colors,
          onSelect: (i) => setState(() => _filter = i),
          filters: _filters,
        ),
        const SizedBox(height: 12),
        if (_query.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                'Search tasks, notes, habits',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    color: colors.ink3, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                'No results for "$_query"',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    color: colors.ink3, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          for (final r in results) ...[
            _ResultTile(result: r, colors: colors, onTap: () => context.push(r.route)),
            const SizedBox(height: 4),
          ],
      ],
    );
  }
}

// ── Search input ──────────────────────────────────────────────────────────────

class _SearchInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String query;
  final KaalColors colors;
  final ValueChanged<String> onChange;
  final VoidCallback onClear;
  const _SearchInput({
    required this.ctrl,
    required this.query,
    required this.colors,
    required this.onChange,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: const Color(0x17FFFFFF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.ink3, size: 15),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: ctrl,
              autofocus: true,
              onChanged: onChange,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, color: colors.ink, height: 1),
              decoration: InputDecoration(
                hintText: AppL10n.of(context).search,
                hintStyle: TextStyle(
                    fontFamily: 'Inter', fontSize: 14, color: colors.ink3, height: 1),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (query.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Text('×',
                  style: TextStyle(
                      fontFamily: 'Inter', fontSize: 18, color: colors.ink3, height: 1)),
            ),
        ],
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final int selected;
  final KaalColors colors;
  final ValueChanged<int> onSelect;
  final List<String> filters;
  const _FilterRow({
    required this.selected,
    required this.colors,
    required this.onSelect,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                  decoration: BoxDecoration(
                    color: selected == i ? KaalColors.acc : const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(6),
                    border: selected == i
                        ? null
                        : Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
                  ),
                  child: Text(
                    filters[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected == i ? Colors.white : colors.ink3,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Result tile ───────────────────────────────────────────────────────────────

class _ResultTile extends StatelessWidget {
  final _Result result;
  final KaalColors colors;
  final VoidCallback onTap;
  const _ResultTile({required this.result, required this.colors, required this.onTap});

  static const _kindColor = {
    'Task':  KaalColors.acc2,
    'Note':  Color(0xFF9FCD44),
    'Habit': KaalColors.q4,
  };

  @override
  Widget build(BuildContext context) {
    final kindColor = _kindColor[result.kind] ?? KaalColors.acc2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              decoration: BoxDecoration(
                color: const Color(0x120A84FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(result.kind,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                      fontWeight: FontWeight.w700, color: kindColor, height: 1)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.title,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w600, color: colors.ink, height: 1.2),
                      overflow: TextOverflow.ellipsis),
                  if (result.sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(result.sub,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                            color: colors.ink3, height: 1.3),
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.ink3, size: 16),
          ],
        ),
      ),
    );
  }
}
