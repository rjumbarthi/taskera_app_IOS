import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_l10n.dart';

import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/add_back_button.dart';
import '../widgets/kaal_top_bar.dart';
import '../widgets/wallpaper_background.dart';
import '../routing/routes.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _annual = true;

  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          KaalTopBar(
            title: 'Kaal Pro',
            leading: AddBackButton(onTap: () => context.pop()),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, safeBot + 16),
              children: [
                _HeroSection(colors: colors),
                const SizedBox(height: 20),
                _FeaturesList(colors: colors),
                const SizedBox(height: 14),
                _PriceToggle(annual: _annual, colors: colors,
                    onChanged: (v) => setState(() => _annual = v)),
                const SizedBox(height: 12),
                _TrialButton(),
                const SizedBox(height: 8),
                _UpiButton(colors: colors),
                const SizedBox(height: 8),
                Text('No charge until trial ends. Cancel anytime in App Store or Play Store settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: colors.ink3, height: 1.5)),
                const SizedBox(height: 4),
                Text('To cancel: App Store / Play Store → Subscriptions → Kaal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: colors.ink2, height: 1.4)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: Text(AppL10n.of(context).maybeLater,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                            color: colors.ink3, height: 1))),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppL10n.of(context).checkingPurchases,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                              color: Colors.white)),
                      backgroundColor: const Color(0xFF1C1C1E),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text(AppL10n.of(context).restorePurchase,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                            color: colors.ink3, height: 1))),
                  ),
                ),
                const SizedBox(height: 10),
                _ReferralNudge(colors: colors),
              ],
            ),
          ),
        ]),
      ),
    ]);
  }
}


// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final KaalColors colors;
  const _HeroSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('✦',
          style: TextStyle(fontFamily: 'Inter', fontSize: 28,
              color: colors.ink, height: 1.2)),
      const SizedBox(height: 8),
      Text('Kaal Pro',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 24,
              fontVariations: const [FontVariation('wght', 700)],
              color: colors.ink, height: 1.2)),
      const SizedBox(height: 4),
      Text('Unlock unlimited AI + all premium features',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
              color: colors.ink3, height: 1.5)),
    ]);
  }
}

// ── Features list ─────────────────────────────────────────────────────────────

class _FeaturesList extends StatelessWidget {
  final KaalColors colors;
  const _FeaturesList({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 0.5, color: colors.bdr2),
      ),
      child: Column(children: [
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0xFF5856D6), KaalColors.acc],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          iconSvgPath: Icons.star_rounded,
          iconColor: Colors.white,
          title: 'Unlimited AI features',
          sub: 'Brain Dump, auto-schedule, AI scoring',
          trailLabel: '∞',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x240A84FF), Color(0x240A84FF)]),
          iconSvgPath: Icons.grid_view_rounded,
          iconColor: KaalColors.acc2,
          title: 'Home screen widget',
          sub: 'Q1 tasks at a glance, streak counter',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1F7FBA00), Color(0x1F7FBA00)]),
          iconSvgPath: Icons.upload_rounded,
          iconColor: KaalColors.q2,
          title: 'Export & share',
          sub: 'Task lists, weekly review, EOD report',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1FFFB900), Color(0x1FFFB900)]),
          iconSvgPath: Icons.email_rounded,
          iconColor: KaalColors.q4,
          title: 'Gmail & Cal deep sync',
          sub: 'Unlimited accounts, real-time AI triage',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
        const SizedBox(height: 9),
        _FeatureRow(
          iconBg: const LinearGradient(colors: [Color(0x1FBF5AF2), Color(0x1FBF5AF2)]),
          iconSvgPath: Icons.star_outline_rounded,
          iconColor: const Color(0xFFBF5AF2),
          title: 'Pro badge + identity',
          sub: 'Custom themes, priority support',
          trailLabel: '✓',
          trailColor: KaalColors.q2,
        ),
      ]),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final Gradient iconBg;
  final IconData iconSvgPath;
  final Color iconColor;
  final String title;
  final String sub;
  final String trailLabel;
  final Color trailColor;
  const _FeatureRow({required this.iconBg, required this.iconSvgPath,
      required this.iconColor, required this.title, required this.sub,
      required this.trailLabel, required this.trailColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          gradient: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconSvgPath, color: iconColor, size: 12),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1.2)),
          Text(sub,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                  color: colors.ink3, height: 1.3)),
        ]),
      ),
      Text(trailLabel,
          style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w700, color: trailColor, height: 1)),
    ]);
  }
}

// ── Price toggle ──────────────────────────────────────────────────────────────

class _PriceToggle extends StatelessWidget {
  final bool annual;
  final KaalColors colors;
  final ValueChanged<bool> onChanged;
  const _PriceToggle({required this.annual, required this.colors, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        _PlanTab(
          label: 'Annual',
          sub: '₹249/mo · Save 50%',
          selected: annual,
          onTap: () => onChanged(true),
        ),
        _PlanTab(
          label: 'Monthly',
          sub: '₹499/mo',
          selected: !annual,
          onTap: () => onChanged(false),
        ),
      ]),
    );
  }
}

class _PlanTab extends StatelessWidget {
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTab({required this.label, required this.sub,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? KaalColors.acc : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Text(label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : colors.ink2, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                    color: selected
                        ? Colors.white.withAlpha(191)
                        : colors.ink3,
                    height: 1.3)),
          ]),
        ),
      ),
    );
  }
}

// ── Trial button ──────────────────────────────────────────────────────────────

class _TrialButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5856D6), KaalColors.acc],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(color: Color(0x665856D6), blurRadius: 18, offset: Offset(0, 4)),
          ],
        ),
        alignment: Alignment.center,
        child: const Text('Start 7-day free trial →',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
      ),
    );
  }
}

// ── UPI button ────────────────────────────────────────────────────────────────

class _UpiButton extends StatelessWidget {
  final KaalColors colors;
  const _UpiButton({required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: colors.surf2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(width: 0.5, color: colors.bdr2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF097939),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text('UPI',
                style: TextStyle(fontFamily: 'Inter', fontSize: 7,
                    fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
          ),
          const SizedBox(width: 8),
          Text('Pay with UPI (India)',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w600, color: colors.ink, height: 1)),
        ]),
      ),
    );
  }
}

// ── Referral nudge ────────────────────────────────────────────────────────────

class _ReferralNudge extends StatelessWidget {
  final KaalColors colors;
  const _ReferralNudge({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colors.surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(children: [
        Text("Know someone who'd love Kaal?",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: colors.ink3, height: 1.4)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => context.push(KaalRoutes.referral),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            decoration: BoxDecoration(
              color: colors.surf2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('🎁 Invite → both get 1 month free',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: KaalColors.acc2, height: 1)),
          ),
        ),
      ]),
    );
  }
}
