import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/integrations_provider.dart';
import '../../data/providers/feature_flags_provider.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/google_access_sheet.dart';
import '../../l10n/app_l10n.dart';

class CalSyncScreen extends ConsumerStatefulWidget {
  const CalSyncScreen({super.key});

  @override
  ConsumerState<CalSyncScreen> createState() => _CalSyncScreenState();
}

class _CalSyncScreenState extends ConsumerState<CalSyncScreen> {
  bool _prepTasks    = true;
  bool _conflictDet  = true;
  bool _connected    = false;
  bool _connecting   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(integrationsProvider.notifier).checkStatus();
      if (mounted) {
        setState(() => _connected = ref.read(integrationsProvider).googleCalendarConnected);
      }
    });
  }

  Future<void> _connect() async {
    if (!ref.read(calendarEnabledProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Google Calendar sync — coming soon.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (!await confirmGoogleAccess(context, GoogleAccess.calendar) || !mounted) return;
    setState(() => _connecting = true);
    try {
      final ok = await ref.read(integrationsProvider.notifier).connectGoogleCalendar();
      if (!mounted) return;
      setState(() { _connected = ok; _connecting = false; });
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not connect — no token received. Check Google Cloud Console.'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _connecting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connection failed. Please try again.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _disconnect() async {
    await ref.read(integrationsProvider.notifier).disconnectCalendar();
    if (mounted) setState(() => _connected = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
          child: Row(
            children: [
              AddBackButton(onTap: () => context.pop()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n.of(context).calendarSync, style: TextStyle(fontFamily: 'Fraunces', fontVariations: [FontVariation('wght', 600)], fontSize: 19, letterSpacing: -0.5, color: colors.ink, height: 1.1)),
                    Text('One-way · Google Calendar → Kaal (read-only)', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: colors.ink3, height: 1.2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, MediaQuery.of(context).padding.bottom + 24),
            children: [
              // Google Calendar connection card
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: _connected ? const Color(0x127FBA00) : const Color(0x120A84FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: _connected ? const Color(0x407FBA00) : const Color(0x400A84FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x1F0A84FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, size: 16, color: KaalColors.acc2),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Google Calendar', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                              Text(
                                _connected ? '● Connected · Syncs every 15 min · 5 min in-app' : '○ Not connected',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                                    color: _connected ? colors.successFg : colors.ink3)),
                            ],
                          ),
                        ),
                        if (_connected)
                          GestureDetector(
                            onTap: _disconnect,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(9, 4, 9, 4),
                              decoration: BoxDecoration(color: const Color(0x1AFF453A), borderRadius: BorderRadius.circular(6)),
                              child: Text(AppL10n.of(context).disconnect, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFFFF6B6B))),
                            ),
                          ),
                      ],
                    ),
                    if (_connected) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _CountCell(value: '0',  label: 'Events → Tasks',   valueColor: KaalColors.acc2),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _connecting ? null : _connect,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: KaalColors.acc, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: _connecting
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(AppL10n.of(context).connectGoogleCal,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Event → task suggestions — only when connected; no fake previews.
              if (_connected) ...[
                Text(AppL10n.of(context).eventsToTaskSugg.toUpperCase(),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: const Color(0x0D0A84FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 0.5, color: const Color(0x330A84FF)),
                  ),
                  child: Text('Synced events will appear here after your next sync.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: colors.ink3, height: 1.4)),
                ),
                const SizedBox(height: 14),
              ],
              // Sync settings
              Text(AppL10n.of(context).syncSettings.toUpperCase(),
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: colors.ink3)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                decoration: BoxDecoration(
                  color: colors.surf2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.5, color: colors.bdr0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingRow(label: 'Suggest prep tasks from events', value: _prepTasks,
                      onChanged: (v) => setState(() => _prepTasks = v), colors: colors),
                    _SettingRow(label: 'Conflict detection', value: _conflictDet,
                      onChanged: (v) => setState(() => _conflictDet = v), colors: colors, isLast: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountCell extends StatelessWidget {
  final String value, label;
  final Color valueColor;
  const _CountCell({required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = KaalTheme.of(context).colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 0.5, color: colors.bdr0),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w700, color: valueColor, height: 1)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: colors.labelMuted)),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final KaalColors colors;
  final bool isLast;
  const _SettingRow({required this.label, required this.value, required this.onChanged, required this.colors, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(width: 0.5, color: colors.bdr)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: colors.ink2))),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 21,
        decoration: BoxDecoration(
          color: value ? KaalColors.acc : const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      ),
    );
  }
}
