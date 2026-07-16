import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/providers/auth_provider.dart';
import '../../l10n/app_l10n.dart';
import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_top_bar.dart';
import '../../widgets/wallpaper_background.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = KaalTheme.of(context).colors;
    final safeBot  = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;
    // Per-user referral code derived from the account id (null when local-only).
    final code = referralCodeFor(ref.watch(currentUserProvider)?.id);

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: AppL10n.of(context).inviteFriends,
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(14, 0, 14, safeBot + 24),
              children: [
                _HeroSection(colors: colors),
                const SizedBox(height: 12),
                _ReferralLinkCard(colors: colors, code: code),
                const SizedBox(height: 12),
                _ShareButtons(colors: colors, code: code),
                const SizedBox(height: 16),
                _StatsCard(colors: colors),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}

/// Deterministic per-user referral code from the account id (a UUID). Returns
/// null for local-only users (no account ⇒ no personal link). NOTE: join
/// attribution needs a backend (`referrals` table + landing page); until then
/// the code is unique per user but the Invited/Joined stats stay 0.
String? referralCodeFor(String? uid) {
  if (uid == null || uid.isEmpty) return null;
  final clean = uid.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (clean.isEmpty) return null;
  return clean.substring(0, clean.length < 8 ? clean.length : 8).toUpperCase();
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final KaalColors colors;
  const _HeroSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 20),
      child: Column(children: [
        const Text('🎁', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 8),
        Text('Give a month, get a month',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 22,
                fontVariations: const [FontVariation('wght', 700)],
                color: colors.ink, height: 1.2)),
        const SizedBox(height: 6),
        Text('Invite a friend. When they start a trial, you both get\n1 month of Kaal Pro free.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: colors.ink3, height: 1.5)),
      ]),
    );
  }
}

// ── Referral link card ────────────────────────────────────────────────────────

class _ReferralLinkCard extends StatefulWidget {
  final KaalColors colors;
  final String? code;
  const _ReferralLinkCard({required this.colors, this.code});

  @override
  State<_ReferralLinkCard> createState() => _ReferralLinkCardState();
}

class _ReferralLinkCardState extends State<_ReferralLinkCard> {
  bool _copied = false;

  void _copy() {
    if (widget.code == null) return;
    Clipboard.setData(ClipboardData(text: 'kaal.app/join/${widget.code}'));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: c.bdr2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your referral link',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: c.ink3, height: 1)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                color: c.surf2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                  widget.code != null ? 'kaal.app/join/${widget.code}' : 'Sign in to get your link',
                  style: TextStyle(fontFamily: 'ui-monospace, monospace',
                      fontSize: 12, color: widget.code != null ? KaalColors.acc2 : c.ink3, height: 1)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _copy,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              decoration: BoxDecoration(
                color: KaalColors.acc,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_copied ? 'Copied!' : 'Copy',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                      fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ── Share buttons ─────────────────────────────────────────────────────────────

class _ShareButtons extends StatelessWidget {
  final KaalColors colors;
  final String? code;
  const _ShareButtons({required this.colors, this.code});

  String get _invite => code != null
      ? 'Join me on Kaal — https://kaal.app/join/$code'
      : 'Join me on Kaal — https://kaal.app';

  // Open the target app with the invite prefilled; fall back to copying the
  // link if the app/scheme isn't available (e.g. WhatsApp not installed).
  Future<void> _share(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {/* fall through to clipboard */}
    await Clipboard.setData(ClipboardData(text: _invite));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link copied — paste it anywhere to share',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white)),
          backgroundColor: Color(0xFF1C1C1E),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Uri.encodeComponent(_invite);
    return Column(children: [
      _ShareBtn(
        label: '📱 Share via WhatsApp',
        bg: const Color(0xFF25D366),
        textColor: Colors.white,
        onTap: () => _share(context, Uri.parse('https://wa.me/?text=$text')),
      ),
    ]);
  }
}

class _ShareBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  const _ShareBtn({required this.label, required this.bg,
      required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w600, color: textColor, height: 1)),
      ),
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final KaalColors colors;
  const _StatsCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR REFERRALS',
            style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
                color: colors.ink3, height: 1)),
        const SizedBox(height: 8),
        Row(children: [
          _StatCell(value: '0', label: 'Invited',
              bg: colors.surf2, valueColor: KaalColors.acc2),
          const SizedBox(width: 5),
          _StatCell(value: '0', label: 'Joined',
              bg: colors.surf2, valueColor: KaalColors.q2),
          const SizedBox(width: 5),
          _StatCell(value: '0', label: 'Earned',
              bg: const Color(0x14127000), valueColor: KaalColors.q2),
        ]),
      ]),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  const _StatCell({required this.value, required this.label,
      required this.bg, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Text(value,
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 18,
                  fontVariations: const [FontVariation('wght', 600)],
                  color: valueColor, height: 1)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: Colors.white54, height: 1.2)),
        ]),
      ),
    );
  }
}
