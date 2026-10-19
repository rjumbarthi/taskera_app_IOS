import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers/ai_access_provider.dart';
import '../routing/routes.dart';
import '../services/ad_service.dart';
import '../services/ai_service.dart';
import '../util/platform_layout.dart';
import '../theme/taskera_colors.dart';
import '../theme/taskera_theme.dart';

/// On-demand "TaskEra AI" insight card. Tapping **Generate** calls the built-in AI
/// (the `ai-proxy` edge function → Claude/OpenAI) with [input] and renders the
/// returned insights. It's on-demand by design so it never auto-burns the daily
/// AI quota on every screen view. Replaces the old hardcoded "✦ TaskEra AI" mockups.
class AiInsightCard extends ConsumerStatefulWidget {
  /// The real context the AI reasons over (built from the screen's live data).
  final String input;

  /// One-line prompt shown before the user generates.
  final String hint;

  final EdgeInsetsGeometry? margin;

  /// Shows a small "✦ PRO" chip confirming actual Pro-subscriber status —
  /// separate from the existing "· PRO" suffix below (which is a *gate*
  /// indicator for locked/free users and disappears once AI is unlocked by
  /// any means, including a watched ad or a personal API key, not just a
  /// real subscription). Off by default so existing call sites are unaffected.
  final bool showProBadge;

  const AiInsightCard({
    super.key,
    required this.input,
    this.hint = 'Get a TaskEra AI insight on this',
    this.margin,
    this.showProBadge = false,
  });

  @override
  ConsumerState<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends ConsumerState<AiInsightCard> {
  bool _loading = false;
  String? _error;
  bool _generated = false;
  bool _adUnlock = false; // a rewarded ad granted one free insight
  List<Map<String, String>> _insights = const [];

  Future<void> _watchAdForInsight() async {
    final ad = ref.read(adServiceProvider);
    if (!ad.rewardedReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ad not ready yet — try again in a moment.')),
        );
      }
      return;
    }
    final earned = await ad.showRewarded();
    if (!mounted || !earned) return;
    setState(() => _adUnlock = true);
    _generate();
  }

  Future<void> _generate() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ref.read(aiServiceProvider).getInsights(widget.input);
      if (!mounted) return;
      setState(() {
        _insights = res;
        _generated = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = TaskEraTheme.of(context).colors;
    final unlocked = ref.watch(aiUnlockedProvider).valueOrNull ?? false;
    final isPro = widget.showProBadge && ref.watch(isProProvider);
    return Padding(
      padding: widget.margin ?? const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          color: const Color(0x120A84FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 0.5, color: const Color(0x400A84FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text((unlocked || _adUnlock) ? '✦ TASKERA AI' : '✦ TASKERA AI · PRO',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 0.4, color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
              if (isPro) ...[
                SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF5856D6), TaskEraColors.acc]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('✦ PRO',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9, fontWeight: FontWeight.w700,
                          color: Colors.white, height: 1)),
                ),
              ],
              const Spacer(),
              if (unlocked && _generated && !_loading)
                GestureDetector(
                  onTap: _generate,
                  child: Text('↻ Refresh',
                      style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1)),
                ),
            ]),
            SizedBox(height: 7),
            if (unlocked || _adUnlock) _body(colors) else _upgradeBody(context, colors),
          ],
        ),
      ),
    );
  }

  // Shown to free users instead of real AI output.
  Widget _upgradeBody(BuildContext context, TaskEraColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => context.push(TaskEraRoutes.paywall),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Unlock AI insights with TaskEra Pro',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600,
                      color: colors.ink, height: 1.3)),
              SizedBox(height: 2),
              Text('Or connect your own OpenAI / Claude key in Settings → Integrations.',
                  style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1.35)),
            ]),
          ),
          SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
            decoration: BoxDecoration(
              color: TaskEraColors.accBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
            ),
            child: Text('Upgrade →',
                style: TextStyle(
                    fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
                    color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
          ),
        ]),
      ),
      // Rewarded-ad path (mobile only): watch a short ad to get one insight free.
      if (isMobile) ...[
        SizedBox(height: 9),
        Divider(height: 0.5, thickness: 0.5, color: colors.bdr),
        SizedBox(height: 9),
        GestureDetector(
          onTap: _watchAdForInsight,
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Expanded(
              child: Text('▶  Watch a short ad for one AI insight',
                  style: TextStyle(
                      fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600,
                      color: colors.ink2, height: 1.3)),
            ),
            Text('Free',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11, color: colors.ink3, height: 1)),
          ]),
        ),
      ],
    ]);
  }

  Widget _body(TaskEraColors colors) {
    if (_loading) {
      return Row(children: [
        SizedBox(width: 13, height: 13,
            child: CircularProgressIndicator(strokeWidth: 1.6, color: TaskEraColors.acc2)),
        SizedBox(width: 8),
        Text('Thinking…', style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3)),
      ]);
    }
    if (_error != null) {
      return GestureDetector(
        onTap: _generate,
        behavior: HitTestBehavior.opaque,
        child: Text('$_error · tap to retry',
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: Color(0xFFFF6B6B), height: 1.4)),
      );
    }
    if (!_generated) {
      return GestureDetector(
        onTap: _generate,
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Expanded(
            child: Text(widget.hint,
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3, height: 1.4)),
          ),
          SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: TaskEraColors.accBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
            ),
            child: Text('Generate',
                style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
          ),
        ]),
      );
    }
    if (_insights.isEmpty) {
      return Text('No insight available right now — tap ↻ to retry.',
          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, color: colors.ink3, height: 1.4));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _insights.length; i++) ...[
          if (i > 0) SizedBox(height: 8),
          _InsightRow(item: _insights[i], colors: colors),
        ],
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final Map<String, String> item;
  final TaskEraColors colors;
  const _InsightRow({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? '';
    final detail = item['detail'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(title,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: colors.ink, height: 1.3)),
        if (detail.isNotEmpty) ...[
          if (title.isNotEmpty) SizedBox(height: 2),
          Text(detail,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 11.5, color: colors.ink2, height: 1.45)),
        ],
      ],
    );
  }
}
