import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/routes.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import 'kaal_sheet.dart';

/// Which Google permission the user is about to grant.
enum GoogleAccess { gmail, calendar }

class _Info {
  final String title, scope, googleWording;
  final List<String> does, never;
  const _Info(this.title, this.scope, this.googleWording, this.does, this.never);
}

// Wording mirrors the Google consent screen and the in-app privacy policy
// (legal_screen.dart → "Google User Data & Gmail (Limited Use)"). Keep in sync.
const _info = {
  GoogleAccess.gmail: _Info(
    'Connect Gmail',
    'gmail.readonly',
    'View your email messages and settings',
    [
      'Lists your unread messages (sender, subject, date) in your Inbox.',
      'Reads a message\'s contents only when you open it, so you can turn it into a task or note.',
    ],
    [
      'Send, modify, label or delete your email.',
      'Store your email on our servers — only tasks or notes you create are saved.',
      'Use it for ads, sell it, or train AI / machine-learning models.',
    ],
  ),
  GoogleAccess.calendar: _Info(
    'Connect Google Calendar',
    'calendar.events.readonly',
    'View events on all your calendars',
    [
      'Shows your upcoming events (next 7 days) alongside your tasks.',
      'Lets you see conflicts between events and your planned work.',
    ],
    [
      'Create, edit or delete events in your Google Calendar.',
      'Store your calendar on our servers.',
      'Use it for ads, sell it, or train AI / machine-learning models.',
    ],
  ),
};

/// Explains the requested Google permission in plain text before the OAuth
/// screen opens. Resolves to `true` only when the user taps "Continue to Google".
Future<bool> confirmGoogleAccess(BuildContext context, GoogleAccess kind) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GoogleAccessSheet(info: _info[kind]!),
  );
  return ok ?? false;
}

class _GoogleAccessSheet extends StatelessWidget {
  final _Info info;
  const _GoogleAccessSheet({required this.info});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    final bottom = MediaQuery.of(context).padding.bottom;
    return KaalSheetSurface(
      child: Container(
        decoration: BoxDecoration(
          color: colors.surf,
          border: Border(top: BorderSide(width: 0.5, color: colors.bdr)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.title,
                  style: TextStyle(fontFamily: 'Fraunces', fontVariations: const [FontVariation('wght', 600)], fontSize: 21, color: colors.ink)),
              const SizedBox(height: 4),
              Text('Kaal is asking Google for one read-only permission.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3)),
              const SizedBox(height: 14),
              // Permission Google will display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x120A84FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERMISSION',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: colors.ink3)),
                    const SizedBox(height: 4),
                    Text('Google will show: "${info.googleWording}"',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text('Scope: ${info.scope} (read-only)',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Block(label: 'WHAT KAAL DOES WITH IT', items: info.does, icon: Icons.check_rounded, color: colors.successFg, colors: colors),
              const SizedBox(height: 12),
              _Block(label: 'WHAT KAAL NEVER DOES', items: info.never, icon: Icons.close_rounded, color: const Color(0xFFFF6B6B), colors: colors),
              const SizedBox(height: 12),
              Text(
                'Kaal\'s use of information received from Google APIs adheres to the Google API Services User Data Policy, including the Limited Use requirements. '
                'You can disconnect at any time in Settings → Integrations.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.4),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop(false);
                  router.push(KaalRoutes.legal);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Read the Privacy Policy',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: KaalColors.acc)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.surf2,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.5, color: colors.bdr0),
                        ),
                        child: Text('Cancel', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Continue to Google',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String label;
  final List<String> items;
  final IconData icon;
  final Color color;
  final KaalColors colors;
  const _Block({required this.label, required this.items, required this.icon, required this.color, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: colors.ink3)),
        const SizedBox(height: 6),
        for (final t in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 14, color: color)),
                const SizedBox(width: 8),
                Expanded(child: Text(t, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink2, height: 1.35))),
              ],
            ),
          ),
      ],
    );
  }
}
