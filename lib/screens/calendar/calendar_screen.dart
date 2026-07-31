import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart' show CalendarEvent;
import '../../data/providers/calendar_provider.dart';
import '../../data/providers/conflicts_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../widgets/reminders_section.dart';
import '../../services/sync_service.dart';
import '../../data/providers/database_provider.dart';
import '../../services/notification_service.dart';
import '../../routing/routes.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/kaal_sheet.dart';
import '../../services/activity_log_service.dart';
import '../../l10n/app_l10n.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Event {
  const _Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isOverdue = false,
    this.isInvite  = false,
  });
  final int    id;
  final String title;
  final String subtitle;
  final Color  color;
  final bool   isOverdue;
  final bool   isInvite;
}

class _Slot {
  const _Slot({required this.time, required this.events});
  final String       time;
  final List<_Event> events;
}


const _monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late int  _year;
  late int  _month;
  bool _monthView = true;
  late int  _selected;

  Timer? _autoSync;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year     = now.year;
    _month    = now.month;
    _selected = now.day;
    // While the calendar is open, auto-sync every 5 minutes.
    _autoSync = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) _refresh();
    });
  }

  @override
  void dispose() {
    _autoSync?.cancel();
    super.dispose();
  }

  Future<void> _refresh() => ref.read(syncServiceProvider).syncAll();

  void _prev() => setState(() {
    if (!_monthView) {
      final dt = DateTime(_year, _month, _selected).subtract(const Duration(days: 7));
      _year = dt.year; _month = dt.month; _selected = dt.day;
    } else {
      if (_month == 1) { _month = 12; _year--; } else { _month--; }
    }
  });

  void _next() => setState(() {
    if (!_monthView) {
      final dt = DateTime(_year, _month, _selected).add(const Duration(days: 7));
      _year = dt.year; _month = dt.month; _selected = dt.day;
    } else {
      if (_month == 12) { _month = 1; _year++; } else { _month++; }
    }
  });

  void _today() {
    final now = DateTime.now();
    setState(() { _year = now.year; _month = now.month; _selected = now.day; });
  }

  int get _todayDay {
    final now = DateTime.now();
    return (_year == now.year && _month == now.month) ? now.day : -1;
  }

  // Compute per-day dot map from real events for the current month.
  Map<int, List<Color>> _computeDots(List<CalendarEvent> events) {
    final map = <int, List<Color>>{};
    for (final e in events) {
      final d = e.eventDate;
      if (d == null || d.year != _year || d.month != _month) continue;
      map.putIfAbsent(d.day, () => []);
      final c = Color(e.colorValue);
      if (!map[d.day]!.contains(c)) map[d.day]!.add(c);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final allEvents = ref.watch(calendarEventsProvider).valueOrNull ?? [];
    final dots = _computeDots(allEvents);
    final selectedDate = DateTime(_year, _month, _selected);
    final dayEvents = ref.watch(calendarEventsForDayProvider(selectedDate));

    // Live scheduling-conflict count (tasks + events), shared with the
    // conflicts screen so the chip and the screen always agree.
    final conflictCount = ref.watch(conflictsProvider).length;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MonthNav(
              year: _year, month: _month, monthView: _monthView,
              colors: colors,
              onPrev: _prev, onNext: _next, onToday: _today,
              onToggle: (v) => setState(() => _monthView = v),
              onConnections: () => context.push(KaalRoutes.calSync),
            ),
            _WeekdayRow(colors: colors),
            if (_monthView)
              _CalGrid(
                year: _year, month: _month,
                todayDay: _todayDay, selected: _selected,
                dots: dots,
                colors: colors,
                onTap: (d) => setState(() => _selected = d),
              )
            else
              _WeekStrip(
                selected: selectedDate,
                today: DateTime.now(),
                allEvents: allEvents,
                colors: colors,
                onTap: (dt) => setState(() {
                  _year = dt.year; _month = dt.month; _selected = dt.day;
                }),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: KaalColors.acc2,
                backgroundColor: const Color(0xFF1C1C1E),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 16),
                  children: [
                    _WeekInsightBanner(colors: colors),
                    const SizedBox(height: 7),
                    _DayCard(
                      colors: colors,
                      selectedDate: selectedDate,
                      events: dayEvents,
                      conflictCount: conflictCount,
                    ),
                    const SizedBox(height: 11),
                    RemindersSection(colors: colors),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
          child: GestureDetector(
            onTap: () => context.push(KaalRoutes.calAddSlot),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: KaalColors.acc,
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

// ── Month nav row ─────────────────────────────────────────────────────────────

class _MonthNav extends StatelessWidget {
  final int year;
  final int month;
  final bool monthView;
  final KaalColors colors;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onConnections;
  final ValueChanged<bool> onToggle;

  const _MonthNav({
    required this.year, required this.month, required this.monthView,
    required this.colors, required this.onPrev, required this.onNext,
    required this.onToday, required this.onConnections, required this.onToggle,
  });

  static const _chevL = '<svg width="8" height="8" viewBox="0 0 22 22" fill="none" '
      'stroke="white" stroke-width="2" stroke-linecap="round"><path d="M15 18l-6-6 6-6"/></svg>';
  static const _chevR = '<svg width="8" height="8" viewBox="0 0 22 22" fill="none" '
      'stroke="white" stroke-width="2" stroke-linecap="round"><path d="M7 4l6 6-6 6"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          _NavCircle(svg: _chevL, colors: colors, onTap: onPrev),
          const SizedBox(width: 5),
          SizedBox(
            width: 90,
            child: Text(
              '${_monthNames[month]} $year',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink, height: 1),
            ),
          ),
          const SizedBox(width: 5),
          _NavCircle(svg: _chevR, colors: colors, onTap: onNext),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onToday,
            child: Container(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
              decoration: BoxDecoration(
                color: KaalColors.accBg,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
              ),
              child: Text(AppL10n.of(context).today,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: KaalColors.acc2, height: 1)),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onConnections,
            child: Container(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 0.5, color: colors.bdr),
              ),
              child: Text(AppL10n.of(context).connections, style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(width: 0.5, color: colors.bdr),
            ),
            child: Row(
              children: [
                _ViewBtn(label: 'Month', active: monthView,  colors: colors, onTap: () => onToggle(true)),
                const SizedBox(width: 1),
                _ViewBtn(label: 'Week',  active: !monthView, colors: colors, onTap: () => onToggle(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCircle extends StatelessWidget {
  final String svg;
  final KaalColors colors;
  final VoidCallback onTap;
  const _NavCircle({required this.svg, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent, border: Border.all(width: 0.5, color: colors.bdr)),
        child: Center(child: SvgPicture.string(svg, width: 8, height: 8,
            colorFilter: ColorFilter.mode(colors.ink2, BlendMode.srcIn))),
      ),
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final String label;
  final bool active;
  final KaalColors colors;
  final VoidCallback onTap;
  const _ViewBtn({required this.label, required this.active, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
        decoration: BoxDecoration(
          color: active ? KaalColors.acc : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600,
          color: active ? Colors.white : colors.ink3, height: 1,
        )),
      ),
    );
  }
}

// ── Weekday headers ───────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  final KaalColors colors;
  const _WeekdayRow({required this.colors});

  static const _labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 3),
      child: Row(
        children: [
          for (final d in _labels)
            Expanded(child: Text(d, textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1))),
        ],
      ),
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final DateTime today;
  final List<CalendarEvent> allEvents;
  final KaalColors colors;
  final ValueChanged<DateTime> onTap;

  const _WeekStrip({
    required this.selected, required this.today,
    required this.allEvents, required this.colors, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final offset = selected.weekday % 7; // Sun=0, Mon=1 … Sat=6
    final sunday = selected.subtract(Duration(days: offset));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Row(
        children: List.generate(7, (i) {
          final day        = sunday.add(Duration(days: i));
          final isToday    = day.year == today.year && day.month == today.month && day.day == today.day;
          final isSelected = day.year == selected.year && day.month == selected.month && day.day == selected.day;
          final dayDots    = allEvents.where((e) {
            final d = e.eventDate;
            return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
          }).map((e) => Color(e.colorValue)).toSet().take(3).toList();

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(day),
              child: SizedBox(
                height: 28,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? KaalColors.acc : (isSelected ? colors.surf3 : Colors.transparent),
                      ),
                      child: Center(
                        child: Text('${day.day}', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isToday ? Colors.white : colors.ink,
                          height: 1,
                        )),
                      ),
                    ),
                    if (dayDots.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int j = 0; j < dayDots.length; j++) ...[
                              Container(width: 3, height: 3, decoration: BoxDecoration(color: dayDots[j], shape: BoxShape.circle)),
                              if (j < dayDots.length - 1) const SizedBox(width: 1),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalGrid extends StatelessWidget {
  final int year;
  final int month;
  final int todayDay;
  final int selected;
  final Map<int, List<Color>> dots;
  final KaalColors colors;
  final ValueChanged<int> onTap;

  const _CalGrid({
    required this.year, required this.month, required this.todayDay,
    required this.selected, required this.dots, required this.colors, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon..7=Sun
    final offset       = firstWeekday % 7;                 // Sun=0,Mon=1..Sat=6
    final daysInMonth  = DateUtils.getDaysInMonth(year, month);
    final totalCells   = offset + daysInMonth;
    final rows         = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Column(
        children: [
          for (int r = 0; r < rows; r++)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  for (int c = 0; c < 7; c++)
                    Expanded(child: _DayCell(
                      day: r * 7 + c - offset + 1,
                      daysInMonth: daysInMonth,
                      isToday: (r * 7 + c - offset + 1) == todayDay,
                      isSelected: (r * 7 + c - offset + 1) == selected,
                      dots: dots[r * 7 + c - offset + 1] ?? [],
                      colors: colors,
                      onTap: onTap,
                    )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int daysInMonth;
  final bool isToday;
  final bool isSelected;
  final List<Color> dots;
  final KaalColors colors;
  final ValueChanged<int> onTap;

  const _DayCell({
    required this.day, required this.daysInMonth, required this.isToday,
    required this.isSelected, required this.dots, required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 28);

    return GestureDetector(
      onTap: () => onTap(day),
      child: SizedBox(
        height: 28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? KaalColors.acc : (isSelected ? colors.surf3 : Colors.transparent),
              ),
              child: Center(
                child: Text('$day', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday ? Colors.white : colors.ink,
                  height: 1,
                )),
              ),
            ),
            if (dots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < dots.length.clamp(0, 3); i++) ...[
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: dots[i], shape: BoxShape.circle)),
                      if (i < dots.length - 1) const SizedBox(width: 1),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Week insight banner (on-device: conflicts + busy-day heuristics; no AI) ────

class _WeekInsightBanner extends ConsumerStatefulWidget {
  final KaalColors colors;
  const _WeekInsightBanner({required this.colors});

  @override
  ConsumerState<_WeekInsightBanner> createState() => _WeekInsightBannerState();
}

class _WeekInsightBannerState extends ConsumerState<_WeekInsightBanner> {
  bool _dismissed = false;

  static const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return _wd[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final colors = widget.colors;

    final conflicts = ref.watch(conflictsProvider);
    final tasks = ref.watch(allTasksProvider).value ?? [];
    final events = ref.watch(calendarEventsProvider).value ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Derive a real "this week" insight. Conflicts take priority, then the
    // busiest upcoming day; if the week is quiet, the banner hides itself.
    List<InlineSpan>? spans;
    var showMove = false;

    if (conflicts.isNotEmpty) {
      final c = conflicts.first;
      showMove = true;
      spans = [
        TextSpan(
            text:
                '${conflicts.length} scheduling conflict${conflicts.length == 1 ? '' : 's'} this week — '),
        TextSpan(text: c.a.title, style: const TextStyle(color: KaalColors.acc2)),
        const TextSpan(text: ' clashes with '),
        TextSpan(text: c.b.title, style: const TextStyle(color: KaalColors.acc2)),
        const TextSpan(text: '. '),
        TextSpan(
            text: c.overlap ? 'Move one to resolve.' : 'Add a buffer between them.',
            style: TextStyle(color: colors.ink3)),
      ];
    } else {
      var bestLoad = 0, bestTasks = 0, bestEvents = 0;
      DateTime? bestDay;
      for (var d = 0; d < 7; d++) {
        final day = today.add(Duration(days: d));
        final tCount = tasks
            .where((t) =>
                !t.isDone &&
                t.dueDate != null &&
                t.dueDate!.year == day.year &&
                t.dueDate!.month == day.month &&
                t.dueDate!.day == day.day)
            .length;
        final eCount = events.where((e) {
          final ed = e.eventDate ?? today;
          return ed.year == day.year && ed.month == day.month && ed.day == day.day;
        }).length;
        final load = tCount + eCount;
        if (load > bestLoad) {
          bestLoad = load;
          bestDay = day;
          bestTasks = tCount;
          bestEvents = eCount;
        }
      }
      if (bestDay != null && bestLoad >= 3) {
        final parts = <String>[
          if (bestTasks > 0) '$bestTasks task${bestTasks == 1 ? '' : 's'}',
          if (bestEvents > 0) '$bestEvents event${bestEvents == 1 ? '' : 's'}',
        ];
        spans = [
          TextSpan(text: '${_dayLabel(bestDay)} looks busy — '),
          TextSpan(text: parts.join(' + '), style: TextStyle(color: colors.ink2)),
          const TextSpan(text: '. Consider shifting a Q2 task to a lighter day.'),
        ];
      }
    }

    if (spans == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Container(
        padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
        decoration: BoxDecoration(
          color: const Color(0x120A84FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2)]),
                  ),
                ),
                const SizedBox(width: 5),
                const Text('This week', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                  color: KaalColors.acc2, letterSpacing: 0.3, height: 1,
                )),
              ],
            ),
            const SizedBox(height: 4),
            RichText(text: TextSpan(
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
              children: spans,
            )),
            const SizedBox(height: 7),
            Row(
              children: [
                if (showMove) ...[
                  GestureDetector(
                    onTap: () => context.push(KaalRoutes.calConflicts),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                      decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(6)),
                      child: Text(AppL10n.of(context).moveIt, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                GestureDetector(
                  onTap: () => setState(() => _dismissed = true),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(width: 0.5, color: colors.bdr)),
                    child: Text(AppL10n.of(context).dismiss, style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── DB → display model mapping ─────────────────────────────────────────────

List<_Slot> _rowsToSlots(List<CalendarEvent> rows) {
  final order = <String, int>{};
  final map = <String, List<_Event>>{};
  for (final r in rows) {
    map.putIfAbsent(r.timeSlot, () {
      order[r.timeSlot] = order.length;
      return [];
    });
    map[r.timeSlot]!.add(_Event(
      id: r.id,
      title: r.title,
      subtitle: r.subtitle,
      color: Color(r.colorValue),
      isOverdue: r.isOverdue,
      isInvite: r.isInvite,
    ));
  }
  final keys = map.keys.toList()
    ..sort((a, b) => (order[a] ?? 0).compareTo(order[b] ?? 0));
  return keys.map((k) => _Slot(time: k, events: map[k]!)).toList();
}

// ── Day detail card ───────────────────────────────────────────────────────────

class _DayCard extends ConsumerWidget {
  final KaalColors colors;
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final int conflictCount;

  const _DayCard({
    required this.colors,
    required this.selectedDate,
    required this.events,
    required this.conflictCount,
  });

  static const _weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  static const _months   = ['','January','February','March','April','May','June',
                             'July','August','September','October','November','December'];

  String get _formattedDate =>
      '${_weekdays[selectedDate.weekday - 1]}, ${_months[selectedDate.month]} ${selectedDate.day}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = _rowsToSlots(events);
    final totalEvents = slots.fold(0, (s, sl) => s + sl.events.length);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 7),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
                        const SizedBox(height: 1),
                        Text(
                          totalEvents == 0 ? 'No events' : '$totalEvents event${totalEvents == 1 ? '' : 's'}',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1)),
                      ],
                    ),
                  ),
                  if (conflictCount > 0)
                    GestureDetector(
                      onTap: () => context.push(KaalRoutes.calConflicts),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFF453A),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 0.5, color: const Color(0x40FF453A)),
                        ),
                        child: Text('⚠ $conflictCount conflict${conflictCount == 1 ? '' : 's'}',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFFF8080), height: 1)),
                      ),
                    ),
                ],
              ),
            ),
            Container(height: 0.5, color: colors.bdr),
            if (slots.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                child: Text(AppL10n.of(context).nothingScheduled, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3, height: 1)),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  children: [
                    for (int i = 0; i < slots.length; i++)
                      _SlotRow(slot: slots[i], isLast: i == slots.length - 1, colors: colors),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Reminders & Alarms card (entry to the reminders subscreen) ────────────────

class _SlotRow extends StatelessWidget {
  final _Slot slot;
  final bool isLast;
  final KaalColors colors;
  const _SlotRow({required this.slot, required this.isLast, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: isLast ? null : BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: colors.bdr))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(slot.time, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < slot.events.length; i++) ...[
                  _EventBlock(event: slot.events[i], colors: colors),
                  if (i < slot.events.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventBlock extends ConsumerWidget {
  final _Event event;
  final KaalColors colors;
  const _EventBlock({required this.event, required this.colors});

  void _showDetail(BuildContext ctx, WidgetRef ref) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C000000),
      builder: (sheetCtx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: KaalSheetSurface(
            borderRadius: BorderRadius.circular(16),
            child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.5, color: colors.bdr),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(width: 3, height: 32, decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink, height: 1.2)),
                        if (event.subtitle.isNotEmpty)
                          Text(event.subtitle, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  ctx.push('/cal/addslot/${event.id}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x120A84FF),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                  ),
                  alignment: Alignment.center,
                  child: Text(AppL10n.of(ctx).editEvent, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0A84FF))),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  ref.read(appDatabaseProvider).calendarDao.deleteEvent(event.id);
                  ref.logActivity('Calendar event "${event.title}" deleted', type: 'calendar');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(width: 0.5, color: const Color(0x40FF453A)),
                  ),
                  alignment: Alignment.center,
                  child: Text(AppL10n.of(ctx).deleteEvent, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF8080))),
                ),
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showDetail(context, ref),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              // No colored edge line on any event (events or invites).
              padding: const EdgeInsets.fromLTRB(2, 4, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
                  if (event.isOverdue) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
                      decoration: BoxDecoration(color: const Color(0x1AFF453A), borderRadius: BorderRadius.circular(3)),
                      child: const Text('Q1 · Overdue', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: Color(0xFFFF8080), height: 1)),
                    ),
                  ] else if (event.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    event.isInvite
                        ? RichText(text: TextSpan(
                            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1),
                            children: [
                              TextSpan(text: '${event.subtitle} · '),
                              const TextSpan(text: 'Invite', style: TextStyle(color: KaalColors.q4)),
                            ],
                          ))
                        : Text(event.subtitle,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.ink3, height: 1)),
                  ],
                ],
              ),
            ),
          ),
          if (event.isInvite) ...[
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _InviteBtn(
                  label: 'Accept',
                  bg: const Color(0x267FBA00), border: const Color(0x4D7FBA00), textColor: colors.successFg,
                  onTap: () async {
                    final dao = ref.read(appDatabaseProvider).calendarDao;
                    await dao.acceptInvite(event.id);
                    ref.logActivity('Calendar invite "${event.title}" accepted', type: 'calendar');
                    // Schedule pre (15-min) + at-start notifications for the event.
                    final ev = await dao.getEvent(event.id);
                    if (ev != null) {
                      // Write the accepted state through to the server now, so a
                      // background sync can't revert the invite to pending.
                      await ref.read(syncServiceProvider).pushCalendarEvent(ev);
                      final svc = ref.read(notificationServiceProvider);
                      await svc.scheduleCalendarReminder(ev);
                      await svc.scheduleEventStart(ev);
                    }
                  },
                ),
                const SizedBox(height: 4),
                _InviteBtn(
                  label: 'Decline',
                  bg: Colors.transparent, border: colors.bdr, textColor: colors.ink3,
                  onTap: () async {
                    final id = event.id;
                    await ref.read(appDatabaseProvider).calendarDao.deleteEvent(id);
                    // Delete on the server too, or the next pull re-adds it.
                    await ref.read(syncServiceProvider).deleteCalendarEventRemote(id);
                    ref.logActivity('Calendar invite "${event.title}" declined', type: 'calendar');
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;
  const _InviteBtn({required this.label, required this.bg, required this.border, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 0.5, color: border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: textColor, height: 1)),
      ),
    );
  }
}
