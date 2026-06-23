import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/ai_nudge_card.dart';
import '../widgets/bar_chart.dart';
import '../widgets/color_swatch.dart';
import '../widgets/context_menu.dart';
import '../widgets/donut_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/habit_row.dart';
import '../widgets/heatmap.dart';
import '../widgets/kaal_fab.dart';
import '../widgets/kaal_filter_chip.dart';
import '../widgets/kaal_pill.dart';
import '../widgets/kaal_toggle.dart';
import '../widgets/note_row.dart';
import '../widgets/progress_bar.dart';
import '../widgets/progress_ring.dart';
import '../widgets/quadrant_card.dart';
import '../widgets/reward_modal.dart';
import '../widgets/segmented_control.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_row.dart';
import '../widgets/size_chips.dart';
import '../widgets/stat_card.dart';
import '../widgets/streak_protect_dialog.dart';
import '../widgets/task_row.dart';
import '../widgets/timeline_row.dart';
import '../widgets/trend_line.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _toggle1 = true;
  bool _toggle2 = false;
  int _seg = 0;
  int _size = 2;
  int _swatch = 0;
  bool _chipA = true;
  bool _chipB = false;
  bool _chipC = false;

  static const _swatchColors = [
    KaalColors.acc,
    KaalColors.q1,
    KaalColors.q2,
    KaalColors.q3,
    KaalColors.q4,
  ];

  void _showContextMenu(BuildContext context, Offset position) {
    showKaalContextMenu(
      context: context,
      position: position,
      items: [
        ContextMenuItem(
          label: 'Edit',
          icon: Icons.edit_outlined,
          onTap: () {},
        ),
        ContextMenuItem(
          label: 'Complete',
          icon: Icons.check_circle_outline,
          onTap: () {},
        ),
        ContextMenuItem(
          label: 'Delete',
          icon: Icons.delete_outline,
          color: const Color(0xFFFF6B6B),
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section('Group 1 — Surfaces & Cards'),

          _Label('GlassCard (B1)'),
          GlassCard(
            child: Text(
              'Glass surface',
              style: TextStyle(color: colors.ink, fontFamily: 'Inter', fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),

          _Label('QuadrantCard (B2) — gradient bg, icon badge, count Positioned(bottom:9, right:11)'),
          Row(children: [
            Expanded(child: QuadrantCard(quadrant: KaalQuadrant.q1, title: 'Do Now', count: 4, icon: '⚡', onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: QuadrantCard(quadrant: KaalQuadrant.q2, title: 'Schedule', count: 7, icon: '🎯', onTap: () {})),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: QuadrantCard(quadrant: KaalQuadrant.q3, title: 'Delegate', count: 2, icon: '🤝', onTap: () {})),
            const SizedBox(width: 8),
            Expanded(child: QuadrantCard(quadrant: KaalQuadrant.q4, title: 'Eliminate', count: 1, icon: '🗑', onTap: () {})),
          ]),
          const SizedBox(height: 12),

          _Label('StatCard (B3) — radius 14, Fraunces 700 19sp number'),
          Row(children: [
            Expanded(child: StatCard(number: '11', label: 'TODAY')),
            const SizedBox(width: 8),
            Expanded(child: StatCard(number: '9', label: 'ACTIVE')),
            const SizedBox(width: 8),
            Expanded(child: StatCard(number: '2', label: 'DONE')),
            const SizedBox(width: 8),
            Expanded(child: StatCard(number: '1', label: 'OVERDUE')),
          ]),
          const SizedBox(height: 12),

          _Label('SettingsCard (B4) + SettingsRow (C7) + KaalToggle (D1)'),
          SettingsCard(children: [
            SettingsRow(
              icon: const Icon(Icons.notifications_outlined, size: 14, color: Colors.white),
              iconBg: KaalColors.acc,
              label: 'Notifications',
              trailing: KaalToggle(value: _toggle1, onChanged: (v) => setState(() => _toggle1 = v)),
            ),
            SettingsRow(
              icon: const Icon(Icons.dark_mode_outlined, size: 14, color: Colors.white),
              iconBg: const Color(0xFF5856D6),
              label: 'Dark mode',
              trailing: KaalToggle(value: _toggle2, onChanged: (v) => setState(() => _toggle2 = v)),
            ),
            const SettingsRow(label: 'Language', value: 'English'),
          ]),
          const SizedBox(height: 12),

          _Label('SettingsGroup (B5) — collapsible, chevron AnimatedRotation 200ms, AnimatedSize body'),
          SettingsGroup(
            icon: const Icon(Icons.tune, size: 16, color: Colors.white),
            iconBg: KaalColors.q3,
            title: 'Appearance',
            initiallyExpanded: true,
            children: [
              SettingsRow(label: 'Theme', value: 'Glass'),
              SettingsRow(label: 'Font size', value: 'Medium'),
            ],
          ),

          _Section('Group 2 — Pills & Chips'),

          _Label('KaalPill (C5) — radius 3, pad h:4 v:1, 9sp'),
          Wrap(spacing: 6, children: [
            KaalPill(label: 'Q1 · Overdue', color: KaalColors.q1),
            KaalPill(label: 'Q2', color: KaalColors.q2),
            KaalPill(label: 'Daily', color: KaalColors.acc),
          ]),
          const SizedBox(height: 12),

          _Label('FilterChip (C6) — radius 6, pad h:10 v:4, 9sp (visibly larger than Pill)'),
          Wrap(spacing: 6, children: [
            KaalFilterChip(label: 'All', active: _chipA, onTap: () => setState(() { _chipA = true; _chipB = false; _chipC = false; })),
            KaalFilterChip(label: 'Q1', active: _chipB, onTap: () => setState(() { _chipA = false; _chipB = true; _chipC = false; })),
            KaalFilterChip(label: 'Q2', active: _chipC, onTap: () => setState(() { _chipA = false; _chipB = false; _chipC = true; })),
          ]),
          const SizedBox(height: 12),

          _Label('SegmentedControl (D3)'),
          KaalSegmentedControl(
            options: const ['Glass', 'Dark', 'Light'],
            selectedIndex: _seg,
            onChanged: (i) => setState(() => _seg = i),
          ),
          const SizedBox(height: 12),

          _Label('SizeChips (D4)'),
          SizeChips(selectedIndex: _size, onChanged: (i) => setState(() => _size = i)),

          _Section('Group 3 — Rows'),

          _Label('TaskRow (C1) — long-press 480ms or right-click → ContextMenu at touch coords'),
          Column(children: [
            TaskRow(
              title: 'Review Q1 strategy deck',
              onTap: () {},
              onLongPress: (pos) => _showContextMenu(context, pos),
            ),
            const SizedBox(height: 6),
            TaskRow(
              title: 'Send weekly update (completed)',
              completed: true,
              onTap: () {},
              onLongPress: (pos) => _showContextMenu(context, pos),
            ),
          ]),
          const SizedBox(height: 12),

          _Label('HabitRow (C2) — 7-day dot grid, streak badge'),
          HabitRow(
            name: 'Morning workout',
            schedule: 'Daily · 06:00',
            weekDots: [true, true, false, true, true, false, false],
            streak: 12,
          ),
          const SizedBox(height: 12),

          _Label('NoteRow (C3)'),
          NoteRow(
            title: 'Sprint retrospective notes',
            preview: 'Velocity was lower than expected due to unplanned hotfixes…',
            tag: 'Work',
            timestamp: 'Yesterday',
            onTap: () {},
          ),
          const SizedBox(height: 12),

          _Label('TimelineRow (C4)'),
          Column(children: [
            TimelineRow(
              time: '08:30 AM',
              accentColor: KaalColors.q1,
              content: Text('Deep work block', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink)),
            ),
            const SizedBox(height: 8),
            TimelineRow(
              time: '10:00 AM',
              accentColor: KaalColors.q2,
              content: Text('Team standup', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink)),
            ),
          ]),

          _Section('Group 4 — Controls'),

          _Label('KaalToggle (D1) — track 32×17, thumb 13×13, radius 9'),
          Row(children: [
            KaalToggle(value: true, onChanged: (_) {}),
            const SizedBox(width: 12),
            KaalToggle(value: false, onChanged: (_) {}),
          ]),
          const SizedBox(height: 12),

          _Label('ColorSwatch (D2) — 20×20, scale 1.15 when selected'),
          Row(children: [
            for (int i = 0; i < _swatchColors.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              KaalColorSwatch(
                color: _swatchColors[i],
                selected: _swatch == i,
                onTap: () => setState(() => _swatch = i),
              ),
            ],
          ]),
          const SizedBox(height: 12),

          _Label('ContextMenu (D5) — long-press a TaskRow above to trigger'),
          GlassCard(
            child: Text(
              'Long-press (480ms) or right-click a TaskRow above. Menu appears at touch coords; outside tap dismisses after 450ms.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
            ),
          ),

          _Section('Group 5 — FAB'),

          _Label('KaalFab (A5) — 38×38, BoxShadow acc 0.5α blur 14'),
          KaalFab(onTap: () {}),

          _Section('Group 6 — Stats Viz'),

          _Label('ProgressBar (E1) — 3dp tall, rounded'),
          KaalProgressBar(value: 0.65),
          const SizedBox(height: 6),
          KaalProgressBar(value: 0.3, color: KaalColors.q1),
          const SizedBox(height: 12),

          _Label('ProgressRing (E2) — CustomPaint arc, stroke 4'),
          Row(children: [
            ProgressRing(
              value: 0.72,
              center: Text('72%', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink)),
            ),
            const SizedBox(width: 16),
            ProgressRing(value: 0.4, color: KaalColors.q1),
            const SizedBox(width: 16),
            ProgressRing(value: 1.0, color: KaalColors.q2),
          ]),
          const SizedBox(height: 12),

          _Label('BarChart (E4)'),
          KaalBarChart(bars: const [
            BarChartData(value: 0.8, color: KaalColors.q1, label: 'M'),
            BarChartData(value: 0.6, color: KaalColors.q2, label: 'T'),
            BarChartData(value: 0.9, color: KaalColors.q1, label: 'W'),
            BarChartData(value: 0.4, color: KaalColors.q3, label: 'T'),
            BarChartData(value: 0.7, color: KaalColors.q2, label: 'F'),
            BarChartData(value: 0.3, color: KaalColors.q4, label: 'S'),
            BarChartData(value: 0.1, color: KaalColors.q4, label: 'S'),
          ]),
          const SizedBox(height: 12),

          _Label('TrendLine (E5) — smooth cubic bezier'),
          TrendLine(values: const [0.3, 0.5, 0.45, 0.7, 0.6, 0.85, 0.9]),
          const SizedBox(height: 12),

          _Label('DonutChart (E6) — Q1/Q2/Q3 + Unplanned segments'),
          KaalQuadrantDonut(
            q1Hours: 3,
            q2Hours: 2,
            q3Hours: 1,
            unplannedHours: 0.5,
            centerText: '6.5h',
          ),
          const SizedBox(height: 12),

          _Label('Heatmap (E3) — 28-cell monthly grid'),
          KaalHeatmap(
            cells: List.generate(
              28,
              (i) => HeatmapCell(
                intensity: (i % 7 == 0 || i % 7 == 6) ? 0 : ((i % 5) / 4),
              ),
            ),
          ),

          _Section('Group 7 — Overlays'),

          _Label('AiNudgeCard (F2)'),
          AiNudgeCard(
            message: 'You have 3 Q1 tasks overdue. Focus on "Review strategy deck" to stay on track.',
            ctaLabel: 'Show Q1 tasks',
            onCta: () {},
            onDismiss: () {},
          ),
          const SizedBox(height: 12),

          _Label('RewardModal (F4) — blur 6px, scrim 0.60α'),
          GestureDetector(
            onTap: () => showRewardModal(
              context: context,
              child: Text('🏆 Task complete!', style: TextStyle(color: colors.ink, fontFamily: 'Inter', fontSize: 15)),
            ),
            child: GlassCard(
              child: Text(
                'Tap to show RewardModal (blur 6px, scrim 0.60α)',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3),
              ),
            ),
          ),
          const SizedBox(height: 8),

          _Label('StreakProtectDialog (F5) — blur 4px, scrim 0.65α'),
          GestureDetector(
            onTap: () => showStreakProtectDialog(
              context: context,
              child: Text('🔥 Use streak shield?', style: TextStyle(color: colors.ink, fontFamily: 'Inter', fontSize: 15)),
            ),
            child: GlassCard(
              child: Text(
                'Tap to show StreakProtectDialog (blur 4px, scrim 0.65α)',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Label('CompletedPanel (F1)'),
          GlassCard(
            child: Text(
              'CompletedPanel.push(context, …) slides in from bottom — trigger from a real screen in Phase 5.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),

          _Label('FabChooserSheet (F3)'),
          GlassCard(
            child: Text(
              'showFabChooserSheet() — triggered from KaalFab in Phase 5 screens.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colors.ink4,
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 0, thickness: 0.5, color: colors.bdr),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          color: KaalTheme.of(context).colors.ink3,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
