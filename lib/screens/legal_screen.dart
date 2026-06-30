import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/add_back_button.dart';
import '../widgets/kaal_top_bar.dart';
import '../widgets/wallpaper_background.dart';

enum LegalTab { terms, privacy, copyright, support, deletion, dataInfo }

class LegalScreen extends ConsumerStatefulWidget {
  /// Which legal document to show.
  final LegalTab tab;
  const LegalScreen({super.key, this.tab = LegalTab.terms});

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends ConsumerState<LegalScreen> {
  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;
    final tab = widget.tab;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: switch (tab) {
              LegalTab.terms     => 'Terms of Service',
              LegalTab.privacy   => 'Privacy Policy',
              LegalTab.copyright => 'Copyright & Licenses',
              LegalTab.support   => 'Support & Help',
              LegalTab.deletion  => 'Account & Data Deletion',
              LegalTab.dataInfo  => 'Data, Permissions & Ads',
            },
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, safeBot + 32),
              child: switch (tab) {
                LegalTab.terms     => _TermsContent(colors: colors),
                LegalTab.privacy   => _PrivacyContent(colors: colors),
                LegalTab.copyright => _CopyrightContent(colors: colors),
                LegalTab.support   => _SupportContent(colors: colors),
                LegalTab.deletion  => _DeletionContent(colors: colors),
                LegalTab.dataInfo  => _DataInfoContent(colors: colors),
              },
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ── Shared text styles ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final KaalColors colors;
  const _Section({required this.title, required this.body, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w700, color: colors.ink, height: 1.5)),
        const SizedBox(height: 4),
        Text(body,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: colors.ink2, height: 1.75)),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _Header({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text,
            style: TextStyle(fontFamily: 'Inter', fontSize: 17,
                fontWeight: FontWeight.w700, color: colors.ink, height: 1.3)),
        const SizedBox(height: 4),
        Divider(color: colors.bdr, thickness: 0.5),
      ]),
    );
  }
}

// ── Terms of Service ──────────────────────────────────────────────────────────

class _TermsContent extends StatelessWidget {
  final KaalColors colors;
  const _TermsContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Kaal — Terms of Service', colors: colors),
      Text('Effective date: June 19, 2026  ·  Version 1.0',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: '1. Acceptance of Terms',
        body: 'By downloading, installing, or using the Kaal application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App. These Terms constitute a legally binding agreement between you and Port443 LLC, the operator of the Kaal application ("Company", "we", "us", or "our").',
        colors: colors,
      ),

      _Section(
        title: '2. Eligibility',
        body: 'You must be at least 13 years of age to use this App. By creating an account or using the App, you represent and warrant that you meet this age requirement. If you are under 18, you represent that your parent or legal guardian has reviewed and agreed to these Terms on your behalf.',
        colors: colors,
      ),

      _Section(
        title: '3. Account Registration',
        body: 'You may create an account using your email address or third-party sign-in (Google, Apple, Microsoft). You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account at r.official@jumbarthi.com.',
        colors: colors,
      ),

      _Section(
        title: '4. Subscriptions & In-App Purchases',
        body: 'Kaal offers a free tier and a premium subscription ("Kaal Pro"). Kaal Pro subscriptions are billed through the Apple App Store or Google Play Store.\n\n'
            '• Monthly plan: prices displayed at checkout, billed monthly.\n'
            '• Annual plan: prices displayed at checkout, billed once per year.\n\n'
            'Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage or cancel your subscription anytime in your device\'s App Store or Play Store account settings. No refunds are issued for unused portions of a subscription period unless required by applicable law.',
        colors: colors,
      ),

      _Section(
        title: '5. Free Trial',
        body: 'Where offered, a free trial of Kaal Pro will automatically convert to a paid subscription at the end of the trial period unless cancelled before the trial ends. You will not be charged during the free trial period.',
        colors: colors,
      ),

      _Section(
        title: '6. Restore Purchase',
        body: 'If you previously purchased Kaal Pro and need to restore access on a new device, go to Profile → Edit profile → Restore purchase. Restore Purchase is only available for purchases made through the same App Store or Play Store account.',
        colors: colors,
      ),

      _Section(
        title: '7. License',
        body: 'Subject to these Terms, we grant you a limited, non-exclusive, non-transferable, revocable license to use the App for your personal, non-commercial purposes. You may not copy, modify, distribute, sell, or lease any part of the App, nor may you reverse engineer or attempt to extract the source code.',
        colors: colors,
      ),

      _Section(
        title: '8. User Content',
        body: 'You retain ownership of all tasks, notes, goals, and other content you create in the App ("User Content"). By using the App, you grant us a limited license to process and store your User Content solely to provide the App\'s features. We do not claim any ownership over your User Content.',
        colors: colors,
      ),

      _Section(
        title: '9. Prohibited Conduct',
        body: 'You agree not to:\n'
            '• Use the App for any unlawful purpose.\n'
            '• Attempt to gain unauthorized access to any portion of the App or its related systems.\n'
            '• Transmit any viruses, malware, or other harmful code.\n'
            '• Impersonate any person or entity.\n'
            '• Use automated means to scrape or collect data from the App.\n'
            '• Violate any applicable local, state, national, or international law.',
        colors: colors,
      ),

      _Section(
        title: '10. Termination',
        body: 'We reserve the right to suspend or terminate your access to the App at any time, with or without notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties. You may delete your account at any time in Profile → Edit profile → Delete account.',
        colors: colors,
      ),

      _Section(
        title: '11. Disclaimer of Warranties',
        body: 'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF VIRUSES.',
        colors: colors,
      ),

      _Section(
        title: '12. Limitation of Liability',
        body: 'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL KAAL, ITS OFFICERS, DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATED TO YOUR USE OF THE APP, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. OUR TOTAL LIABILITY TO YOU SHALL NOT EXCEED THE AMOUNT YOU PAID US IN THE 12 MONTHS PRECEDING THE CLAIM.',
        colors: colors,
      ),

      _Section(
        title: '13. Governing Law',
        body: 'These Terms are governed by the laws of India, without regard to its conflict of law provisions. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the courts located in Hyderabad, India.',
        colors: colors,
      ),

      _Section(
        title: '14. Changes to Terms',
        body: 'We may update these Terms from time to time. We will notify you of material changes via in-app notification or email. Continued use of the App after any changes constitutes your acceptance of the new Terms.',
        colors: colors,
      ),

      _Section(
        title: '15. Contact',
        body: 'If you have questions about these Terms, please contact us at:\nr.official@jumbarthi.com',
        colors: colors,
      ),
    ]);
  }
}

// ── Privacy Policy ────────────────────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  final KaalColors colors;
  const _PrivacyContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Kaal — Privacy Policy', colors: colors),
      Text('Effective date: June 19, 2026  ·  Version 1.0',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: '1. Introduction',
        body: 'Kaal, operated by Port443 LLC ("we", "us", or "our"), is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the Kaal application. Please read this policy carefully. If you disagree with its terms, please discontinue use of the App.',
        colors: colors,
      ),

      _Section(
        title: '2. Information We Collect',
        body: 'We collect the following categories of information:\n\n'
            'Account Information: When you create an account, we collect your email address and display name. If you sign in with Google, Apple, or Microsoft, we receive the profile information you authorise.\n\n'
            'App Data: Tasks, habits, goals, notes, calendar events, and other content you create in the App.\n\n'
            'Usage Data: Information about how you interact with the App, including features used, session duration, and crash logs. This data is collected in aggregated or anonymised form.\n\n'
            'Device Information: Device type, operating system version, and unique device identifiers for crash reporting and analytics.\n\n'
            'Payment Information: We do not collect or store your payment card details. All payments are processed by Apple App Store or Google Play Store under their respective privacy policies.',
        colors: colors,
      ),

      _Section(
        title: '3. How We Use Your Information',
        body: 'We use the information we collect to:\n'
            '• Provide, maintain, and improve the App.\n'
            '• Sync your data across your devices.\n'
            '• Send you service-related notifications (e.g., reminders you set).\n'
            '• Respond to your support requests.\n'
            '• Detect and prevent fraud, abuse, and security issues.\n'
            '• Comply with legal obligations.\n\n'
            'We do not use your App Data (tasks, notes, habits) for advertising purposes and do not sell it to third parties.',
        colors: colors,
      ),

      _Section(
        title: '4. Data Storage & Security',
        body: 'Your data is stored locally on your device and, when sync is enabled, on secured cloud servers (Supabase). We use industry-standard encryption (TLS in transit, AES-256 at rest) to protect your data. No method of transmission over the internet is 100% secure, however, and we cannot guarantee absolute security.',
        colors: colors,
      ),

      _Section(
        title: '5. Third-Party Services',
        body: 'The App uses the following third-party services which have their own privacy policies:\n\n'
            '• Supabase — cloud database and authentication.\n'
            '• Google Sign-In / Google APIs — if you connect Google Calendar or Gmail.\n'
            '• Apple Sign-In — if you sign in with Apple.\n'
            '• Microsoft Authentication — if you sign in with Microsoft.\n'
            '• Anthropic / OpenAI — process the text you submit to AI features.\n'
            '• Google AdMob — serves ads to free-plan users (see "Advertising" below).\n'
            '• PostHog — anonymous, opt-out usage analytics.\n\n'
            'We encourage you to review the privacy policies of these services. We are not responsible for the data practices of third-party services.',
        colors: colors,
      ),

      _Section(
        title: '6. Data Sharing',
        body: 'We do not sell, trade, or rent your personal information to third parties. We may share information with:\n\n'
            '• Service providers who assist us in operating the App (e.g., cloud hosting, crash analytics), bound by confidentiality agreements.\n'
            '• Law enforcement or government authorities when required by applicable law.\n'
            '• A successor entity in the event of a merger, acquisition, or sale of assets, with prior notice to you.',
        colors: colors,
      ),

      _Section(
        title: '7. Your Rights & Choices',
        body: 'Depending on your location, you may have the following rights regarding your personal data:\n\n'
            '• Access: Request a copy of the data we hold about you.\n'
            '• Correction: Request correction of inaccurate data.\n'
            '• Deletion: Request deletion of your account and associated data. Go to Profile → Edit profile → Delete account. Data is deleted within 30 days.\n'
            '• Portability: Request an export of your data in a machine-readable format.\n'
            '• Opt-out: You can disable optional analytics in Settings → Privacy.\n\n'
            'To exercise these rights, contact us at r.official@jumbarthi.com.',
        colors: colors,
      ),

      _Section(
        title: '8. GDPR (European Users)',
        body: 'If you are located in the European Economic Area (EEA), you have additional rights under the General Data Protection Regulation (GDPR). Our lawful basis for processing your data is:\n\n'
            '• Contract performance — to provide the App features you requested.\n'
            '• Legitimate interests — to improve the App and prevent fraud.\n'
            '• Consent — for optional features such as analytics.\n\n'
            'You have the right to lodge a complaint with your local data protection authority.',
        colors: colors,
      ),

      _Section(
        title: '9. CCPA (California Users)',
        body: 'If you are a California resident, the California Consumer Privacy Act (CCPA) grants you the right to know what personal information we collect, the right to delete your personal information, and the right to opt out of the sale of your personal information. We do not sell personal information. To submit a request, contact r.official@jumbarthi.com.',
        colors: colors,
      ),

      _Section(
        title: '10. Children\'s Privacy',
        body: 'The App is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information without parental consent, we will delete it. If you believe a child under 13 has provided us with personal information, contact us at r.official@jumbarthi.com.',
        colors: colors,
      ),

      _Section(
        title: '11. Data Retention',
        body: 'We retain your data for as long as your account is active or as needed to provide the App services. If you delete your account, we will delete or anonymise your personal data within 30 days, except where we are required to retain it for legal or compliance purposes.',
        colors: colors,
      ),

      _Section(
        title: '12. Changes to This Policy',
        body: 'We may update this Privacy Policy periodically. We will notify you of material changes via in-app notification or email at least 30 days before the change takes effect. The "Effective date" at the top of this page indicates when the policy was last revised.',
        colors: colors,
      ),

      _Section(
        title: '13. Advertising',
        body: 'The free plan of Kaal displays advertisements provided by Google AdMob. To serve '
            'ads, AdMob may collect and use a device advertising identifier and limited device '
            'information. Where required by law, we will request your consent before showing '
            'personalized ads; you may also reset or limit the advertising identifier in your '
            'device settings.\n\n'
            'We do not share your tasks, notes, or other personal content with advertisers. '
            'Kaal Pro is entirely ad-free — upgrading removes all advertising. For more, see '
            'Google\'s policies at policies.google.com/technologies/ads.',
        colors: colors,
      ),

      _Section(
        title: '14. Contact Us',
        body: 'If you have questions, concerns, or requests regarding this Privacy Policy, please contact our Data Protection contact at:\n\nr.official@jumbarthi.com\n\nKaal — a product of Port443 LLC\nHyderabad, India',
        colors: colors,
      ),
    ]);
  }
}

// ── Copyright & Licenses ──────────────────────────────────────────────────────

class _CopyrightContent extends StatelessWidget {
  final KaalColors colors;
  const _CopyrightContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Kaal — Copyright & Licenses', colors: colors),
      Text('Effective date: June 19, 2026  ·  Version 1.0',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: '1. Copyright',
        body: '© 2026 Port443 LLC. All rights reserved.\n\n'
            'The Kaal application, including its source code, design, user interface, graphics, '
            'layout, text, and all other content (collectively, the "Materials"), is the '
            'exclusive property of Port443 LLC and is protected by copyright, trade dress, and '
            'other intellectual property laws of India and other jurisdictions.',
        colors: colors,
      ),

      _Section(
        title: '2. Trademarks',
        body: 'Kaal™, the Kaal logo, and "Execution OS for high performers" are trademarks of '
            'Port443 LLC. You may not use these marks without our prior written permission. All '
            'other product and company names mentioned in the App may be trademarks of their '
            'respective owners.',
        colors: colors,
      ),

      _Section(
        title: '3. Restrictions',
        body: 'Except as expressly permitted by these terms or by applicable law, you may not '
            'copy, reproduce, modify, adapt, translate, distribute, publicly display, sell, '
            'lease, reverse engineer, decompile, or create derivative works from any part of the '
            'Materials without the prior written consent of Port443 LLC.',
        colors: colors,
      ),

      _Section(
        title: '4. Open-Source Software',
        body: 'Kaal is built with the Flutter framework and incorporates open-source software '
            'components, each provided under its own license. We gratefully acknowledge their '
            'authors. Key components include:\n\n'
            '• Flutter & Dart SDK — © Google LLC, BSD-3-Clause License.\n'
            '• Riverpod, go_router — MIT License.\n'
            '• Drift (SQLite ORM) — MIT License.\n'
            '• supabase_flutter — MIT License.\n'
            '• shared_preferences, url_launcher, image_picker, flutter_local_notifications, '
            'home_widget, in_app_purchase, window_manager — BSD-3-Clause / MIT Licenses.\n\n'
            'Copies of these licenses are available from each project\'s repository. A complete, '
            'machine-generated list of bundled packages and their licenses is available via the '
            'system "Licenses" page (Settings → About on supported platforms).',
        colors: colors,
      ),

      _Section(
        title: '5. Fonts',
        body: 'Kaal uses the following typefaces under the SIL Open Font License, Version 1.1:\n\n'
            '• Inter — © The Inter Project Authors (Rasmus Andersson).\n'
            '• Fraunces — © The Fraunces Project Authors (Undercase Type).\n\n'
            'The SIL Open Font License permits use, study, modification, and redistribution of '
            'these fonts. The full license text is available at https://openfontlicense.org.',
        colors: colors,
      ),

      _Section(
        title: '6. Third-Party Notices',
        body: 'Wallpaper imagery bundled with the App is either originally created by Port443 LLC '
            'or licensed for redistribution. AI features are powered by third-party providers '
            '(Anthropic, OpenAI) under their respective terms; content you submit to those '
            'features is processed by the selected provider.',
        colors: colors,
      ),

      _Section(
        title: '7. DMCA & Infringement',
        body: 'We respect the intellectual property rights of others. If you believe that '
            'material available in the App infringes your copyright, please send a notice with '
            'sufficient detail to identify the work and the alleged infringement to '
            'r.official@jumbarthi.com, and we will respond promptly.',
        colors: colors,
      ),

      _Section(
        title: '8. Contact',
        body: 'For copyright, licensing, or permission requests, contact:\n\n'
            'r.official@jumbarthi.com\n\n'
            'Kaal — a product of Port443 LLC\nHyderabad, India',
        colors: colors,
      ),
    ]);
  }
}

// ── Support & Help ────────────────────────────────────────────────────────────

class _SupportContent extends StatelessWidget {
  final KaalColors colors;
  const _SupportContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Support & Help', colors: colors),
      Text('We\'re here to help you get the most out of Kaal.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: 'Contact us',
        body: 'Email our team at r.official@jumbarthi.com. We typically respond within 1–2 '
            'business days. Please include your account email and a description of the issue '
            '(and screenshots if relevant) so we can help faster.',
        colors: colors,
      ),

      _Section(
        title: 'Report a bug or request a feature',
        body: 'Use Settings → About & Legal → "Report a bug · Request a feature" to send us '
            'feedback directly from the app. Detailed reports with the steps to reproduce help '
            'us fix things quickly.',
        colors: colors,
      ),

      _Section(
        title: 'Common questions',
        body: 'Sync isn\'t working — Make sure you\'re signed in (Settings → top of screen). '
            'Data syncs automatically over Wi-Fi or mobile data; check your connection.\n\n'
            'I didn\'t get my sign-in code — Check spam/junk. Codes expire shortly; tap "Resend" '
            'to get a new one. Make sure you entered the same email.\n\n'
            'Restore a purchase — Go to Profile → Edit profile → Restore purchase. This works for '
            'purchases made with the same App Store / Play Store account.\n\n'
            'Set up AI — Add your own OpenAI or Claude key in Settings → Integrations, or upgrade '
            'to Kaal Pro for built-in AI.\n\n'
            'Reminders not firing — Allow notifications and, on Android, enable exact alarms when '
            'prompted. Reminders re-arm automatically after a reboot.',
        colors: colors,
      ),

      _Section(
        title: 'Subscriptions & billing',
        body: 'Manage or cancel Kaal Pro anytime in your device\'s App Store or Play Store '
            'subscription settings. Billing questions about a charge are handled by Apple or '
            'Google; for everything else, email us and we\'ll do our best to help.',
        colors: colors,
      ),

      _Section(
        title: 'Privacy, data & account deletion',
        body: 'See Settings → About & Legal → Privacy Policy for how your data is handled, and '
            '"Account & Data Deletion" for how to delete your account and data.',
        colors: colors,
      ),

      _Section(
        title: 'Still need help?',
        body: 'Reach us directly:\n\nr.official@jumbarthi.com\n\n'
            'Kaal — a product of Port443 LLC\nHyderabad, India',
        colors: colors,
      ),
    ]);
  }
}

// ── Account & Data Deletion ───────────────────────────────────────────────────

class _DeletionContent extends StatelessWidget {
  final KaalColors colors;
  const _DeletionContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Account & Data Deletion', colors: colors),
      Text('You are always in control of your data.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: 'Delete your account in the app',
        body: 'Go to Profile → Edit profile → Delete account. You\'ll be asked to confirm. This '
            'permanently deletes your account and your synced content (tasks, habits, goals, '
            'notes, calendar events, and profile information).',
        colors: colors,
      ),

      _Section(
        title: 'Request deletion by email',
        body: 'If you can\'t access the app, email r.official@jumbarthi.com from the address '
            'associated with your account and ask us to delete it. We may ask you to verify '
            'ownership of the account before processing the request.',
        colors: colors,
      ),

      _Section(
        title: 'What gets deleted',
        body: 'When you delete your account, we delete:\n'
            '• Your profile and authentication record.\n'
            '• All tasks, subtasks, habits, goals, notes, and calendar events synced to your '
            'account.\n'
            '• Your Pro entitlement record on our servers.\n\n'
            'Data is deleted or irreversibly anonymised within 30 days.',
        colors: colors,
      ),

      _Section(
        title: 'What may be retained',
        body: 'We may retain limited information where required by law or for legitimate '
            'business needs — for example, transaction/billing records held by Apple or Google, '
            'and anonymised, non-identifying analytics. This information cannot be used to '
            'identify you.',
        colors: colors,
      ),

      _Section(
        title: 'Clearing local data',
        body: 'If you use Kaal without an account ("Skip — use local storage"), your data lives '
            'only on your device. Deleting the app, or clearing its storage in your device '
            'settings, removes that local data. Local data is not recoverable once removed.',
        colors: colors,
      ),

      _Section(
        title: 'Questions',
        body: 'For any data or deletion request, contact:\n\nr.official@jumbarthi.com\n\n'
            'Kaal — a product of Port443 LLC\nHyderabad, India',
        colors: colors,
      ),
    ]);
  }
}

// ── Data, Permissions & Ads (plain-language summary) ──────────────────────────

class _DataInfoContent extends StatelessWidget {
  final KaalColors colors;
  const _DataInfoContent({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Header(text: 'Data, Permissions & Ads', colors: colors),
      Text('A plain-language summary. The full detail is in the Privacy Policy.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: colors.ink3, height: 1.5)),
      const SizedBox(height: 16),

      _Section(
        title: 'What data we collect',
        body: '• Email address — to create and secure your account.\n'
            '• Your content — tasks, habits, goals, notes, and calendar events you create '
            '(synced to your account when you\'re signed in).\n'
            '• Purchase status — whether you have Kaal Pro, to unlock paid features.\n'
            '• Anonymous usage analytics — which screens/features are used, to improve the app. '
            'This is not linked to your identity and can be turned off in '
            'Settings → About & Legal → "Share anonymous usage analytics".\n\n'
            'We do not sell your data. Your content is never used for advertising.',
        colors: colors,
      ),

      _Section(
        title: 'Permissions we use & why',
        body: '• Notifications — to deliver the reminders and alarms you set.\n'
            '• Exact alarms (Android) — so time-critical task/habit reminders fire at the '
            'precise minute you chose.\n'
            '• Full-screen alarm (Android) — to show alarm-style reminders you explicitly set.\n'
            '• Run after restart — to re-arm your scheduled reminders after the device reboots.\n'
            '• Photos / camera (optional) — only if you choose a profile photo.\n\n'
            'Each permission is used only for the feature described and nothing else.',
        colors: colors,
      ),

      _Section(
        title: 'AI features',
        body: 'When you use an AI feature (Brain Dump, summaries, insights), the relevant text '
            'you submit is sent to the AI provider that powers it — Anthropic or OpenAI, or your '
            'own provider if you connect your own key in Settings → Integrations — solely to '
            'generate your result. If you never use AI features, no content is sent to any AI '
            'provider.',
        colors: colors,
      ),

      _Section(
        title: 'Ads (free plan only)',
        body: 'The free plan shows ads delivered by Google AdMob. Ads may use a device '
            'advertising identifier to limit repetition and, where you allow it, to show more '
            'relevant ads. You can reset or limit this identifier in your device settings, and '
            'where required we ask for your consent first.\n\n'
            'Kaal Pro is completely ad-free. Upgrading removes all ads.',
        colors: colors,
      ),

      _Section(
        title: 'Your choices',
        body: '• Turn off anonymous analytics in Settings → About & Legal.\n'
            '• Limit ad personalization in your device privacy settings.\n'
            '• Upgrade to Kaal Pro to remove ads entirely.\n'
            '• Delete your account and data anytime (see "Account & Data Deletion").',
        colors: colors,
      ),

      _Section(
        title: 'Learn more',
        body: 'Full details are in the Privacy Policy. Questions? '
            'r.official@jumbarthi.com\n\nKaal — a product of Port443 LLC',
        colors: colors,
      ),
    ]);
  }
}
