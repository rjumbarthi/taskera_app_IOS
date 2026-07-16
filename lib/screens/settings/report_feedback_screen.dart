import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/wallpaper_background.dart';

const _supportEmail = 'kaal_support@jumbarthi.com';
const _appVersion = 'v1.0.0';

// Prepopulated tab → screen / sub-screen map so reporting is one-tap easy.
const _areas = <String, List<String>>{
  'Focus': [
    'Do The Next',
    'Goals',
    'Goal detail',
    'Brain Dump',
    'Weekly Focus Review',
    'Pomodoro',
  ],
  'Tasks': [
    'Task list',
    '2×2 Matrix',
    'Task detail',
    'Add / edit task',
    'Completed',
    'Day schedule',
  ],
  'Habits': [
    'Habit list',
    'Habit detail',
    'Habit stats',
    'Add / edit habit',
    'Achievements',
  ],
  'Calendar': [
    'Month / week',
    'Day schedule',
    'Add slot',
    'Calendar sync',
    'Gmail sync',
    'Conflicts',
  ],
  'Inbox': [
    'Emails / Gmail',
    'Kaal suggestions',
    'Integrations',
    'Add task',
  ],
  'Notes': ['Notes list', 'Note editor'],
  'Profile': [
    'Overview',
    'Weekly Review',
    'Edit Profile',
    'Achievements',
    'Referral',
    'Student mode',
  ],
  'Settings': [
    'Display',
    'Tasks',
    'Features',
    'Calendar & Inbox',
    'Integrations',
    'Sync & Data',
    'Notifications',
    'About & Legal',
  ],
  'Sign in / Onboarding': ['Sign in', 'Sign up', 'Onboarding'],
  'General / Other': ['Performance', 'Crash', 'Sync', 'Other'],
};

class ReportFeedbackScreen extends ConsumerStatefulWidget {
  const ReportFeedbackScreen({super.key});

  @override
  ConsumerState<ReportFeedbackScreen> createState() =>
      _ReportFeedbackScreenState();
}

class _ReportFeedbackScreenState extends ConsumerState<ReportFeedbackScreen> {
  bool _isBug = true;
  String _tab = _areas.keys.first;
  String? _screen;
  final _descCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  String get _where => _screen != null ? '$_tab › $_screen' : _tab;

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty || _sending) return;
    setState(() => _sending = true);
    final type = _isBug ? 'Bug' : 'Feature';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '—';

    // 1) Best-effort: collect centrally in Supabase for the developers.
    var stored = false;
    try {
      await Supabase.instance.client.from('feedback').insert({
        'type': type,
        'area': _where,
        'message': desc,
        'user_email': email,
        'app_version': _appVersion,
      });
      stored = true;
    } catch (_) {}

    // 2) Fallback: open the email app prefilled to the developers.
    if (!stored) {
      final subject = Uri.encodeComponent('[Kaal $type] $_where');
      final body = Uri.encodeComponent(
        '$desc\n\n—\nWhere: $_where\nFrom: $email\nApp: Kaal $_appVersion',
      );
      final mailto = Uri.parse(
        'mailto:$_supportEmail?subject=$subject&body=$body',
      );
      bool ok = false;
      try {
        ok = await launchUrl(mailto, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!ok) {
        // 3) Last resort: copy a ready-to-send report to the clipboard.
        await Clipboard.setData(
          ClipboardData(
            text: '[Kaal $type] $_where\n\n$desc\n\nSend to: $_supportEmail',
          ),
        );
        if (mounted) setState(() => _sending = false);
        _snack('Report copied — email it to $_supportEmail');
        return;
      }
    }

    if (!mounted) return;
    setState(() => _sending = false);
    _snack(
      _isBug ? 'Thanks! Bug report sent 🐞' : 'Thanks! Feature request sent ✨',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final screens = _areas[_tab] ?? const <String>[];
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(
      children: [
        Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
                  child: Row(
                    children: [
                      AddBackButton(onTap: () => context.pop()),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'Report · Request',
                          style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontVariations: const [FontVariation('wght', 600)],
                            fontSize: 19,
                            letterSpacing: -0.5,
                            color: colors.ink,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('TYPE', colors),
                        Row(
                          children: [
                            Expanded(
                              child: _typeBtn(
                                '🐞  Bug',
                                _isBug,
                                () => setState(() => _isBug = true),
                                colors,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _typeBtn(
                                '✨  Feature',
                                !_isBug,
                                () => setState(() => _isBug = false),
                                colors,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _label('WHERE · TAB', colors),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final t in _areas.keys)
                              _chip(
                                t,
                                _tab == t,
                                () => setState(() {
                                  _tab = t;
                                  _screen = null;
                                }),
                                colors,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        _label('SCREEN · SUB-SCREEN', colors),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final s in screens)
                              _chip(
                                s,
                                _screen == s,
                                () => setState(() => _screen = s),
                                colors,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _label(
                          _isBug ? 'WHAT HAPPENED?' : 'DESCRIBE THE FEATURE',
                          colors,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 0.5, color: colors.bdr),
                          ),
                          child: TextField(
                            controller: _descCtrl,
                            minLines: 4,
                            maxLines: 8,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: colors.ink,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _isBug
                                  ? 'Steps to reproduce, what you expected vs. what you saw…'
                                  : 'What would help you, and why?',
                              hintStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: colors.ink3,
                                height: 1.5,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Sent to the Kaal team with “$_where” · your email · app $_appVersion',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: colors.ink3,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),

                        GestureDetector(
                          onTap: _submit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: KaalColors.acc,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            alignment: Alignment.center,
                            child: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isBug
                                        ? 'Send bug report'
                                        : 'Send feature request',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String t, KaalColors colors) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      t,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colors.ink3,
      ),
    ),
  );

  Widget _typeBtn(
    String label,
    bool on,
    VoidCallback onTap,
    KaalColors colors,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: on ? KaalColors.accBg : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          width: 0.5,
          color: on ? const Color(0x4D0A84FF) : colors.bdr,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: on ? KaalColors.acc2 : colors.ink2,
        ),
      ),
    ),
  );

  Widget _chip(String label, bool on, VoidCallback onTap, KaalColors colors) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          decoration: BoxDecoration(
            color: on ? KaalColors.accBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 0.5,
              color: on ? const Color(0x4D0A84FF) : colors.bdr,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: on ? FontWeight.w600 : FontWeight.w400,
              color: on ? KaalColors.acc2 : colors.ink2,
              height: 1,
            ),
          ),
        ),
      );
}
