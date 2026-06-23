import 'package:flutter/material.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_motion.dart';
import '../theme/kaal_shape.dart';

enum KaalQuadrant { q1, q2, q3, q4 }

extension KaalQuadrantX on KaalQuadrant {
  Color get color => switch (this) {
        KaalQuadrant.q1 => KaalColors.q1,
        KaalQuadrant.q2 => KaalColors.q2,
        KaalQuadrant.q3 => KaalColors.q3,
        KaalQuadrant.q4 => KaalColors.q4,
      };

  String get label => switch (this) {
        KaalQuadrant.q1 => 'Q1',
        KaalQuadrant.q2 => 'Q2',
        KaalQuadrant.q3 => 'Q3',
        KaalQuadrant.q4 => 'Q4',
      };

  // Glass theme: linear-gradient(145deg, start ~45%, end ~52%)
  List<Color> get gradient => switch (this) {
        KaalQuadrant.q1 => const [Color(0x739B1600), Color(0x85F25022)],
        KaalQuadrant.q2 => const [Color(0x73326E00), Color(0x857FBA00)],
        KaalQuadrant.q3 => const [Color(0x73004080), Color(0x8500A4EF)],
        KaalQuadrant.q4 => const [Color(0x73784C00), Color(0x85FFB900)],
      };

  // .5px border at 40% alpha
  Color get borderColor => switch (this) {
        KaalQuadrant.q1 => const Color(0x66F25022),
        KaalQuadrant.q2 => const Color(0x667FBA00),
        KaalQuadrant.q3 => const Color(0x6600A4EF),
        KaalQuadrant.q4 => const Color(0x66FFB900),
      };

  // qc-ico bg: rgba(255,255,255,.22); Q4 uses rgba(0,0,0,.12)
  Color get iconBg => switch (this) {
        KaalQuadrant.q4 => const Color(0x1F000000),
        _ => const Color(0x38FFFFFF),
      };
}

class QuadrantCard extends StatefulWidget {
  final KaalQuadrant quadrant;
  final String title;
  final int count;
  final String icon;
  // Dashboard extras — null = omit section
  final String? meta;
  final double? progressFraction;
  final String? badgeText;
  final VoidCallback? onTap;

  const QuadrantCard({
    super.key,
    required this.quadrant,
    required this.title,
    required this.count,
    required this.icon,
    this.meta,
    this.progressFraction,
    this.badgeText,
    this.onTap,
  });

  @override
  State<QuadrantCard> createState() => _QuadrantCardState();
}

class _QuadrantCardState extends State<QuadrantCard> {
  bool _pressed = false;

  // Badge colors from shared.css lines 213-239
  Color _badgeBg(KaalQuadrant q) => switch (q) {
        KaalQuadrant.q3 => const Color(0x2E00A4EF), // rgba(0,164,239,.18)
        KaalQuadrant.q4 => const Color(0x2EFFB900), // rgba(255,185,0,.18)
        _               => const Color(0x2E000000), // rgba(0,0,0,.18)
      };

  Color _badgeFg(KaalQuadrant q) => switch (q) {
        KaalQuadrant.q3 => KaalColors.q3,
        KaalQuadrant.q4 => KaalColors.q4,
        _               => Colors.black,
      };

  @override
  Widget build(BuildContext context) {
    final q = widget.quadrant;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? KaalMotion.scalePressed : 1.0,
        duration: KaalMotion.fastPress,
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: q.gradient,
            ),
            borderRadius: KaalShape.card,
            border: Border.all(width: 0.5, color: q.borderColor),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 14, 11, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // qc-top: icon + body(label + meta)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: q.iconBg,
                            borderRadius: KaalShape.sgrpIcon,
                          ),
                          alignment: Alignment.center,
                          child: Text(widget.icon, style: const TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, right: 33),
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: Color(0xE6000000),
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.meta != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Text(
                          widget.meta!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: q == KaalQuadrant.q4
                                ? const Color(0x61000000)
                                : const Color(0x99000000),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                    if (widget.badgeText != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _badgeBg(q),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.badgeText!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _badgeFg(q),
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // qc-bottom: progress bar + count in the same row
              Positioned(
                bottom: 8,
                left: 11,
                right: 11,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.progressFraction != null) ...[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: SizedBox(
                            height: 3,
                            child: Stack(
                              children: [
                                Container(color: const Color(0x26000000)),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: widget.progressFraction!.clamp(0.0, 1.0),
                                  child: Container(
                                    color: q == KaalQuadrant.q4
                                        ? const Color(0x59000000)
                                        : const Color(0x73000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else
                      const Spacer(),
                    Text(
                      '${widget.count}',
                      style: const TextStyle(
                        fontFamily: 'Fraunces',
                        fontVariations: [FontVariation('wght', 700)],
                        fontSize: 8,
                        color: Color(0xD9000000),
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
