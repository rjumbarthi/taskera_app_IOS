import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart' show CalendarEventsCompanion;
import '../../data/providers/database_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../util/taskera_dialogs.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';

class AddSlotScreen extends ConsumerStatefulWidget {
  final String? eventId;
  const AddSlotScreen({super.key, this.eventId});

  @override
  ConsumerState<AddSlotScreen> createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends ConsumerState<AddSlotScreen> {
  int _periodIdx = 1;
  int _repeatIdx = 0;
  final Set<int> _selLabels = {1};

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime   _date     = DateTime.now();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool get _isEdit => widget.eventId != null && widget.eventId!.isNotEmpty;
  int? get _id     => int.tryParse(widget.eventId ?? '');

  static const _periods  = ['Morning', 'Afternoon', 'Evening', 'Night'];
  static const _repeats  = ['Today only', 'Daily', 'Every 2 days', 'Weekdays', 'Weekly'];
  static const _labels   = ['#work', '#gym', '#personal', '+ New'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvent());
  }

  Future<void> _loadEvent() async {
    final id = _id;
    if (id == null) return;
    final event = await ref.read(appDatabaseProvider).calendarDao.getEvent(id);
    if (event == null || !mounted) return;
    setState(() {
      _titleCtrl.text = event.title;
      _notesCtrl.text = event.subtitle;
      _date           = event.eventDate ?? DateTime.now();
      _startTime      = _parseTime(event.timeSlot);
    });
  }

  TimeOfDay? _parseTime(String slot) {
    final m = RegExp(r'^(\d+):(\d+)\s*(AM|PM)$', caseSensitive: false).firstMatch(slot.trim());
    if (m == null) return null;
    int hour = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final isPm = m.group(3)!.toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: min);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 14, minute: 0))
          : (_endTime   ?? const TimeOfDay(hour: 16, minute: 0)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: TaskEraColors.acc, onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { if (isStart) {
      _startTime = picked;
    } else {
      _endTime = picked;
    } });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: TaskEraColors.acc, onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final title    = _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : _periods[_periodIdx];
    final timeSlot = _startTime != null ? _fmt(_startTime!) : _periods[_periodIdx];
    final dao      = ref.read(appDatabaseProvider).calendarDao;
    final companion = CalendarEventsCompanion(
      title:      Value(title),
      subtitle:   Value(_notesCtrl.text.trim()),
      timeSlot:   Value(timeSlot),
      colorValue: const Value(0xFF0A84FF),
      eventDate:  Value(_date),
    );
    if (_isEdit) {
      await dao.updateEvent(_id!, companion);
    } else {
      await dao.insertEvent(companion);
    }
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await taskeraConfirmDelete(context);
    if (confirmed && mounted) {
      await ref.read(appDatabaseProvider).calendarDao.deleteEvent(_id!);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final dateStr = '${_date.year}-${_date.month.toString().padLeft(2,'0')}-${_date.day.toString().padLeft(2,'0')}';
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
                child: Text(_isEdit ? 'Edit time block' : 'Add time block', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
              ),
              GestureDetector(
                onTap: _save,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text(AppL10n.of(context).save, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Title
              _FormRow(label: 'Title', colors: colors, child: TextField(
                controller: _titleCtrl,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
                decoration: InputDecoration(
                  hintText: 'e.g. Deep work session',
                  hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                  filled: false,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(width: 0.5, color: TaskEraColors.acc)),
                  contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 9), isDense: true,
                ),
              )),
              // Period
              _FormRow(label: 'Period', colors: colors, child: Wrap(
                spacing: 5, runSpacing: 5,
                children: [for (int i = 0; i < _periods.length; i++)
                  _Chip(label: _periods[i], selected: _periodIdx == i, colors: colors,
                    onTap: () => setState(() => _periodIdx = i))],
              )),
              // Start time
              _FormRow(label: 'Start time', colors: colors, child: GestureDetector(
                onTap: () => _pickTime(isStart: true),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: colors.bdr)),
                  child: Text(_startTime != null ? _fmt(_startTime!) : 'Tap to set', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: _startTime != null ? colors.ink : colors.ink3)),
                ),
              )),
              // End time
              _FormRow(label: 'End time', colors: colors, child: GestureDetector(
                onTap: () => _pickTime(isStart: false),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: colors.bdr)),
                  child: Text(_endTime != null ? _fmt(_endTime!) : 'Tap to set', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: _endTime != null ? colors.ink : colors.ink3)),
                ),
              )),
              // Date
              _FormRow(label: 'Date', colors: colors, child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 0.5, color: colors.bdr)),
                  child: Text(dateStr, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink)),
                ),
              )),
              // Repeat block
              _FormRow(label: 'Repeat block', colors: colors, child: Wrap(
                spacing: 5, runSpacing: 5,
                children: [for (int i = 0; i < _repeats.length; i++)
                  _Chip(label: _repeats[i], selected: _repeatIdx == i, colors: colors,
                    onTap: () => setState(() => _repeatIdx = i))],
              )),
              // Labels
              _FormRow(label: 'Labels', colors: colors, child: Wrap(
                spacing: 5, runSpacing: 5,
                children: [for (int i = 0; i < _labels.length; i++)
                  _Chip(label: _labels[i], selected: _selLabels.contains(i), colors: colors,
                    onTap: () => setState(() {
                      if (i == _labels.length - 1) return;
                      if (_selLabels.contains(i)) {
                        _selLabels.remove(i);
                      } else {
                        _selLabels.add(i);
                      }
                    }))],
              )),
              // Notes
              _FormRow(label: 'Notes', colors: colors, child: TextField(
                controller: _notesCtrl,
                minLines: 2,
                maxLines: 4,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink),
                decoration: InputDecoration(
                  hintText: 'e.g. Prepare 3 talking points',
                  hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                  filled: false,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.5, color: colors.bdr)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(width: 0.5, color: TaskEraColors.acc)),
                  contentPadding: const EdgeInsets.fromLTRB(10, 9, 10, 9), isDense: true,
                ),
              )),
              if (_isEdit) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _delete,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x12FF453A),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(width: 0.5, color: const Color(0x33FF453A)),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppL10n.of(context).deleteEvent, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFF453A), height: 1)),
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
        child: Text(label, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w500,
          color: selected ? Colors.white : colors.ink2, height: 1)),
      ),
    );
  }
}
