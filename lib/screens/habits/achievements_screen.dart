import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_l10n.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _unlocked = [
    ('🌱', 'First Habit',  'Created your first habit',          Color(0xFF7FBA00)),
    ('🔥', '7 Day Streak', 'Complete a habit 7 days in a row',  Color(0xFFFF6B6B)),
    ('🌅', 'Early Bird',   'Complete a habit before 8 AM',      Color(0xFFFFB900)),
    ('⭐', '5 Habits',     'Track 5 habits at once',             Color(0xFF0A84FF)),
  ];

  static const _locked = [
    ('🏆', '30 Day Streak',  'Maintain a streak for 30 days',         0.47),
    ('💎', 'Habit Master',   'Complete 50 habits total',              0.86),
    ('🎯', 'Perfect Week',   'Complete all habits for 7 days',        0.60),
    ('🚀', '10 Habits',      'Track 10 habits at once',               0.40),
    ('🌙', 'Night Owl',      'Complete a habit after 10 PM',          0.0),
    ('🎪', 'Variety Pack',   'Complete 5 different habit types',      0.80),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
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
                child: Text(AppL10n.of(context).achievements, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // Unlocked section
              Text(
                'UNLOCKED (${_unlocked.length})',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 1.0,
                children: _unlocked.map((a) => _UnlockedCard(
                  emoji: a.$1, title: a.$2, desc: a.$3, accentColor: a.$4,
                )).toList(),
              ),
              const SizedBox(height: 16),
              // Locked section
              Text(
                'LOCKED (${_locked.length})',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 7, mainAxisSpacing: 7, childAspectRatio: 0.9,
                children: _locked.map((a) => _LockedCard(
                  emoji: a.$1, title: a.$2, desc: a.$3, pct: a.$4, colors: colors,
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final String emoji, title, desc;
  final Color accentColor;
  const _UnlockedCard({required this.emoji, required this.title, required this.desc, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(0x1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: accentColor.withAlpha(0x30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF2F2F7), height: 1.2)),
          const SizedBox(height: 3),
          Text(desc, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.labelMuted, height: 1.4)),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final String emoji, title, desc;
  final double pct;
  final KaalColors colors;
  const _LockedCard({required this.emoji, required this.title, required this.desc, required this.pct, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
            ),
            const SizedBox(height: 5),
            Text(title, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink, height: 1.2)),
            const SizedBox(height: 3),
            Text(desc, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3, height: 1.4)),
            const SizedBox(height: 6),
            if (pct > 0) ...[
              Container(
                height: 3,
                decoration: BoxDecoration(color: const Color(0x20FFFFFF), borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  widthFactor: pct, alignment: Alignment.centerLeft,
                  child: Container(decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(2))),
                ),
              ),
              const SizedBox(height: 3),
              Text('${(pct * 100).toInt()}%', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
            ] else
              Text('🔒 Locked', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: colors.ink3)),
          ],
        ),
      ),
    );
  }
}
