import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/providers/calendar_provider.dart';
import '../data/providers/habits_provider.dart';
import '../data/providers/notes_provider.dart';
import '../data/providers/tasks_provider.dart';
import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_motion.dart';
import '../theme/kaal_theme.dart';

enum KaalTab { focus, tasks, habits, calendar, aiInbox, notes, search, settings, profile }

// ── Nav icon SVG strings — strokes/fills in white so ColorFilter.srcIn recolors them.

const _svgSearch =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<circle cx="11" cy="11" r="8" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '<path d="M21 21l-4.35-4.35" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>';

const _svgSettings =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>';

const _svgProfile =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<circle cx="12" cy="7" r="4" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>';

const _svgTasks =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<polyline points="9 11 12 14 22 4" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>';

const _svgHabits =
    '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="white"/>'
    '</svg>';

const _svgCalendar =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<rect x="3" y="4" width="18" height="18" rx="2" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="16" y1="2" x2="16" y2="6" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="8" y1="2" x2="8" y2="6" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="3" y1="10" x2="21" y2="10" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>';

const _svgNotes =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<polyline points="14 2 14 8 20 8" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<line x1="8" y1="13" x2="16" y2="13" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '<line x1="8" y1="17" x2="13" y2="17" stroke="white" stroke-width="1.8" stroke-linecap="round"/>'
    '</svg>';

const _svgAiInbox =
    '<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">'
    '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '<polyline points="22,6 12,13 2,6" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'
    '</svg>';

class KaalBottomNav extends ConsumerWidget {
  final KaalTab currentTab;
  final ValueChanged<KaalTab>? onTabChanged;

  const KaalBottomNav({
    super.key,
    required this.currentTab,
    this.onTabChanged,
  });

  // Whether a tab is currently unlocked. The four optional tabs unlock either
  // automatically by install age (see _applyTabUnlocks in main.dart) or manually
  // in Settings → Tabs. Locked tabs still show their icon (dimmed) so users know
  // what's coming; tapping one explains how to unlock it.
  static bool _enabled(KaalSettingsState s, KaalTab tab) => switch (tab) {
        KaalTab.habits   => s.sw('habits'),
        KaalTab.calendar => s.sw('calendar'),
        KaalTab.notes    => s.sw('notes'),
        KaalTab.aiInbox  => s.sw('inbox'),
        _                => true,
      };

  static String _tabName(KaalTab tab) => switch (tab) {
        KaalTab.habits   => 'Habits',
        KaalTab.calendar => 'Calendar',
        KaalTab.notes    => 'Notes',
        KaalTab.aiInbox  => 'Inbox',
        _                => '',
      };

  void _showLockedMessage(BuildContext context, KaalTab tab) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${_tabName(tab)} is locked. Enable it in Settings → Tabs, or it unlocks automatically in a few days.'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors         = KaalTheme.of(context).colors;
    final bottomSafeArea = MediaQuery.viewPaddingOf(context).bottom;
    final settings       = ref.watch(kaalSettingsProvider);

    // All four optional tabs are always shown (locked ones dimmed). Search,
    // Settings and Profile are reached elsewhere, never from the bottom nav.
    final visibleTabs = KaalTab.values.where((tab) => switch (tab) {
      KaalTab.focus    => true,
      KaalTab.tasks    => true,
      KaalTab.habits   => true,
      KaalTab.calendar => true,
      KaalTab.notes    => true,
      KaalTab.aiInbox  => true,
      KaalTab.search   => false,
      KaalTab.settings => false,
      KaalTab.profile  => false,
    }).toList();

    return _GlassPill(
      bottomSafeArea: bottomSafeArea,
      child: Row(
        children: [
          for (final tab in visibleTabs)
            _NavItem(
              tab: tab,
              isActive: tab == currentTab,
              enabled: _enabled(settings, tab),
              colors: colors,
              onTap: () {
                if (_enabled(settings, tab)) {
                  onTabChanged?.call(tab);
                } else {
                  _showLockedMessage(context, tab);
                }
              },
            ),
        ],
      ),
    );
  }
}

// Full-width edge-to-edge nav bar with glass backdrop blur.
class _GlassPill extends StatelessWidget {
  final Widget child;
  final double bottomSafeArea;
  const _GlassPill({required this.child, required this.bottomSafeArea});

  static const _radius = BorderRadius.only(
    topLeft:  Radius.circular(20),
    topRight: Radius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    final isLight = KaalTheme.of(context).mode == KaalThemeMode.light;
    final pillColor  = isLight ? const Color(0xD9F2F2F7) : const Color(0x8C080812);
    final borderCol  = isLight ? const Color(0x33000000) : const Color(0x33FFFFFF);
    final shadowCol  = isLight ? const Color(0x20000000) : const Color(0x40000000);

    return ClipRRect(
        borderRadius: _radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: _radius,
              border: Border.fromBorderSide(BorderSide(width: 0.5, color: borderCol)),
              boxShadow: [BoxShadow(color: shadowCol, blurRadius: 20, offset: const Offset(0, -6))],
            ),
            constraints: const BoxConstraints(minHeight: 44),
            padding: EdgeInsets.fromLTRB(
              4, 6, 4,
              bottomSafeArea > 0 ? bottomSafeArea : 6,
            ),
            child: child,
          ),
        ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final KaalTab tab;
  final bool isActive;
  final bool enabled;
  final KaalColors colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  // Focus tab uses an asset SVG (handled in _icon); this getter is only called for the other tabs.
  String get _svg => switch (widget.tab) {
        KaalTab.tasks    => _svgTasks,
        KaalTab.habits   => _svgHabits,
        KaalTab.calendar => _svgCalendar,
        KaalTab.notes    => _svgNotes,
        KaalTab.aiInbox  => _svgAiInbox,
        KaalTab.search   => _svgSearch,
        KaalTab.settings => _svgSettings,
        KaalTab.profile  => _svgProfile,
        KaalTab.focus    => '',
      };

  Color get _iconColor =>
      widget.isActive ? KaalColors.acc : widget.colors.ink2;

  // Focus renders at 26px (slightly larger, matching prototype); others at 20px.
  Widget get _icon {
    final size   = widget.tab == KaalTab.focus ? 26.0 : 20.0;
    final filter = ColorFilter.mode(_iconColor, BlendMode.srcIn);

    if (widget.tab == KaalTab.focus) {
      return SvgPicture.asset(
        'assets/icons/focus_nav.svg',
        width: size,
        height: size,
        colorFilter: filter,
      );
    }

    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
      colorFilter: filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: KaalMotion.fastPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            // Locked tabs render dimmed so they read as "not yet available".
            child: Opacity(opacity: widget.enabled ? 1.0 : 0.35, child: _icon),
          ),
        ),
      ),
    );
  }
}

// ── Desktop / web left sidebar ────────────────────────────────────────────────
// Replaces the bottom nav on wide windows. Gives one-click access to every
// section (incl. Settings/Profile that the bottom nav hides) and surfaces live
// counts so info is visible without navigating in.

class KaalSidebar extends ConsumerWidget {
  final KaalTab currentTab;
  final ValueChanged<KaalTab>? onTabChanged;
  const KaalSidebar({super.key, required this.currentTab, this.onTabChanged});

  static const _main = [
    KaalTab.focus, KaalTab.tasks, KaalTab.habits,
    KaalTab.calendar, KaalTab.notes, KaalTab.aiInbox,
  ];
  static const _footer = [KaalTab.search, KaalTab.settings, KaalTab.profile];

  static String _label(KaalTab t) => switch (t) {
        KaalTab.focus    => 'Focus',
        KaalTab.tasks    => 'Tasks',
        KaalTab.habits   => 'Habits',
        KaalTab.calendar => 'Calendar',
        KaalTab.notes    => 'Notes',
        KaalTab.aiInbox  => 'Inbox',
        KaalTab.search   => 'Search',
        KaalTab.settings => 'Settings',
        KaalTab.profile  => 'Profile',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = KaalTheme.of(context).colors;
    final isLight  = KaalTheme.of(context).mode == KaalThemeMode.light;
    final settings = ref.watch(kaalSettingsProvider);
    final topSafe  = MediaQuery.viewPaddingOf(context).top;
    final botSafe  = MediaQuery.viewPaddingOf(context).bottom;

    // Live counts so the nav itself carries info (reduces clicking in).
    final tasks  = ref.watch(allTasksProvider).value ?? const [];
    final habits = ref.watch(habitsProvider).value ?? const [];
    final notes  = ref.watch(notesProvider).value ?? const [];
    final events = ref.watch(calendarEventsProvider).value ?? const [];
    final now = DateTime.now();
    bool isToday(DateTime? d) =>
        d == null || (d.year == now.year && d.month == now.month && d.day == now.day);

    int? badge(KaalTab t) => switch (t) {
          KaalTab.tasks    => tasks.where((x) => !x.isDone).length,
          KaalTab.habits   => habits.length,
          KaalTab.notes    => notes.length,
          KaalTab.calendar => events.where((e) => isToday(e.eventDate)).length,
          _ => null,
        };

    final panel = isLight ? const Color(0xF5F4F4F8) : const Color(0xF00B0B12);

    Widget item(KaalTab t) {
      final n = badge(t);
      return _SidebarItem(
        tab: t,
        label: _label(t),
        badge: (n != null && n > 0) ? '$n' : null,
        isActive: t == currentTab,
        enabled: KaalBottomNav._enabled(settings, t),
        colors: colors,
        onTap: () {
          if (KaalBottomNav._enabled(settings, t)) {
            onTabChanged?.call(t);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${KaalBottomNav._tabName(t)} is locked. Enable it in '
                  'Settings -> Tabs, or it unlocks automatically in a few days.'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
      );
    }

    return Container(
      width: 232,
      decoration: BoxDecoration(
        color: panel,
        border: Border(right: BorderSide(width: 0.5, color: colors.bdr)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSafe + 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 0, 16, 0),
            child: Row(children: [
              const Text('✦', style: TextStyle(fontSize: 18, color: KaalColors.acc, height: 1)),
              const SizedBox(width: 9),
              Text('Kaal',
                  style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontVariations: const [FontVariation('wght', 600)],
                      fontSize: 20,
                      color: colors.ink,
                      height: 1)),
            ]),
          ),
          const SizedBox(height: 18),
          for (final t in _main) item(t),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 1, thickness: 0.5, color: colors.bdr),
          ),
          const SizedBox(height: 6),
          for (final t in _footer) item(t),
          SizedBox(height: 16 + botSafe),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final KaalTab tab;
  final String label;
  final String? badge;
  final bool isActive;
  final bool enabled;
  final KaalColors colors;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.tab,
    required this.label,
    required this.badge,
    required this.isActive,
    required this.enabled,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  Widget _icon(Color color) {
    const size = 19.0;
    final filter = ColorFilter.mode(color, BlendMode.srcIn);
    if (widget.tab == KaalTab.focus) {
      return SvgPicture.asset('assets/icons/focus_nav.svg',
          width: size, height: size, colorFilter: filter);
    }
    final svg = switch (widget.tab) {
      KaalTab.tasks    => _svgTasks,
      KaalTab.habits   => _svgHabits,
      KaalTab.calendar => _svgCalendar,
      KaalTab.notes    => _svgNotes,
      KaalTab.aiInbox  => _svgAiInbox,
      KaalTab.search   => _svgSearch,
      KaalTab.settings => _svgSettings,
      KaalTab.profile  => _svgProfile,
      KaalTab.focus    => '',
    };
    return SvgPicture.string(svg, width: size, height: size, colorFilter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final fg = widget.isActive ? KaalColors.acc : colors.ink2;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 1, 10, 1),
            padding: const EdgeInsets.fromLTRB(11, 9, 10, 9),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? KaalColors.accBg
                  : (_hover ? colors.surf2 : Colors.transparent),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(children: [
              SizedBox(width: 22, child: _icon(fg)),
              const SizedBox(width: 11),
              Expanded(
                child: Text(widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.5,
                        fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                        color: widget.isActive ? colors.ink : colors.ink2,
                        height: 1)),
              ),
              if (widget.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isActive ? KaalColors.acc : colors.surf3,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(widget.badge!,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.isActive ? Colors.white : colors.ink3,
                          height: 1)),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
