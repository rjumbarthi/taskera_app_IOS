import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/tasks_provider.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/ai_insight_card.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Suggestion {
  final String title, meta, slot, slotDetail;
  final Color quadColor;
  const _Suggestion(this.title, this.meta, this.slot, this.slotDetail, this.quadColor);
}

const _suggestions = <_Suggestion>[];

class _Scheduled {
  final String title, time;
  const _Scheduled(this.title, this.time);
}

const _scheduled = <_Scheduled>[];

// ── Screen ────────────────────────────────────────────────────────────────────

class DayScheduleScreen extends ConsumerStatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  ConsumerState<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends ConsumerState<DayScheduleScreen> {
  final Set<int> _confirmed = {};

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final active = (ref.watch(allTasksProvider).valueOrNull ?? const [])
        .where((t) => !t.isDone)
        .toList();
    final aiInput = active.isEmpty
        ? 'The user has no active tasks to schedule.'
        : 'My active tasks to schedule:\n${active.take(25).map((t) => '- ${t.title} (Q${t.quadrant})${t.dueLabel != null && t.dueLabel!.isNotEmpty ? ' · due ${t.dueLabel}' : ''}').join('\n')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Auto-schedule', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('AI finds best slots for your tasks', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Auto-scheduling coming soon'))),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                  decoration: BoxDecoration(color: TaskEraColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: Text('Schedule all', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Real on-demand TaskEra AI — reasons over your unscheduled tasks.
                AiInsightCard(
                  input: aiInput,
                  hint: 'When should I tackle these today?',
                  margin: EdgeInsets.zero,
                ),
                SizedBox(height: 12),

                // NEEDS SCHEDULING
                Row(
                  children: [
                    Text('NEEDS SCHEDULING', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                    SizedBox(width: 6),
                    Text('· ${_suggestions.length} TASKS', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
                  ],
                ),
                SizedBox(height: 8),

                if (_suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No tasks need scheduling right now.',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                    ),
                  )
                else
                  for (int i = 0; i < _suggestions.length; i++) ...[
                    _SuggestionCard(
                      suggestion: _suggestions[i],
                      confirmed: _confirmed.contains(i),
                      onConfirm: () => setState(() => _confirmed.add(i)),
                      colors: colors,
                    ),
                    SizedBox(height: 8),
                  ],

                // ALREADY SCHEDULED
                SizedBox(height: 8),
                Text('ALREADY SCHEDULED · TODAY', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                SizedBox(height: 6),
                if (_scheduled.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Nothing scheduled for today yet.',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink3),
                    ),
                  )
                else
                  for (final s in _scheduled) ...[
                    _ScheduledRow(s: s, colors: colors),
                    SizedBox(height: 4),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Suggestion card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  final _Suggestion suggestion;
  final bool confirmed;
  final VoidCallback onConfirm;
  final TaskEraColors colors;
  const _SuggestionCard({required this.suggestion, required this.confirmed, required this.onConfirm, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(suggestion.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: colors.textOrPlain(suggestion.quadColor))),
          SizedBox(height: 2),
          Text(suggestion.meta, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
          SizedBox(height: 8),
          // AI slot suggestion
          Row(
            children: [
              Text('✦ AI · ', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.textOrPlain(TaskEraColors.acc2))),
              Expanded(
                child: Text(suggestion.slot, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              if (!confirmed)
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                  decoration: BoxDecoration(color: const Color(0x1F7FBA00), borderRadius: BorderRadius.circular(4)),
                  child: Text('Best', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: colors.successFg)),
                ),
            ],
          ),
          SizedBox(height: 2),
          Text(suggestion.slotDetail, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
          SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: confirmed ? const Color(0x1F7FBA00) : TaskEraColors.accBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: confirmed ? const Color(0x407FBA00) : const Color(0x660A84FF)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (confirmed) Icon(Icons.check, size: 12, color: colors.successFg),
                        if (confirmed) SizedBox(width: 4),
                        Text(
                          confirmed ? 'Confirmed' : '✓ Confirm',
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: confirmed ? colors.successFg : TaskEraColors.acc2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Alternative slots coming soon'))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    alignment: Alignment.center,
                    child: Text('Other slots', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduledRow extends StatelessWidget {
  final _Scheduled s;
  final TaskEraColors colors;
  const _ScheduledRow({required this.s, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined, size: 12, color: colors.ink3),
          SizedBox(width: 8),
          Expanded(child: Text(s.title, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13, color: colors.ink))),
          Text(s.time, style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3)),
        ],
      ),
    );
  }
}
