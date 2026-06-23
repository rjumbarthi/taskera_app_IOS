import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Preset {
  final String name, sub;
  final int count;
  final Color quadColor;
  const _Preset(this.name, this.sub, this.count, this.quadColor);
}

const _presets = [
  _Preset('Overdue tasks',       'Past due · All quads',  1, KaalColors.q1),
  _Preset('High score Q2',       'Q2 · Score > 7',        3, KaalColors.q2),
  _Preset('Today\'s Q2 focus',   'Q2 · Due today',        4, KaalColors.q2),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final String _whenField = 'Quadrant';
  final String _whenOp    = 'is';
  final String _whenVal   = 'Q2';
  final String _andField  = 'Score';
  final String _andOp     = '≥';
  final String _andVal    = '7.0';

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
                    Text('Filters', style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('Custom task views', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PRESETS
                Text('PRESETS', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                const SizedBox(height: 6),
                for (final p in _presets) ...[
                  _PresetRow(preset: p, colors: colors),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 16),

                // BUILD A FILTER
                Text('BUILD A FILTER', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                const SizedBox(height: 6),

                // When row
                _ConditionRow(
                  prefix: 'When',
                  field: _whenField,
                  op: _whenOp,
                  value: _whenVal,
                  colors: colors,
                ),
                const SizedBox(height: 4),

                // And row
                _ConditionRow(
                  prefix: 'And',
                  field: _andField,
                  op: _andOp,
                  value: _andVal,
                  colors: colors,
                ),
                const SizedBox(height: 8),

                // + Add condition
                GestureDetector(
                  onTap: () {},
                  child: const Text('+ Add condition', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc)),
                ),
                const SizedBox(height: 12),

                // Run + Focus buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(9)),
                          alignment: Alignment.center,
                          child: const Text('Run', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(width: 0.5, color: KaalColors.acc),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Focus', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: KaalColors.acc2)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Save as Filter
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: colors.bdr),
                    ),
                    alignment: Alignment.center,
                    child: const Text('+ Save as Filter', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: KaalColors.acc)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Preset row ────────────────────────────────────────────────────────────────

class _PresetRow extends StatelessWidget {
  final _Preset preset;
  final KaalColors colors;
  const _PresetRow({required this.preset, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preset.name, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: preset.quadColor)),
                Text(preset.sub, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
              ],
            ),
          ),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: KaalColors.accBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${preset.count}', style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: KaalColors.acc2)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(6)),
              child: const Text('Focus', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Condition row ─────────────────────────────────────────────────────────────

class _ConditionRow extends StatelessWidget {
  final String prefix, field, op, value;
  final KaalColors colors;
  const _ConditionRow({required this.prefix, required this.field, required this.op, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(prefix, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: colors.ink3)),
          ),
          const SizedBox(width: 8),
          _Pill(label: field, colors: colors),
          const SizedBox(width: 6),
          Text(op, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
          const SizedBox(width: 6),
          _Pill(label: value, colors: colors, active: true),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final KaalColors colors;
  final bool active;
  const _Pill({required this.label, required this.colors, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: active ? KaalColors.accBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(width: 0.5, color: active ? const Color(0x660A84FF) : colors.bdr),
      ),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: active ? KaalColors.acc2 : colors.ink2)),
    );
  }
}
