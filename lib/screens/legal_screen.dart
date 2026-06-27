import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_theme.dart';
import '../widgets/add_back_button.dart';
import '../widgets/kaal_top_bar.dart';
import '../widgets/wallpaper_background.dart';

class LegalScreen extends ConsumerStatefulWidget {
  /// Which tab to open first. true = Terms of Service, false = Privacy Policy.
  final bool showTerms;
  const LegalScreen({super.key, this.showTerms = true});

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends ConsumerState<LegalScreen> {
  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;
    final showTerms = widget.showTerms;

    return Stack(children: [
      Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KaalTopBar(
            title: showTerms ? 'Terms of Service' : 'Privacy Policy',
            leading: AddBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, safeBot + 32),
              child: showTerms
                  ? _TermsContent(colors: colors)
                  : _PrivacyContent(colors: colors),
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
        body: 'By downloading, installing, or using the Kaal application ("App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use the App. These Terms constitute a legally binding agreement between you and Kaal ("Company", "we", "us", or "our").',
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
        body: 'Kaal ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the Kaal application. Please read this policy carefully. If you disagree with its terms, please discontinue use of the App.',
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
            '• Microsoft Authentication — if you sign in with Microsoft.\n\n'
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
        title: '13. Contact Us',
        body: 'If you have questions, concerns, or requests regarding this Privacy Policy, please contact our Data Protection contact at:\n\nr.official@jumbarthi.com\n\nKaal\nHyderabad, India',
        colors: colors,
      ),
    ]);
  }
}
