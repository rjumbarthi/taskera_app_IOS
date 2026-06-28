import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/tasks_provider.dart';
import '../routing/routes.dart';
import '../settings/kaal_settings.dart';
import '../theme/kaal_colors.dart';
import '../theme/kaal_motion.dart';
import '../theme/kaal_theme.dart';
import 'kaal_avatar.dart';

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


// ── Desktop / web left sidebar (reference design) ─────────────────────────────
// Visual match to the Apple-restrained reference: brand, Today/Inbox/Upcoming,
// a TOOLS group, and an account footer. Wired to the existing routes (no
// routing changes) — `currentTab` drives the selected highlight.

class KaalSidebar extends ConsumerWidget {
  final KaalTab currentTab;
  const KaalSidebar({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness != Brightness.light;
    final panel     = dark ? const Color(0xFF0A0A0C) : const Color(0xFFF6F6F9);
    final labelCol  = dark ? Colors.white : const Color(0xFF1A1A1A);
    final secondary = dark ? const Color(0xFF8E8E93) : const Color(0xFF6B6B70);
    final toolsCol  = dark ? const Color(0xFF6A6A70) : const Color(0xFF9A9AA0);
    final borderCol = dark ? const Color(0xFF1C1C1E) : const Color(0xFFE2E2E7);
    final hover     = dark ? const Color(0x14FFFFFF) : const Color(0x0A000000);

    final topSafe = MediaQuery.viewPaddingOf(context).top;
    final botSafe = MediaQuery.viewPaddingOf(context).bottom;

    final tasks = ref.watch(allTasksProvider).value ?? const <dynamic>[];
    final todayCount = tasks.where((t) => !t.isDone).length;
    final inboxCount =
        tasks.where((t) => !t.isDone && (t.quadrant < 1 || t.quadrant > 4)).length;

    final name = ref.watch(displayNameProvider) ?? 'You';
    final synced = ref.watch(currentUserProvider) != null;

    Widget item({
      required String label,
      required IconData icon,
      required String route,
      bool active = false,
      int? count,
    }) =>
        _SideNavItem(
          label: label,
          icon: icon,
          active: active,
          count: count,
          labelCol: labelCol,
          secondary: secondary,
          hover: hover,
          onTap: () => context.go(route),
        );

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: panel,
        border: Border(right: BorderSide(width: 0.5, color: borderCol)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSafe + 20),
          // Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A84FF), Color(0xFF409CFF)],
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icons/focus_nav.svg',
                    width: 20, height: 20,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
              const SizedBox(width: 12),
              Text('Kaal',
                  style: TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: labelCol, height: 1)),
            ]),
          ),
          const SizedBox(height: 24),
          item(label: 'Today', icon: Icons.access_time_rounded, route: KaalRoutes.focus,
              active: currentTab == KaalTab.focus, count: todayCount > 0 ? todayCount : null),
          item(label: 'Inbox', icon: Icons.inbox_outlined, route: KaalRoutes.inbox,
              active: currentTab == KaalTab.aiInbox, count: inboxCount > 0 ? inboxCount : null),
          item(label: 'Upcoming', icon: Icons.event_outlined, route: KaalRoutes.tasks,
              active: currentTab == KaalTab.tasks),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 16, 8),
            child: Text('TOOLS',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: toolsCol, height: 1)),
          ),
          item(label: 'Focus', icon: Icons.timer_outlined, route: KaalRoutes.tasksPomodoro),
          item(label: 'Habits', icon: Icons.check_box_outlined, route: KaalRoutes.habits,
              active: currentTab == KaalTab.habits),
          item(label: 'Notes', icon: Icons.sticky_note_2_outlined, route: KaalRoutes.notes,
              active: currentTab == KaalTab.notes),
          const Spacer(),
          // Account footer
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go(KaalRoutes.profile),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 16, 0),
                child: Row(children: [
                  const KaalAvatar(size: 34),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: labelCol, height: 1.2)),
                        Text(synced ? 'Cloud synced' : 'Local storage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: secondary, height: 1.2)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
          SizedBox(height: 16 + botSafe),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool active;
  final int? count;
  final Color labelCol, secondary, hover;
  final VoidCallback onTap;
  const _SideNavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.count,
    required this.labelCol,
    required this.secondary,
    required this.hover,
    required this.onTap,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active ? Colors.white : widget.labelCol;
    final iconCol = active ? Colors.white : widget.secondary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 2, 12, 2),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF0A84FF)
                : (_hover ? widget.hover : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(widget.icon, size: 19, color: iconCol),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                      height: 1)),
            ),
            if (widget.count != null)
              Text('${widget.count}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (active ? Colors.white : widget.secondary)
                          .withValues(alpha: active ? 0.95 : 0.8),
                      height: 1)),
          ]),
        ),
      ),
    );
  }
}
