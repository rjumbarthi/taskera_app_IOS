import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart' show Task;
import '../data/providers/tasks_provider.dart';
import '../data/providers/time_tracker_provider.dart';

const _accent = Color(0xFF0A84FF); // tokens core_colors.acc

/// App-wide floating focus-session pill (Dynamic-Island style). Mounted once at
/// the root so it stays visible across every tab while a session runs.
class FocusPillOverlay extends ConsumerWidget {
  const FocusPillOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(timeTrackerProvider);
    if (tr.taskTitle == null) return const SizedBox.shrink();

    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    Task? task;
    for (final t in tasks) {
      if (t.id == tr.taskId) {
        task = t;
        break;
      }
    }
    final targetSec = (task?.timeAllocatedMin ?? 25) * 60;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FocusPill(
              state: tr,
              targetSeconds: targetSec,
              onToggle: () {
                final n = ref.read(timeTrackerProvider.notifier);
                tr.running ? n.pause() : n.resume();
              },
              onStop: () => ref.read(timeTrackerProvider.notifier).stop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusPill extends StatelessWidget {
  final TimeTrackerState state;
  final int targetSeconds;
  final VoidCallback onToggle;
  final VoidCallback onStop;
  const _FocusPill({
    required this.state,
    required this.targetSeconds,
    required this.onToggle,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        targetSeconds > 0 ? (state.elapsedSeconds / targetSeconds).clamp(0.0, 1.0) : 0.0;
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xD9101012),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(width: 0.5, color: const Color(0x1FFFFFFF)),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        value: progress.toDouble(),
                        strokeWidth: 2.5,
                        backgroundColor: const Color(0x33FFFFFF),
                        valueColor: const AlwaysStoppedAnimation(_accent),
                      ),
                    ),
                    Icon(state.running ? Icons.bolt : Icons.pause, size: 13, color: Colors.white),
                  ]),
                ),
                const SizedBox(width: 11),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(state.taskTitle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.1)),
                    ),
                    const SizedBox(height: 2),
                    Text(state.displayTime,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0x99FFFFFF),
                            height: 1,
                            fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
                const SizedBox(width: 14),
                _PillBtn(icon: state.running ? Icons.pause_rounded : Icons.play_arrow_rounded, onTap: onToggle),
                const SizedBox(width: 4),
                _PillBtn(icon: Icons.close_rounded, onTap: onStop),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Color(0x1FFFFFFF), shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
      ),
    );
  }
}
