import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

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

class DayScheduleScreen extends StatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  final Set<int> _confirmed = {};

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Auto-schedule', style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('AI finds best slots for your tasks', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                  decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Schedule all', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
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
                // AI banner
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color(0x120A84FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
                      children: const [
                        TextSpan(text: '✦ ', style: TextStyle(color: KaalColors.acc2)),
                        TextSpan(text: 'AI scans your calendar, peak hours and task scores to find optimal slots. ', style: TextStyle(color: KaalColors.acc2)),
                        TextSpan(text: 'No tasks need scheduling yet.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // NEEDS SCHEDULING
                Row(
                  children: [
                    Text('NEEDS SCHEDULING', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                    const SizedBox(width: 6),
                    Text('· ${_suggestions.length} TASKS', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                  ],
                ),
                const SizedBox(height: 8),

                if (_suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No tasks need scheduling right now.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
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
                    const SizedBox(height: 8),
                  ],

                // ALREADY SCHEDULED
                const SizedBox(height: 8),
                Text('ALREADY SCHEDULED · TODAY', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                const SizedBox(height: 6),
                if (_scheduled.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Nothing scheduled for today yet.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink3),
                    ),
                  )
                else
                  for (final s in _scheduled) ...[
                    _ScheduledRow(s: s, colors: colors),
                    const SizedBox(height: 4),
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
  final KaalColors colors;
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
          Text(suggestion.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: suggestion.quadColor)),
          const SizedBox(height: 2),
          Text(suggestion.meta, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          const SizedBox(height: 8),
          // AI slot suggestion
          Row(
            children: [
              const Text('✦ AI · ', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc2)),
              Expanded(
                child: Text(suggestion.slot, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              if (!confirmed)
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                  decoration: BoxDecoration(color: const Color(0x1F7FBA00), borderRadius: BorderRadius.circular(4)),
                  child: Text('Best', style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: colors.successFg)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(suggestion.slotDetail, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          const SizedBox(height: 10),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: confirmed ? const Color(0x1F7FBA00) : KaalColors.accBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: confirmed ? const Color(0x407FBA00) : const Color(0x660A84FF)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (confirmed) Icon(Icons.check, size: 12, color: colors.successFg),
                        if (confirmed) const SizedBox(width: 4),
                        Text(
                          confirmed ? 'Confirmed' : '✓ Confirm',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: confirmed ? colors.successFg : KaalColors.acc2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    alignment: Alignment.center,
                    child: Text('Other slots', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
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
  final KaalColors colors;
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
          const SizedBox(width: 8),
          Expanded(child: Text(s.title, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink))),
          Text(s.time, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
        ],
      ),
    );
  }
}
