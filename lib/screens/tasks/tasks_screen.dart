import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;

import '../../data/database.dart' show Task, TasksCompanion, CustomList, CustomListItem;
import '../../data/providers/database_provider.dart';
import '../../data/providers/lists_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../routing/routes.dart';
import '../../settings/taskera_settings.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/taskera_sheet.dart';
import '../../services/activity_log_service.dart';
import '../../l10n/app_l10n.dart';
import '../../l10n/app_strings.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Sub {
  const _Sub(this.title) : isDone = false;
  final String title;
  final bool isDone;
}

class _Task {
  const _Task({
    required this.id,
    required this.title,
    required this.due,
    this.isOverdue = false,
    this.hasAi = false,
    this.recLabel,
    this.hasPomo = false,
    this.pomoMin = 25,
  }) : subs = const [];
  final int id;
  final String title;
  final String due;
  final bool isOverdue;
  final bool hasAi;
  final String? recLabel;
  final bool hasPomo;
  final int pomoMin;
  final List<_Sub> subs;
}

class _DoneTask {
  const _DoneTask(this.id, this.title, this.doneText, this.quad, this.qColor);
  final int id;
  final String title;
  final String doneText;
  final String quad;
  final Color qColor;
}

class _PruneItem {
  const _PruneItem(this.title, this.age, this.moveLabel);
  final String title;
  final String age;
  final String moveLabel;
}

// Prune data is not populated — requires updatedAt tracking (not yet in schema)
const _pruneData = <_PruneItem>[];

// ── DB → display model mapping ─────────────────────────────────────────────

_Task _rowToTask(Task r) => _Task(
      id: r.id,
      title: r.title,
      due: r.dueLabel ?? '',
      isOverdue: r.isOverdue,
      hasAi: r.hasAi,
      recLabel: r.recurrenceLabel,
      hasPomo: r.hasPomodoro,
      pomoMin: r.timeAllocatedMin ?? 25,
    );

_DoneTask _rowToDone(Task r, Map<int, String> names, AppStrings l10n) {
  const cols = {1: TaskEraColors.q1, 2: TaskEraColors.q2, 3: TaskEraColors.q3, 4: TaskEraColors.q4};
  final at = r.doneAt;
  final diff = at == null ? -1 : DateTime.now().difference(at).inDays;
  final label = diff < 0
      ? l10n.done
      : diff == 0
          ? l10n.doneToday
          : diff == 1
              ? l10n.doneYesterday
              : 'Done ${diff}d ago';
  return _DoneTask(r.id, r.title, label, names[r.quadrant] ?? '', cols[r.quadrant] ?? TaskEraColors.q2);
}

String _localizeDue(String raw, AppStrings l) => raw
    .replaceAll('This week', l.thisWeek)
    .replaceAll('Overdue', l.overdue)
    .replaceAll('Tomorrow', l.tomorrow)
    .replaceAll('Today', l.today)
    .replaceAll('Someday', l.someday);

String _localizeRec(String raw, AppStrings l) => raw
    .replaceAll('Daily', l.daily)
    .replaceAll('Weekly', l.weeklyRecur);

// ── Screen ────────────────────────────────────────────────────────────────────

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _isListView = true;
  bool _q1Open = true;
  bool _q2Open = true;
  bool _q3Open = true;
  bool _q4Open = true;
  bool _compOpen = false;
  bool _pruneVisible = false;

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final l10n = AppL10n.of(context);
    final settings = ref.watch(taskeraSettingsProvider);
    final useCovey = settings.qnames == 0;
    final showLists = settings.sw('listsGrid');
    final lists = ref.watch(listsProvider).valueOrNull ?? [];
    final qn = useCovey
        ? {1: 'Q1 · ${l10n.doNow}', 2: 'Q2 · ${l10n.scheduleLabel}', 3: 'Q3 · ${l10n.delegate}', 4: 'Q4 · ${l10n.eliminate}'}
        : {1: 'Q1 · ${l10n.urgent}', 2: 'Q2 · ${l10n.important}', 3: 'Q3 · ${l10n.delegate}', 4: 'Q4 · ${l10n.drop}'};

    final q1 = ref.watch(quadrantTasksProvider(1)).value?.map(_rowToTask).toList() ?? [];
    final q2 = ref.watch(quadrantTasksProvider(2)).value?.map(_rowToTask).toList() ?? [];
    final q3 = ref.watch(quadrantTasksProvider(3)).value?.map(_rowToTask).toList() ?? [];
    final q4 = ref.watch(quadrantTasksProvider(4)).value?.map(_rowToTask).toList() ?? [];
    final rawDone = ref.watch(doneTasksProvider).value ?? [];
    final done = rawDone.map((r) => _rowToDone(r, qn, l10n)).toList();

    double frac(int quad, int activeLen) {
      final d = rawDone.where((t) => t.quadrant == quad).length;
      final total = activeLen + d;
      return total > 0 ? d / total : 0.0;
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FilterChips(colors: colors, isListView: _isListView, onToggle: (v) => setState(() => _isListView = v)),
            Expanded(
              child: _isListView
                  ? _listView(context, colors, q1, q2, q3, q4, done, qn, frac, showLists, lists, settings.sw('quadColors'))
                  : _gridView(context, colors, q1, q2, q3, q4, done, qn, frac, showLists, lists),
            ),
          ],
        ),
        Positioned(
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          right: 16,
          child: _Fab(),
        ),
      ],
    );
  }

  Widget _listView(BuildContext context, TaskEraColors colors,
      List<_Task> q1, List<_Task> q2, List<_Task> q3, List<_Task> q4,
      List<_DoneTask> done, Map<int, String> qn, double Function(int, int) frac,
      bool showLists, List<CustomList> lists, bool quadColorsOn) {
    // paddingOf().bottom already includes the nav-bar height (injected by the
    // router shell), so this clears the floating nav on every device.
    final navClear = MediaQuery.paddingOf(context).bottom + 16;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12, 4, 12, navClear),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuadSection(
            quadColor: TaskEraColors.q1,
            bgColor: quadColorsOn ? TaskEraColors.q1.withAlpha(0x12) : Colors.transparent,
            name: qn[1]!,
            quadKey: 'q1',
            aiBadge: _HeaderBadge(label: '⚠ ${AppL10n.of(context).overdue}', isRed: true),
            fraction: frac(1, q1.length),
            tasks: q1,
            isOpen: _q1Open,
            onToggle: () => setState(() => _q1Open = !_q1Open),
            colors: colors,
          ),
          SizedBox(height: 4),
          _QuadSection(
            quadColor: TaskEraColors.q2,
            bgColor: quadColorsOn ? TaskEraColors.q2.withAlpha(0x12) : Colors.transparent,
            name: qn[2]!,
            quadKey: 'q2',
            aiBadge: _HeaderBadge(label: '✦ ${AppL10n.of(context).focus}', isRed: false),
            fraction: frac(2, q2.length),
            tasks: q2,
            isOpen: _q2Open,
            onToggle: () => setState(() => _q2Open = !_q2Open),
            colors: colors,
          ),
          SizedBox(height: 4),
          _QuadSection(
            quadColor: TaskEraColors.q3,
            bgColor: quadColorsOn ? TaskEraColors.q3.withAlpha(0x12) : Colors.transparent,
            name: qn[3]!,
            quadKey: 'q3',
            aiBadge: null,
            fraction: frac(3, q3.length),
            tasks: q3,
            isOpen: _q3Open,
            onToggle: () => setState(() => _q3Open = !_q3Open),
            colors: colors,
          ),
          SizedBox(height: 4),
          _QuadSection(
            quadColor: TaskEraColors.q4,
            bgColor: quadColorsOn ? TaskEraColors.q4.withAlpha(0x12) : Colors.transparent,
            name: qn[4]!,
            quadKey: 'q4',
            aiBadge: null,
            fraction: frac(4, q4.length),
            tasks: q4,
            isOpen: _q4Open,
            onToggle: () => setState(() => _q4Open = !_q4Open),
            colors: colors,
          ),
          SizedBox(height: 4),
          _CompletedSection(
            isOpen: _compOpen,
            onToggle: () => setState(() => _compOpen = !_compOpen),
            tasks: done,
            colors: colors,
          ),
          if (_pruneVisible) ...[
            SizedBox(height: 4),
            _PruneCard(
              onDismiss: () => setState(() => _pruneVisible = false),
              colors: colors,
            ),
          ],
          if (showLists && lists.isNotEmpty) ...[
            SizedBox(height: 8),
            _ListsInTasksSection(lists: lists, colors: colors),
          ],
        ],
      ),
    ),
    );
  }

  Widget _gridView(BuildContext context, TaskEraColors colors,
      List<_Task> q1, List<_Task> q2, List<_Task> q3, List<_Task> q4,
      List<_DoneTask> done, Map<int, String> qn, double Function(int, int) frac,
      bool showLists, List<CustomList> lists) {
    // paddingOf().bottom already includes the nav-bar height (injected by the
    // router shell), so this clears the floating nav on every device.
    final navClear = MediaQuery.paddingOf(context).bottom + 12;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Collapsed completed-panel header ≈ 46px. Give quads the remaining
        // viewport (minus the nav clearance) so both quad rows + the completed
        // header sit *above* the floating nav without scrolling.
        // Checklists appear below the fold and are reached by scrolling.
        const kCompH = 46.0;
        final quadsH = (constraints.maxHeight - kCompH - 10 - navClear).clamp(160.0, double.infinity);

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(12, 6, 12, navClear),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 2×2 quad cards ──────────────────────────────────────────
                SizedBox(
                  height: quadsH,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _QuadCard(quadColor: TaskEraColors.q1, name: qn[1]!, quadKey: 'q1', count: q1.length, fraction: frac(1, q1.length), tasks: q1, colors: colors)),
                            SizedBox(width: 6),
                            Expanded(child: _QuadCard(quadColor: TaskEraColors.q2, name: qn[2]!, quadKey: 'q2', count: q2.length, fraction: frac(2, q2.length), tasks: q2, colors: colors)),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _QuadCard(quadColor: TaskEraColors.q3, name: qn[3]!, quadKey: 'q3', count: q3.length, fraction: frac(3, q3.length), tasks: q3, colors: colors)),
                            SizedBox(width: 6),
                            Expanded(child: _QuadCard(quadColor: TaskEraColors.q4, name: qn[4]!, quadKey: 'q4', count: q4.length, fraction: frac(4, q4.length), tasks: q4, colors: colors)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Completed panel — visible at bottom of viewport ──────────
                SizedBox(height: 4),
                _CompletedSection(
                  isOpen: _compOpen,
                  onToggle: () => setState(() => _compOpen = !_compOpen),
                  tasks: done,
                  colors: colors,
                ),
                // ── Checklists — appear on scroll when setting is on ─────────
                if (showLists && lists.isNotEmpty) ...[
                  SizedBox(height: 8),
                  _ListsInTasksSection(lists: lists, colors: colors),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── View-toggle chip (List / 2×2) ─────────────────────────────────────────────

class _ViewChip extends StatelessWidget {
  final String label;
  final TaskEraColors colors;
  final VoidCallback onTap;
  const _ViewChip({required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: const BoxDecoration(),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: TaskEraTheme.of(context).fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.ink3,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final TaskEraColors colors;
  final bool isListView;
  final void Function(bool) onToggle;
  const _FilterChips({required this.colors, required this.isListView, required this.onToggle});

  static const _goalsIconSvg =
      '<svg width="10" height="10" viewBox="0 0 22 22" fill="none" stroke="#9fcd44" '
      'stroke-width="1.8" stroke-linecap="round">'
      '<circle cx="11" cy="11" r="9"/><circle cx="11" cy="11" r="4"/>'
      '<circle cx="11" cy="11" r="1" fill="#9fcd44" stroke="none"/></svg>';

  static const _clockSvg =
      '<svg width="10" height="10" viewBox="0 0 22 22" fill="none" stroke="currentColor" '
      'stroke-width="1.8" stroke-linecap="round">'
      '<circle cx="11" cy="11" r="8"/><path d="M11 6v5l3 2"/></svg>';

  static const _filterSvg =
      '<svg width="10" height="10" viewBox="0 0 22 22" fill="none" stroke="currentColor" '
      'stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66'
      'l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        label: '📥 ${AppL10n.of(context).inbox}',
                        textColor: TaskEraColors.acc2,
                        bg: TaskEraColors.accBg,
                        border: const Color(0x330A84FF),
                        onTap: () => context.push(TaskEraRoutes.tasksInbox),
                      ),
                      SizedBox(width: 4),
                      _Chip(
                        label: '📌 ${AppL10n.of(context).board}',
                        textColor: const Color(0xFF5856D6),
                        bg: const Color(0x145856D6),
                        border: const Color(0x335856D6),
                        onTap: () => context.push(TaskEraRoutes.tasksBoard),
                      ),
                      SizedBox(width: 4),
                      _Chip(
                        label: '🏷 ${AppL10n.of(context).labels}',
                        textColor: const Color(0xFFFF375F),
                        bg: const Color(0x14FF375F),
                        border: const Color(0x33FF375F),
                        onTap: () => context.push(TaskEraRoutes.tasksLabels),
                      ),
                      SizedBox(width: 4),
                      _Chip(
                        icon: SvgPicture.string(_filterSvg, width: 10, height: 10,
                            colorFilter: const ColorFilter.mode(Color(0xFF00BCD4), BlendMode.srcIn)),
                        label: AppL10n.of(context).filter,
                        textColor: const Color(0xFF00BCD4),
                        bg: const Color(0x1400BCD4),
                        border: const Color(0x3300BCD4),
                        onTap: () => context.push(TaskEraRoutes.tasksFilters),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              _ViewChip(
                label: isListView ? '⊞ 2×2' : '≡ List',
                colors: colors,
                onTap: () => onToggle(!isListView),
              ),
              SizedBox(width: 12),
            ],
          ),
          SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(label: '⚡ ${AppL10n.of(context).auto}', textColor: const Color(0xFFFFB900), bg: const Color(0x1AFFB900), border: const Color(0x33FFB900), onTap: () => context.push(TaskEraRoutes.tasksSchedule)),
                SizedBox(width: 4),
                _Chip(
                  icon: SvgPicture.string(_goalsIconSvg, width: 10, height: 10),
                  label: AppL10n.of(context).goals,
                  textColor: colors.successFg,
                  bg: const Color(0x1A7FBA00),
                  border: const Color(0x337FBA00),
                  onTap: () => context.push(TaskEraRoutes.goals),
                ),
                SizedBox(width: 4),
                _Chip(
                  label: '📋 ${AppL10n.of(context).checklist}',
                  textColor: const Color(0xFFBF5AF2),
                  bg: const Color(0x14BF5AF2),
                  border: const Color(0x33BF5AF2),
                  onTap: () => context.push(TaskEraRoutes.tasksLists),
                ),
                SizedBox(width: 4),
                _Chip(label: '▶ ${AppL10n.of(context).timer}', textColor: const Color(0xFFFF6B35), bg: const Color(0x14FF6B35), border: const Color(0x33FF6B35), onTap: () => context.push(TaskEraRoutes.tasksPomodoro)),
                SizedBox(width: 4),
                _Chip(
                  icon: SvgPicture.string(_clockSvg, width: 10, height: 10,
                      colorFilter: const ColorFilter.mode(Color(0xFF6264A7), BlendMode.srcIn)),
                  label: AppL10n.of(context).history,
                  textColor: const Color(0xFF6264A7),
                  bg: const Color(0x146264A7),
                  border: const Color(0x336264A7),
                  onTap: () => context.push('/tasks/logs'),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color? textColor;
  final Color? bg;
  final Color? border;
  final VoidCallback? onTap;

  const _Chip({
    this.icon,
    required this.label,
    required this.textColor,
    this.bg,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc     = textColor ?? const Color(0xFF8E8E93);
    final bgCol  = bg     ?? Colors.transparent;
    final bdCol  = border ?? const Color(0x24FFFFFF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: bdCol),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: 3)],
          Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: tc, height: 1)),
        ],
      ),
      ),
    );
  }
}

// ── Quad section ──────────────────────────────────────────────────────────────

class _QuadSection extends StatelessWidget {
  final Color quadColor;
  final Color bgColor;
  final String name;
  final String quadKey;
  final Widget? aiBadge;
  final double fraction;
  final List<_Task> tasks;
  final bool isOpen;
  final VoidCallback onToggle;
  final TaskEraColors colors;

  const _QuadSection({
    required this.quadColor,
    required this.bgColor,
    required this.name,
    required this.quadKey,
    required this.aiBadge,
    required this.fraction,
    required this.tasks,
    required this.isOpen,
    required this.onToggle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Derive border from quad color at 40% opacity
    final borderColor = quadColor.withAlpha(102);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(color: quadColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 7),
                    GestureDetector(
                      onTap: () => context.push('/tasks/quad/$quadKey'),
                      child: Text(
                        name,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: quadColor, height: 1),
                      ),
                    ),
                    if (aiBadge != null) ...[SizedBox(width: 6), aiBadge!],
                    const Spacer(),
                    Text(
                      '${tasks.length}',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: colors.ink, height: 1),
                    ),
                    Text(
                      ' active',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1),
                    ),
                    SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isOpen ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF636366)),
                    ),
                  ],
                ),
              ),
            ),
            // Progress bar
            SizedBox(
              height: 2,
              child: Stack(
                children: [
                  Container(color: colors.surf3),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    alignment: Alignment.centerLeft,
                    child: Container(color: quadColor),
                  ),
                ],
              ),
            ),
            // Body
            if (isOpen)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < tasks.length; i++)
                    _TaskRow(
                      key: ValueKey(tasks[i].id),
                      task: tasks[i],
                      quadColor: quadColor,
                      colors: colors,
                      showDivider: i > 0,
                      index: i,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── AI badge in section header ─────────────────────────────────────────────────

class _HeaderBadge extends StatelessWidget {
  final String label;
  final bool isRed;
  const _HeaderBadge({required this.label, required this.isRed});

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final bg  = isRed ? const Color(0x2EF25022) : const Color(0x2E7FBA00);
    final col = isRed ? const Color(0xFFF87058) : colors.successFg;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w600, color: col, height: 1)),
    );
  }
}

// ── Long-press context menu ───────────────────────────────────────────────────

Future<void> _showTaskMenu(BuildContext ctx, WidgetRef ref, _Task task, Color quadColor, TaskEraColors colors) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: ctx,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    builder: (sheetCtx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: TaskEraSheetSurface(
          borderRadius: BorderRadius.circular(16),
          child: Container(
        decoration: BoxDecoration(
          color: colors.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Text(
                task.title,
                style: TextStyle(fontFamily: TaskEraTheme.of(ctx).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: quadColor, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(height: 0.5, color: colors.bdr),
            _ContextItem(icon: Icons.edit_outlined, label: AppL10n.of(ctx).editTask, color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push('/tasks/edittask/${task.id}'); }, colors: colors),
            _ContextItem(icon: Icons.check_circle_outline, label: AppL10n.of(ctx).completeTask, color: const Color(0xFF30D158),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, true);
                ref.logActivity('Task "${task.title}" marked as completed');
              }, colors: colors),
            _ContextItem(icon: Icons.timer_outlined, label: AppL10n.of(ctx).startPomodoro, color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push(TaskEraRoutes.tasksPomodoro); }, colors: colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Text(AppL10n.of(ctx).moveTo, style: TextStyle(fontFamily: TaskEraTheme.of(ctx).fontFamily, fontSize: 13, color: colors.ink3, height: 1)),
                  SizedBox(width: 10),
                  for (final (lbl, quad, clr) in [('Q1', 1, TaskEraColors.q1), ('Q2', 2, TaskEraColors.q2), ('Q3', 3, TaskEraColors.q3), ('Q4', 4, TaskEraColors.q4)])
                    GestureDetector(
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        ref.read(appDatabaseProvider).tasksDao
                            .updateTask(task.id, TasksCompanion(quadrant: Value(quad)));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                        decoration: BoxDecoration(
                          color: clr.withAlpha(0x1A),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 0.5, color: clr.withAlpha(0x66)),
                        ),
                        child: Text(lbl, style: TextStyle(fontFamily: TaskEraTheme.of(ctx).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: clr, height: 1)),
                      ),
                    ),
                ],
              ),
            ),
            Container(height: 0.5, color: colors.bdr),
            _ContextItem(icon: Icons.delete_outline, label: AppL10n.of(ctx).deleteTask, color: TaskEraColors.warn,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ref.read(appDatabaseProvider).tasksDao.deleteTask(task.id);
                ref.logActivity('Task "${task.title}" deleted');
              }, colors: colors),
            SizedBox(height: 8),
          ],
        ),
          ),
        ),
      ),
    ),
  );
}

class _ContextItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final TaskEraColors colors;
  const _ContextItem({required this.icon, required this.label, required this.color, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 12),
            Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: color, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ── Task row ──────────────────────────────────────────────────────────────────

class _TaskRow extends ConsumerStatefulWidget {
  final _Task task;
  final Color quadColor;
  final TaskEraColors colors;
  final bool showDivider;
  final int index;

  const _TaskRow({super.key, required this.task, required this.quadColor, required this.colors, required this.showDivider, required this.index});

  @override
  ConsumerState<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends ConsumerState<_TaskRow> with SingleTickerProviderStateMixin {
  bool _completing = false;
  late final AnimationController _ctrl;
  late final Animation<double> _fadeOut;
  late final Animation<double> _collapse;

  static const _pomoClock =
      '<svg width="7" height="7" viewBox="0 0 22 22" fill="none" stroke="#FF8080" '
      'stroke-width="1.6" stroke-linecap="round">'
      '<circle cx="11" cy="11" r="8"/><path d="M11 7v4l3 2"/></svg>';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fadeOut  = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65, curve: Curves.easeIn)));
    _collapse = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _complete() {
    if (_completing) return;
    setState(() => _completing = true);
    // Capture everything before the widget may be disposed (task moves to Completed section).
    final db        = ref.read(appDatabaseProvider);
    final taskId    = widget.task.id;
    final taskTitle = widget.task.title;
    final messenger = ScaffoldMessenger.of(context);
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    db.tasksDao.toggleDone(taskId, true);
    ref.logActivity('Task "$taskTitle" marked as completed');
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) _ctrl.forward();
    });
    messenger.clearSnackBars();
    final controller = messenger.showSnackBar(SnackBar(
      content: Text(
        '✓  $taskTitle',
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.fromLTRB(12, 0, 12, bottomPad + 50 + 8),
      duration: const Duration(milliseconds: 2000),
      action: SnackBarAction(
        label: AppL10n.of(context).undo,
        textColor: TaskEraColors.acc2,
        onPressed: () {
          db.tasksDao.toggleDone(taskId, false);
          if (mounted) {
            setState(() => _completing = false);
            _ctrl.reset();
          }
        },
      ),
    ));
    // Safety net: guarantee the toast clears after ~2s even if the row-collapse
    // animation / disposal interferes with the SnackBar's internal timer.
    Timer(const Duration(milliseconds: 2100), () {
      try { controller.close(); } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final task      = widget.task;
    final quadColor = widget.quadColor;
    final colors    = widget.colors;
    final l10n      = AppL10n.of(context);

    return SizeTransition(
      sizeFactor: _collapse,
      // ignore: deprecated_member_use
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _fadeOut,
        child: GestureDetector(
          onTap: () => context.push('/tasks/taskdetail/${task.id}'),
          onLongPress: () => _showTaskMenu(context, ref, task, quadColor, colors),
          onSecondaryTap: () => _showTaskMenu(context, ref, task, quadColor, colors),
          child: Container(
            decoration: BoxDecoration(
              border: widget.showDivider
                  ? Border(top: BorderSide(width: 0.5, color: colors.bdr))
                  : null,
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: quadColor, height: 1.3),
                      ),
                      SizedBox(height: 2),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _localizeDue(task.due, l10n),
                            style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily,
                              fontSize: 11,
                              color: task.isOverdue ? const Color(0xFFFF8080) : colors.ink3,
                              height: 1.3,
                            ),
                          ),
                          if (task.hasAi)
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                              decoration: BoxDecoration(
                                color: const Color(0x26FFB900),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text('AI', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFFFB900), height: 1.2)),
                            ),
                          if (task.recLabel != null)
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                              decoration: BoxDecoration(
                                color: const Color(0x1EFFFFFF),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(width: 0.5, color: const Color(0x24FFFFFF)),
                              ),
                              child: Text(_localizeRec(task.recLabel!, l10n), style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3, height: 1.2)),
                            ),
                          if (task.hasPomo)
                            GestureDetector(
                              onTap: () => context.push(TaskEraRoutes.tasksPomodoro),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                decoration: BoxDecoration(
                                  color: const Color(0x14FF453A),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(width: 0.5, color: const Color(0x26FF453A)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.string(_pomoClock, width: 7, height: 7),
                                    SizedBox(width: 3),
                                    Text('${task.pomoMin} min', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: Color(0xFFFF8080), height: 1.2)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (task.subs.isNotEmpty) ...[
                        SizedBox(height: 5),
                        ...task.subs.map((s) => _SubItemRow(sub: s, quadColor: quadColor, colors: colors)),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 10),
                // Dead-zone buffer: taps in the padding around the checkbox are
                // absorbed (never open task details); only the icon completes.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: GestureDetector(
                      onTap: _complete,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _completing ? quadColor : quadColor.withAlpha(0x1A),
                          shape: BoxShape.circle,
                          border: Border.all(width: 0.5, color: quadColor.withAlpha(0x99)),
                        ),
                        child: Center(
                          child: Icon(Icons.check_rounded, size: 14,
                              color: _completing ? Colors.white : quadColor.withAlpha(0x80)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubItemRow extends StatelessWidget {
  final _Sub sub;
  final Color quadColor;
  final TaskEraColors colors;
  const _SubItemRow({required this.sub, required this.quadColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: sub.isDone ? quadColor.withAlpha(0x40) : Colors.transparent,
              shape: BoxShape.circle,
              border: sub.isDone ? null : Border.all(width: 0.8, color: quadColor),
            ),
            child: sub.isDone
                ? Icon(Icons.check, size: 8, color: quadColor)
                : null,
          ),
          SizedBox(width: 5),
          Text(
            sub.title,
            style: TextStyle(
              fontFamily: TaskEraTheme.of(context).fontFamily,
              fontSize: 11,
              color: sub.isDone ? colors.ink3 : quadColor,
              decoration: sub.isDone ? TextDecoration.lineThrough : null,
              decorationColor: colors.ink3,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completed long-press menu ─────────────────────────────────────────────────

Future<void> _showCompletedMenu(BuildContext ctx, WidgetRef ref, _DoneTask task, TaskEraColors colors) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: ctx,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    builder: (sheetCtx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: TaskEraSheetSurface(
          borderRadius: BorderRadius.circular(16),
          child: Container(
        decoration: BoxDecoration(
          color: colors.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Text(task.title,
                style: TextStyle(fontFamily: TaskEraTheme.of(ctx).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: task.qColor, height: 1.3),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Container(height: 0.5, color: colors.bdr),
            _ContextItem(icon: Icons.restore_rounded, label: AppL10n.of(ctx).restoreTask, color: colors.ink,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ref.read(appDatabaseProvider).tasksDao.toggleDone(task.id, false);
                ref.logActivity('Task "${task.title}" restored from completed');
              }, colors: colors),
            Container(height: 0.5, color: colors.bdr),
            _ContextItem(icon: Icons.delete_forever_outlined, label: AppL10n.of(ctx).deletePermanently, color: TaskEraColors.warn,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                ref.read(appDatabaseProvider).tasksDao.deleteTask(task.id);
                ref.logActivity('Task "${task.title}" permanently deleted');
              }, colors: colors),
            SizedBox(height: 8),
          ],
        ),
          ),
        ),
      ),
    ),
  );
}

// ── Completed section ─────────────────────────────────────────────────────────

class _CompletedSection extends ConsumerWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final List<_DoneTask> tasks;
  final TaskEraColors colors;

  const _CompletedSection({required this.isOpen, required this.onToggle, required this.tasks, required this.colors});

  List<MapEntry<String, List<_DoneTask>>> _grouped() {
    final map = <String, List<_DoneTask>>{};
    for (final t in tasks) {
      (map[t.quad] ??= []).add(t);
    }
    return map.entries.toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                child: Row(
                  children: [
                    Icon(Icons.check_rounded, size: 18, color: Color(0xFF636366)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppL10n.of(context).done,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, height: 1),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 0.5, color: colors.bdr),
                      ),
                      child: Text('${tasks.length} ${AppL10n.of(context).tasks.toLowerCase()}', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, color: colors.ink3, height: 1)),
                    ),
                    SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isOpen ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF636366)),
                    ),
                  ],
                ),
              ),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in _grouped()) ...[
                      // Quad source label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: entry.value.first.qColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(entry.key, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
                          ],
                        ),
                      ),
                      for (final t in entry.value)
                        GestureDetector(
                          onLongPress: () => _showCompletedMenu(context, ref, t, colors),
                          child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
                          child: Row(
                              children: [
                                Container(
                                  width: 14, height: 14,
                                  decoration: BoxDecoration(color: t.qColor, shape: BoxShape.circle),
                                  child: Icon(Icons.check, size: 8, color: Colors.white),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3, decoration: TextDecoration.lineThrough, decorationColor: colors.ink3, height: 1.3)),
                                      Text(t.doneText, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ref.read(appDatabaseProvider).tasksDao.toggleDone(t.id, false);
                                    ref.logActivity('Task "${t.title}" restored from completed');
                                  },
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(width: 0.5, color: colors.bdr2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.restore_rounded, size: 15, color: colors.ink),
                                  ),
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    ref.read(appDatabaseProvider).tasksDao.deleteTask(t.id);
                                    ref.logActivity('Task "${t.title}" deleted');
                                  },
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(width: 0.5, color: colors.bdr2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFFF3B30)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: GestureDetector(
                        onTap: () => context.push(TaskEraRoutes.tasksPanelComp),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
                          ),
                          child: Text(
                            'View all completed →',
                            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: TaskEraColors.acc2, height: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Prune card ────────────────────────────────────────────────────────────────

class _PruneCard extends StatefulWidget {
  final VoidCallback onDismiss;
  final TaskEraColors colors;
  const _PruneCard({required this.onDismiss, required this.colors});

  @override
  State<_PruneCard> createState() => _PruneCardState();
}

class _PruneCardState extends State<_PruneCard> {
  final _dismissed = <int>{};

  @override
  Widget build(BuildContext context) {
    final visible = _pruneData.asMap().entries.where((e) => !_dismissed.contains(e.key)).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: const Color(0x40FF9500)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧹', style: TextStyle(fontSize: 16, height: 1.2)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${visible.length} tasks haven\'t moved in 7+ days',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: widget.colors.ink, height: 1.3),
                    ),
                    Text(
                      'Keep, move, or cut — your list, your call.',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: widget.colors.ink3, height: 1.4),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Text('×', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 18, color: widget.colors.ink3, height: 1)),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...visible.map((e) => _PruneItemRow(
            item: e.value,
            colors: widget.colors,
            onDel: () => setState(() => _dismissed.add(e.key)),
          )),
        ],
      ),
    );
  }
}

class _PruneItemRow extends StatelessWidget {
  final _PruneItem item;
  final TaskEraColors colors;
  final VoidCallback onDel;
  const _PruneItemRow({required this.item, required this.colors, required this.onDel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(item.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: colors.ink, height: 1.3)),
          ),
          SizedBox(width: 6),
          Text(item.age, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10, color: colors.ink3, height: 1)),
          SizedBox(width: 6),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.moveLabel} — coming soon'))),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              decoration: BoxDecoration(color: TaskEraColors.accBg, borderRadius: BorderRadius.circular(6)),
              child: Text(item.moveLabel, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: TaskEraColors.acc2, height: 1)),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: onDel,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              decoration: BoxDecoration(color: const Color(0x14FF453A), borderRadius: BorderRadius.circular(6)),
              child: Text(AppL10n.of(context).delete, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: TaskEraColors.warn, height: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2×2 quad card ─────────────────────────────────────────────────────────────

class _QuadCard extends StatelessWidget {
  final Color quadColor;
  final String name;
  final String quadKey;
  final int count;
  final double fraction;
  final List<_Task> tasks;
  final TaskEraColors colors;

  const _QuadCard({
    required this.quadColor,
    required this.name,
    required this.quadKey,
    required this.count,
    required this.fraction,
    required this.tasks,
    required this.colors,
  });

  static const _kFixed = 10.0 + 17.0 + 6.0 + 3.0 + 7.0 + 10.0; // pad×2 + header(fs-md=13) + gaps + bar
  static const _kRowH  = 24.0; // task row: fs-md(13)×1.3 + 6 bottom gap

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCount = constraints.maxHeight.isFinite
            ? ((constraints.maxHeight - _kFixed) / _kRowH).floor().clamp(0, tasks.length)
            : tasks.length;

        return Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5, color: quadColor.withAlpha(102)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header — taps to quad screen
              GestureDetector(
                onTap: () => context.push('/tasks/quad/$quadKey'),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: quadColor, shape: BoxShape.circle)),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(name, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: quadColor, height: 1), overflow: TextOverflow.ellipsis),
                    ),
                    Text('$count', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: quadColor, height: 1)),
                  ],
                ),
              ),
              SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: Stack(
                    children: [
                      Container(color: colors.surf3),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        alignment: Alignment.centerLeft,
                        child: Container(color: quadColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 7),
              // Task rows — each taps to task detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < maxCount && i < tasks.length; i++)
                      GestureDetector(
                        onTap: () => context.push('/tasks/taskdetail/${tasks[i].id}'),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(width: 5, height: 5, decoration: BoxDecoration(color: quadColor, shape: BoxShape.circle)),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  tasks[i].title,
                                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: quadColor, height: 1.3),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Lists section (shown in Tasks tab when toggle is on) ──────────────────────

class _ListsInTasksSection extends ConsumerWidget {
  final List<CustomList> lists;
  final TaskEraColors colors;
  const _ListsInTasksSection({required this.lists, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 0, 6),
          child: Row(children: [
            Expanded(
              child: Text(AppL10n.of(context).myChecklists,
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w600,
                      color: colors.ink3, letterSpacing: 0.5, height: 1)),
            ),
            GestureDetector(
              onTap: () => context.push(TaskEraRoutes.tasksLists),
              child: Text('${AppL10n.of(context).seeAll} ›',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: TaskEraColors.acc2, height: 1)),
            ),
          ]),
        ),
        for (final list in lists)
          _ListCardInTasks(list: list, colors: colors),
      ],
    );
  }
}

class _ListCardInTasks extends ConsumerWidget {
  final CustomList list;
  final TaskEraColors colors;
  const _ListCardInTasks({required this.list, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(listItemsProvider(list.id)).valueOrNull ?? [];
    final doneCount = items.where((i) => i.isDone).length;
    final pending = items.where((i) => !i.isDone).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row — opens the full checklist screen scrolled to this list.
          GestureDetector(
            onTap: () => context.push('${TaskEraRoutes.tasksLists}/${list.id}'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              child: Row(children: [
                Text(list.emoji, style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(list.title,
                      style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                          fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
                ),
                if (items.isNotEmpty) ...[
                  // Progress pill
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                    decoration: BoxDecoration(
                      color: doneCount == items.length
                          ? const Color(0x1F30D158)
                          : colors.surf2,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 0.5,
                        color: doneCount == items.length
                            ? const Color(0x4030D158)
                            : colors.bdr,
                      ),
                    ),
                    child: Text('$doneCount/${items.length}',
                        style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: doneCount == items.length
                                ? const Color(0xFF30D158)
                                : colors.ink3,
                            height: 1)),
                  ),
                  SizedBox(width: 6),
                ],
                Icon(Icons.chevron_right_rounded, size: 16, color: colors.ink3),
              ]),
            ),
          ),
          // Item chips — pending items only, wrapping grid
          if (items.isNotEmpty) ...[
            Container(height: 0.5, color: colors.bdr),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final item in pending)
                    _ListItemChip(item: item, colors: colors, ref: ref),
                  if (doneCount > 0)
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        color: colors.surf2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(width: 0.5, color: colors.bdr),
                      ),
                      child: Text('$doneCount ${AppL10n.of(context).done.toLowerCase()}',
                          style: TextStyle(
                              fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                              color: colors.ink3, height: 1)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ListItemChip extends StatelessWidget {
  final CustomListItem item;
  final TaskEraColors colors;
  final WidgetRef ref;
  const _ListItemChip({required this.item, required this.colors, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(appDatabaseProvider).listsDao.toggleItem(item.id, !item.isDone),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: colors.bdr2),
              ),
            ),
            SizedBox(width: 6),
            Text(item.content,
                style: TextStyle(
                    fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
                    color: colors.ink, height: 1)),
          ],
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFabChooser(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: TaskEraColors.acc,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x8C000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}

void _showFabChooser(BuildContext ctx) {
  final colors = TaskEraTheme.of(ctx).colors;
  showModalBottomSheet(
    isScrollControlled: true,
    context: ctx,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C000000),
    builder: (sheetCtx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Text(AppL10n.of(ctx).addNew, style: TextStyle(fontFamily: TaskEraTheme.of(ctx).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink, height: 1.3)),
            ),
            Container(height: 0.5, color: colors.bdr),
            _ContextItem(
              icon: Icons.check_box_outline_blank_rounded,
              label: 'Task',
              color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push(TaskEraRoutes.tasksQuickAdd); },
              colors: colors,
            ),
            _ContextItem(
              icon: Icons.repeat_rounded,
              label: 'Habit',
              color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push(TaskEraRoutes.habitsAddHabit); },
              colors: colors,
            ),
            _ContextItem(
              icon: Icons.sticky_note_2_outlined,
              label: 'Note',
              color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push(TaskEraRoutes.notesEditor); },
              colors: colors,
            ),
            _ContextItem(
              icon: Icons.checklist_rounded,
              label: 'Checklist',
              color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); ctx.push(TaskEraRoutes.tasksLists); },
              colors: colors,
            ),
            _ContextItem(
              icon: Icons.person_add_outlined,
              label: 'Invite',
              color: colors.ink,
              onTap: () { Navigator.of(sheetCtx).pop(); },
              colors: colors,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
