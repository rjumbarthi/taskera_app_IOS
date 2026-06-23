import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

class StudentModeScreen extends ConsumerWidget {
  const StudentModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: 'Student Mode',
            subtitle: 'UPSC · JEE · MBA · Board exams',
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
            actions: [
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: KaalColors.q2, shape: BoxShape.circle)),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12, 8, 12, safeBot + 24),
          children: [
            _SectionLabel('Exam countdowns', colors),
            const SizedBox(height: 6),
            _ExamCountdowns(colors: colors),
            const SizedBox(height: 9),
            _StudyPlanCard(colors: colors),
            const SizedBox(height: 9),
            _SectionLabel('Subject task groups', colors),
            const SizedBox(height: 6),
            _SubjectGroups(colors: colors),
            const SizedBox(height: 9),
            _WeekStatsCard(colors: colors),
          ],
        ),
      ),
        ]),
      ),
    ]);
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _SectionLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 0, 0),
      child: Text(text.toUpperCase(),
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 0.5,
              color: colors.ink3, height: 1)),
    );
  }
}

// ── Exam countdowns ───────────────────────────────────────────────────────────

class _ExamCountdowns extends StatelessWidget {
  final KaalColors colors;
  const _ExamCountdowns({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ExamCard(
            name: 'UPSC Prelims',
            days: 42,
            percent: 0.62,
            label: '62% prep done',
            accentColor: const Color(0xFFFF6B6B),
            bg: const Color(0x1FF25022),
            border: const Color(0x4DF25022),
          ),
          const SizedBox(width: 8),
          _ExamCard(
            name: 'JEE Advanced',
            days: 89,
            percent: 0.38,
            label: '38% prep done',
            accentColor: KaalColors.acc2,
            bg: const Color(0x1A0A84FF),
            border: const Color(0x400A84FF),
          ),
          const SizedBox(width: 8),
          _AddExamCard(colors: colors),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String name;
  final int days;
  final double percent;
  final String label;
  final Color accentColor;
  final Color bg;
  final Color border;
  const _ExamCard({required this.name, required this.days, required this.percent,
      required this.label, required this.accentColor, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name.toUpperCase(),
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, color: accentColor,
                letterSpacing: 0.3, height: 1)),
        const SizedBox(height: 4),
        Text('$days',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 28,
                fontVariations: const [FontVariation('wght', 700)],
                color: Colors.white, height: 1)),
        Text('days left',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: Colors.white54, height: 1.3)),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 4,
            backgroundColor: const Color(0x33FFFFFF),
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: Colors.white54, height: 1)),
      ]),
    );
  }
}

class _AddExamCard extends StatelessWidget {
  final KaalColors colors;
  const _AddExamCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 1.5, color: colors.bdr2,
            style: BorderStyle.none),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: colors.bdr2),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('+',
              style: TextStyle(fontFamily: 'Inter', fontSize: 20,
                  color: colors.ink3, height: 1)),
          const SizedBox(height: 4),
          Text('Add exam',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, height: 1.2)),
        ]),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
          const Radius.circular(13)));
    _drawDashed(canvas, path, paint);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashLen = 5.0, gapLen = 4.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final end = (dist + dashLen).clamp(0, m.length);
        canvas.drawPath(m.extractPath(dist, end.toDouble()), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ── Study plan card ───────────────────────────────────────────────────────────

class _StudyPlanCard extends StatelessWidget {
  final KaalColors colors;
  const _StudyPlanCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text("Today's study plan",
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
          ),
          Text('5h 30m target',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                  fontWeight: FontWeight.w600, color: KaalColors.q2, height: 1)),
        ]),
        const SizedBox(height: 9),
        _StudyItem(
          dot: KaalColors.q2,
          title: 'History — Modern India',
          sub: 'UPSC · 90 min',
          bg: const Color(0x117FBA00),
          border: const Color(0x337FBA00),
          trailing: _CheckCircle(),
        ),
        const SizedBox(height: 6),
        _StudyItem(
          dot: KaalColors.acc,
          title: 'Polity — Constitution',
          sub: 'UPSC · 60 min',
          bg: colors.surf2,
          border: colors.bdr,
          trailing: _StartBtn(),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: 0.5,
          child: _StudyItem(
            dot: colors.ink3,
            title: 'Maths — Integration',
            sub: 'JEE · 120 min',
            bg: colors.surf2,
            border: colors.bdr,
            trailing: Text('Later',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1)),
          ),
        ),
      ]),
    );
  }
}

class _StudyItem extends StatelessWidget {
  final Color dot;
  final String title;
  final String sub;
  final Color bg;
  final Color border;
  final Widget trailing;
  const _StudyItem({required this.dot, required this.title, required this.sub,
      required this.bg, required this.border, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Row(children: [
        Container(width: 6, height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        trailing,
      ]),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 1.5, color: KaalColors.q2),
      ),
      child: const Icon(Icons.check, color: KaalColors.q2, size: 11),
    );
  }
}

class _StartBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
      decoration: BoxDecoration(
        color: KaalColors.acc,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('Start',
          style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
    );
  }
}

// ── Subject groups ────────────────────────────────────────────────────────────

class _SubjectGroups extends StatelessWidget {
  final KaalColors colors;
  const _SubjectGroups({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _SubjectRow(
        emoji: '📚', label: 'UPSC Prep', sub: '14 tasks · 3 due today',
        quadLabel: 'Q1', quadColor: const Color(0xFFFF6B6B),
        iconBg: const Color(0x1AF25022),
        border: const Color(0x33F25022),
        colors: colors,
      ),
      const SizedBox(height: 6),
      _SubjectRow(
        emoji: '⚗️', label: 'JEE / Science', sub: '8 tasks · 1 due today',
        quadLabel: 'Q2', quadColor: KaalColors.acc2,
        iconBg: const Color(0x1A0A84FF),
        border: const Color(0x330A84FF),
        colors: colors,
      ),
      const SizedBox(height: 6),
      _SubjectRow(
        emoji: '📝', label: 'Assignments', sub: '5 tasks · 0 due today',
        quadLabel: 'Q3', quadColor: colors.ink3,
        iconBg: colors.surf2,
        border: colors.bdr,
        colors: colors,
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 1.5, color: colors.bdr2,
              style: BorderStyle.none),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: colors.bdr2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text('+ Add subject',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: colors.ink3, height: 1)),
          ),
        ),
      ),
    ]);
  }
}

class _SubjectRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final String quadLabel;
  final Color quadColor;
  final Color iconBg;
  final Color border;
  final KaalColors colors;
  const _SubjectRow({required this.emoji, required this.label, required this.sub,
      required this.quadLabel, required this.quadColor, required this.iconBg,
      required this.border, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(width: 0.5, color: border),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 13)),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        Text(quadLabel,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w600, color: quadColor, height: 1)),
        const SizedBox(width: 6),
        Text('›',
            style: TextStyle(fontSize: 18, color: colors.ink3, height: 1)),
      ]),
    );
  }
}

// ── Week stats card ───────────────────────────────────────────────────────────

class _WeekStatsCard extends StatelessWidget {
  final KaalColors colors;
  const _WeekStatsCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('This week',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: FontWeight.w700, color: colors.ink, height: 1)),
        const SizedBox(height: 8),
        Row(children: [
          _WeekCell(value: '22h', label: 'Studied',
              bg: colors.surf2, valueColor: colors.ink),
          const SizedBox(width: 6),
          _WeekCell(value: '34', label: 'Topics',
              bg: colors.surf2, valueColor: KaalColors.q2),
          const SizedBox(width: 6),
          _WeekCell(value: '6🔥', label: 'Day streak',
              bg: const Color(0x14FFB900), valueColor: KaalColors.q4),
        ]),
      ]),
    );
  }
}

class _WeekCell extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _WeekCell({required this.value, required this.label,
      required this.bg, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Column(children: [
          Text(value,
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                  fontVariations: const [FontVariation('wght', 700)],
                  color: valueColor, height: 1)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  color: Colors.white54, height: 1.3)),
        ]),
      ),
    );
  }
}
