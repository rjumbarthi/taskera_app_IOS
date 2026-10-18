import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart' show Task;
import '../../data/providers/database_provider.dart';
import '../../data/repositories/focus_session_repository.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/taskera_sheet.dart';

// Immutable quadrant colors + suggested default focus durations (minutes).
const _kQuadColor = {1: TaskEraColors.q1, 2: TaskEraColors.q2, 3: TaskEraColors.q3, 4: TaskEraColors.q4};
const _kQuadMins  = {1: 25, 2: 50, 3: 15, 4: 15};

/// Launches the task-linked focus session as a modal (not a route).
Future<void> showFocusSession(BuildContext context, {required int taskId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB3000000),
    builder: (_) => _FocusSessionModal(taskId: taskId),
  );
}

class _FocusSessionModal extends ConsumerStatefulWidget {
  final int taskId;
  const _FocusSessionModal({required this.taskId});

  @override
  ConsumerState<_FocusSessionModal> createState() => _FocusSessionModalState();
}

class _FocusSessionModalState extends ConsumerState<_FocusSessionModal> {
  Task? _task;
  int _mins = 25;
  late int _secondsLeft = _mins * 60;
  bool _running = false;
  bool _done = false;
  DateTime? _startedAt;
  bool _logged = false;
  Timer? _timer;
  late final FocusSessionRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(focusSessionRepositoryProvider);
    _load();
  }

  Future<void> _load() async {
    final t = await ref.read(appDatabaseProvider).tasksDao.getTask(widget.taskId);
    if (!mounted || t == null) return;
    setState(() {
      _task = t;
      _mins = _kQuadMins[t.quadrant] ?? 25;
      _secondsLeft = _mins * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Persist an in-progress session if the sheet is dismissed mid-focus.
    _logSession();
    super.dispose();
  }

  int get _elapsed => (_mins * 60 - _secondsLeft).clamp(0, _mins * 60);

  void _logSession() {
    if (_logged || _task == null || _startedAt == null || _elapsed <= 0) return;
    _logged = true;
    _repo.logSession(FocusSessionRecord(
      taskId:          _task!.id,
      quadrant:        _task!.quadrant,
      startedAt:       _startedAt!,
      durationSeconds: _elapsed,
      completed:       _secondsLeft <= 0,
    ));
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress => _mins > 0 ? 1.0 - (_secondsLeft / (_mins * 60)) : 0.0;

  void _setMins(int m) {
    _timer?.cancel();
    setState(() {
      _mins = m;
      _secondsLeft = m * 60;
      _running = false;
    });
  }

  void _startPause() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    _startedAt ??= DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() { _secondsLeft = 0; _running = false; _done = true; });
        _logSession();
      }
    });
    setState(() => _running = true);
  }

  void _end() {
    _timer?.cancel();
    _logSession();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = TaskEraTheme.of(context).colors;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final task      = _task;
    final quad      = task?.quadrant ?? 2;
    final qColor    = _kQuadColor[quad] ?? TaskEraColors.acc2;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: TaskEraSheetSurface(
        borderRadius: BorderRadius.circular(22),
        child: Container(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 16 + safeBottom),
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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colors.bdr2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: 16),

          // ── Task context — visible throughout the session ──────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: qColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.5, color: qColor.withValues(alpha: 0.33)),
            ),
            child: Row(
              children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: qColor, shape: BoxShape.circle)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task?.title ?? 'Loading…',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                            fontWeight: FontWeight.w600, color: colors.ink, height: 1.25),
                      ),
                      SizedBox(height: 2),
                      Text('Q$quad · Now focusing',
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11,
                              fontWeight: FontWeight.w600, color: qColor, height: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22),

          // ── Timer ──────────────────────────────────────────────────────────
          Text(
            _timerLabel,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).type.numberFontFamily,
                fontVariations: const [FontVariation('wght', 300)],
                fontSize: 64, color: colors.ink, height: 1),
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3, color: colors.surf3,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress.clamp(0.0, 1.0),
                child: ColoredBox(color: qColor),
              ),
            ),
          ),
          SizedBox(height: 18),

          // ── Duration pills (default suggested by quadrant) ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final m in {15, 25, 50, _kQuadMins[quad] ?? 25}.toList()..sort()) ...[
                _DurPill(label: '${m}m', value: m, selected: _mins, color: qColor, onTap: _setMins),
                SizedBox(width: 8),
              ],
            ],
          ),
          SizedBox(height: 18),

          // ── Controls ───────────────────────────────────────────────────────
          if (_done)
            _PrimaryBtn(label: 'DONE ✓', color: colors.successFg, onTap: () => Navigator.of(context).pop())
          else
            Row(
              children: [
                Expanded(
                  child: _PrimaryBtn(
                    label: _running ? 'PAUSE' : 'START FOCUS',
                    color: _running ? const Color(0xFF636366) : TaskEraColors.acc,
                    onTap: _startPause,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _end,
                  child: Container(
                    height: 44, width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: TaskEraColors.warn.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Text('End',
                        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                            fontWeight: FontWeight.w700, color: TaskEraColors.warn)),
                  ),
                ),
              ],
            ),
        ],
      ),
        ),
      ),
    );
  }
}

class _DurPill extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final Color color;
  final ValueChanged<int> onTap;
  const _DurPill({required this.label, required this.value, required this.selected,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final active = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5, color: active ? color.withValues(alpha: 0.4) : colors.bdr),
        ),
        child: Text(label,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? color : colors.ink3)),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2)),
      ),
    );
  }
}
