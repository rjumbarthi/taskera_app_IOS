import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/database.dart' show Task, TasksCompanion;
import '../../data/providers/database_provider.dart';
import '../../data/providers/tasks_provider.dart';
import '../../data/providers/time_tracker_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_sheet.dart';
import '../tasks/time_track_screen.dart' show TimeTrackContent;

// ── Data ──────────────────────────────────────────────────────────────────────

class _QTask {
  final int id;
  final String title;
  final String meta;
  final int mins;
  final Color color;
  const _QTask({
    required this.id,
    required this.title,
    required this.meta,
    required this.mins,
    required this.color,
  });
}

const _kEmptyTask = _QTask(
  id: -1,
  title: 'No tasks — add one to get started',
  meta:  '',
  mins:  25,
  color: KaalColors.acc2,
);

// ── Screen ────────────────────────────────────────────────────────────────────

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  int _mins        = 25;
  int _activeIndex = 0;
  bool _running    = false;
  bool _userPicked = false; // user manually chose a task → stop auto-selecting
  int _activeTaskId = -1;   // id of the task currently shown (for saving duration)
  int _loadedTaskId = -2;   // last task whose saved duration we loaded into _mins
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _mins * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      _mins > 0 ? 1.0 - (_secondsLeft / (_mins * 60)) : 0.0;

  void _selectTask(int i) {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _userPicked  = true;
      _activeIndex = i;
      _loadedTaskId = -2; // force build to load the new task's saved duration
      _running     = false;
    });
  }

  static List<_QTask> _buildQueue(List<Task> rawTasks) {
    const qColors = {
      1: KaalColors.q1,
      2: KaalColors.q2,
      3: KaalColors.q3,
      4: KaalColors.q4,
    };
    final sorted = rawTasks.where((t) => !t.isDone).toList()
      ..sort((a, b) {
        final cmpQ = a.quadrant.compareTo(b.quadrant);
        if (cmpQ != 0) return cmpQ;
        return (b.urgencyScore ?? 0).compareTo(a.urgencyScore ?? 0);
      });
    return sorted.map((t) => _QTask(
      id: t.id,
      title: t.title,
      meta: 'Q${t.quadrant}${t.priority != null ? " · ${t.priority}" : ""}',
      mins: t.timeAllocatedMin ?? 25, // saved custom duration per task
      color: qColors[t.quadrant] ?? KaalColors.acc2,
    )).toList();
  }

  void _onMinsChanged(int m) {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _mins        = m;
      _secondsLeft = m * 60;
      _running     = false;
    });
    // Persist the chosen duration to the active task so it sticks next time.
    if (_activeTaskId >= 0) {
      ref.read(appDatabaseProvider).tasksDao.updateTask(
            _activeTaskId,
            TasksCompanion(timeAllocatedMin: Value(m)),
          );
    }
  }

  void _startPause() {
    if (_running) {
      _timer?.cancel();
      _timer = null;
      setState(() => _running = false);
    } else {
      if (_secondsLeft == 0) _secondsLeft = _mins * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
        } else {
          _timer?.cancel();
          _timer = null;
          setState(() => _running = false);
        }
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _secondsLeft = _mins * 60;
      _running     = false;
    });
  }

  // Finish the session: mark the active task done and reset the timer.
  void _complete() {
    final hadTask = _activeTaskId >= 0;
    if (hadTask) {
      ref.read(appDatabaseProvider).tasksDao.toggleDone(_activeTaskId, true);
    }
    _reset();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(hadTask ? 'Session complete — task marked done' : 'Session complete'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final rawTasks = ref.watch(allTasksProvider).valueOrNull ?? [];
    final queue = _buildQueue(rawTasks);
    // Default the active task to the one currently being tracked (e.g. started
    // from the Focus DTN card) so the Timer opens on it — until the user picks
    // another from the queue.
    var idx = _activeIndex;
    if (!_userPicked) {
      final tracked = ref.watch(timeTrackerProvider).taskTitle;
      if (tracked != null) {
        final ti = queue.indexWhere((q) => q.title == tracked);
        if (ti >= 0) idx = ti;
      }
    }
    final safeIndex = queue.isEmpty ? 0 : idx.clamp(0, queue.length - 1);
    final activeTask = queue.isEmpty ? _kEmptyTask : queue[safeIndex];

    // When the active task changes (selection or auto-select), load its saved
    // duration so the custom timer persists per task. Skip while a timer runs.
    _activeTaskId = activeTask.id;
    if (activeTask.id >= 0 && activeTask.id != _loadedTaskId && !_running) {
      _loadedTaskId = activeTask.id;
      _mins = activeTask.mins;
      _secondsLeft = _mins * 60;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TimerSubHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActiveCard(
                  activeTask: activeTask,
                  mins: _mins,
                  colors: colors,
                  timerLabel: _timerLabel,
                  progress: _progress,
                  running: _running,
                  onMinsChanged: _onMinsChanged,
                  onStartPause: _startPause,
                  onReset: _reset,
                  onComplete: _complete,
                ),
                const SizedBox(height: 10),
                _QueueSection(
                  items: queue,
                  activeIndex: safeIndex,
                  colors: colors,
                  onSelect: _selectTask,
                ),
                // Time log embedded at the bottom of the timer screen.
                const SizedBox(height: 22),
                Text('TIME LOG',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                        letterSpacing: 0.5, color: colors.ink3, height: 1)),
                const SizedBox(height: 10),
                const TimeTrackContent(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-header ────────────────────────────────────────────────────────────────

class _TimerSubHeader extends StatelessWidget {
  const _TimerSubHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
      child: Row(
        children: [
          AddBackButton(onTap: () => context.pop()),
          const SizedBox(width: 2),
          const Text(
            'Timer',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontVariations: [FontVariation('wght', 600)],
              fontSize: 19,
              letterSpacing: -0.5,
              color: Color(0xFFF2F2F7),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active card ───────────────────────────────────────────────────────────────

class _ActiveCard extends StatelessWidget {
  final _QTask activeTask;
  final int mins;
  final KaalColors colors;
  final String timerLabel;
  final double progress;
  final bool running;
  final ValueChanged<int> onMinsChanged;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onComplete;

  const _ActiveCard({
    required this.activeTask,
    required this.mins,
    required this.colors,
    required this.timerLabel,
    required this.progress,
    required this.running,
    required this.onMinsChanged,
    required this.onStartPause,
    required this.onReset,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Task info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(Icons.access_time_outlined,
                    size: 14, color: KaalColors.acc2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Now focusing',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: colors.ink3,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeTask.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                        height: 1.3,
                      ),
                    ),
                    if (activeTask.meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        activeTask.meta,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: colors.ink3,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Timer
          Text(
            timerLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontVariations: [FontVariation('wght', 300)],
              fontSize: 58,
              color: Color(0xFFF2F2F7),
              height: 1,
            ),
          ),

          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              color: colors.surf3,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: const ColoredBox(color: KaalColors.acc),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Duration pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DurationPill(label: '15m', value: 15, selected: mins, onTap: onMinsChanged),
              const SizedBox(width: 8),
              _DurationPill(label: '25m', value: 25, selected: mins, onTap: onMinsChanged),
              const SizedBox(width: 8),
              _DurationPill(label: '45m', value: 45, selected: mins, onTap: onMinsChanged),
              const SizedBox(width: 8),
              _CustomDurationPill(selected: mins, onTap: onMinsChanged),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onStartPause,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: running ? const Color(0xFF636366) : KaalColors.acc,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      running ? 'PAUSE' : 'START FOCUS',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _IconCircleBtn(icon: Icons.check_rounded, color: colors.successFg, onTap: onComplete),
              const SizedBox(width: 6),
              _IconCircleBtn(icon: Icons.close_rounded, color: KaalColors.warn, onTap: onReset),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Duration pill ─────────────────────────────────────────────────────────────

class _DurationPill extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final ValueChanged<int> onTap;
  const _DurationPill({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  bool get _active => value == selected;

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: _active ? KaalColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 0.5,
            color: _active
                ? const Color(0x330A84FF)
                : colors.bdr,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _active ? KaalColors.acc2 : colors.ink3,
          ),
        ),
      ),
    );
  }
}

// ── Custom duration pill ──────────────────────────────────────────────────────

class _CustomDurationPill extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _CustomDurationPill({required this.selected, required this.onTap});

  static const _presets = {15, 25, 45};
  bool get _active => !_presets.contains(selected);

  String get _label => _active ? '${selected}m' : 'Custom';

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: const Color(0x8C000000),
          isScrollControlled: true,
          builder: (_) => _CustomDurationSheet(initial: _active ? selected : 30),
        );
        if (result != null) onTap(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _active ? KaalColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 0.5,
            color: _active ? const Color(0x330A84FF) : colors.bdr,
          ),
        ),
        child: Text(
          _label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _active ? KaalColors.acc2 : colors.ink3,
          ),
        ),
      ),
    );
  }
}

// ── Custom duration bottom sheet ──────────────────────────────────────────────

class _CustomDurationSheet extends StatefulWidget {
  final int initial;
  const _CustomDurationSheet({required this.initial});

  @override
  State<_CustomDurationSheet> createState() => _CustomDurationSheetState();
}

class _CustomDurationSheetState extends State<_CustomDurationSheet> {
  late int _value;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
    _ctrl = TextEditingController(text: '$_value');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dec() {
    if (_value > 5) {
      setState(() { _value -= 5; _ctrl.text = '$_value'; });
    }
  }

  void _inc() {
    if (_value < 180) {
      setState(() { _value += 5; _ctrl.text = '$_value'; });
    }
  }

  void _onTextChanged(String v) {
    final parsed = int.tryParse(v);
    if (parsed != null) {
      setState(() => _value = parsed.clamp(1, 180));
    }
  }

  void _set() {
    final parsed = int.tryParse(_ctrl.text);
    final finalVal = (parsed ?? _value).clamp(1, 180);
    Navigator.of(context).pop(finalVal);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: KaalSheetSurface(
        borderRadius: BorderRadius.circular(20),
        child: Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + safeBottom),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: colors.bdr2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'CUSTOM DURATION',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: colors.ink3,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          // Stepper + editable value
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepBtn(icon: Icons.remove_rounded, onTap: _dec, enabled: _value > 5),
              const SizedBox(width: 16),
              IntrinsicWidth(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: _onTextChanged,
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontVariations: [FontVariation('wght', 300)],
                    fontSize: 52,
                    color: Color(0xFFF2F2F7),
                    height: 1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                ' min',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: colors.ink3,
                ),
              ),
              const SizedBox(width: 16),
              _StepBtn(icon: Icons.add_rounded, onTap: _inc, enabled: _value < 180),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '1 – 180 min',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: colors.ink3,
              height: 1,
            ),
          ),
          const SizedBox(height: 24),
          // Set button
          GestureDetector(
            onTap: _set,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: KaalColors.acc,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Set Duration',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _StepBtn({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 0.5,
            color: enabled ? colors.bdr2 : colors.bdr,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.ink : colors.ink3,
        ),
      ),
    );
  }
}

// ── Icon circle button ────────────────────────────────────────────────────────

class _IconCircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _IconCircleBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: color.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ── Queue section ─────────────────────────────────────────────────────────────

class _QueueSection extends StatelessWidget {
  final List<_QTask> items;
  final int activeIndex;
  final KaalColors colors;
  final ValueChanged<int> onSelect;
  const _QueueSection({
    required this.items,
    required this.activeIndex,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Queue',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length} tasks',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.ink3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Rows
        ...items.asMap().entries.map((e) {
          final i    = e.key;
          final task = e.value;
          return Column(
            children: [
              _QueueRow(
                task: task,
                isActive: i == activeIndex,
                colors: colors,
                onTap: () => onSelect(i),
              ),
              if (i < items.length - 1)
                Divider(height: 1, thickness: 0.5, color: colors.bdr),
            ],
          );
        }),

        const SizedBox(height: 12),
        Text(
          'Ready for deep focus.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: colors.ink3,
          ),
        ),
      ],
    );
  }
}

// ── Queue row ─────────────────────────────────────────────────────────────────

class _QueueRow extends StatelessWidget {
  final _QTask task;
  final bool isActive;
  final KaalColors colors;
  final VoidCallback onTap;
  const _QueueRow({
    required this.task,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Dot
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: task.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive ? task.color : colors.ink,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    task.meta,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: colors.ink3,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Duration pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? KaalColors.accBg : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 0.5,
                  color: isActive
                      ? const Color(0x330A84FF)
                      : colors.bdr,
                ),
              ),
              child: Text(
                '${task.mins}m',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? task.color : colors.ink3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
