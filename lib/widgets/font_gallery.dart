import 'package:flutter/material.dart';
import 'kaal_logo.dart';

// Bare content widget — no Scaffold. Rendered inside AppShell for Phase 2 testing.
class FontGalleryScreen extends StatelessWidget {
  const FontGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo preview ──────────────────────────────────────────────────
          const Center(child: KaalLogo(size: 90)),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'KaalLogo(size: 90)  ·  assets/logo/kaal_logo.png',
              style: TextStyle(color: Color(0xFF5A5A62), fontSize: 10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              KaalLogo(size: 56),
              SizedBox(width: 24),
              KaalLogo(size: 36),
              SizedBox(width: 24),
              KaalLogo(size: 20),
            ],
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '56  ·  36  ·  20',
              style: TextStyle(color: Color(0xFF5A5A62), fontSize: 10),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0x24FFFFFF)),
          const SizedBox(height: 24),
          // ── Font test ─────────────────────────────────────────────────────
          const Text(
            'Font loading test — Fraunces should look serif, Inter sans-serif.',
            style: TextStyle(color: Color(0xFF7A7A86), fontSize: 12),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _FontSample(label: 'Fraunces', family: 'Fraunces')),
              Expanded(child: _FontSample(label: 'Inter', family: 'Inter')),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Color(0x24FFFFFF)),
          const SizedBox(height: 24),
          const Text(
            'Type scale',
            style: TextStyle(color: Color(0xFF7A7A86), fontSize: 11),
          ),
          const SizedBox(height: 12),
          ..._typeScaleRows(),
        ],
      ),
    );
  }

  static List<Widget> _typeScaleRows() {
    const sizes = <(String, double)>[
      ('hero  30', 30),
      ('2xl   23', 23),
      ('xl    19', 19),
      ('lg    15', 15),
      ('md    13', 13),
      ('sm    11', 11),
      ('xs     9', 9),
    ];
    return sizes
        .map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    e.$1,
                    style: const TextStyle(
                      color: Color(0xFF5A5A62),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Text(
                  'The quick brown fox',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: e.$2,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _FontSample extends StatelessWidget {
  final String label;
  final String family;

  const _FontSample({required this.label, required this.family});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7A7A86), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          'Kaal',
          style: TextStyle(
            fontFamily: family,
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
