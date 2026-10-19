import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:go_router/go_router.dart';
import '../../l10n/app_l10n.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/taskera_top_bar.dart';
import '../../data/providers/auth_provider.dart'
    show profileImagePathProvider, profileAvatarColorProvider, profileAvatarLogoProvider,
         profileDisplayNameProvider, displayNameProvider, currentUserProvider;
import '../../services/auth_service.dart';
import '../../util/taskera_dialogs.dart';
import '../../widgets/taskera_avatar.dart' show kTaskEraAvatarColors;
import '../../routing/routes.dart';
import '../../settings/taskera_settings.dart';
import '../../theme/taskera_colors.dart';
import '../../theme/taskera_theme.dart';
import '../../widgets/wallpaper_background.dart';

// ── Picker tab ────────────────────────────────────────────────────────────────

enum _PickerTab { color, logo }


// ── App logo definitions ──────────────────────────────────────────────────────

sealed class _Logo { const _Logo(); }
class _AssetLogo  extends _Logo { final String path; const _AssetLogo(this.path); }
class _SvgLogo    extends _Logo { final String path; const _SvgLogo(this.path); }
class _EmojiLogo  extends _Logo { final String emoji; const _EmojiLogo(this.emoji); }

const _kLogos = <_Logo>[
  _AssetLogo('assets/logo/taskera_icon_glass.png'),
  _SvgLogo('assets/icons/focus_nav.svg'),
  _EmojiLogo('🎯'),
  _EmojiLogo('🔥'),
  _EmojiLogo('⚡'),
  _EmojiLogo('🚀'),
  _EmojiLogo('✦'),
  _EmojiLogo('🌊'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  _PickerTab _tab      = _PickerTab.color;
  int        _colorIdx = 0;
  int?       _logoIdx;

  @override
  void initState() {
    super.initState();
    final savedName = ref.read(profileDisplayNameProvider) ?? ref.read(displayNameProvider) ?? '';
    _nameCtrl = TextEditingController(text: savedName);
    // Pre-load saved avatar state.
    _colorIdx = ref.read(profileAvatarColorProvider);
    _logoIdx  = ref.read(profileAvatarLogoProvider);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _save() async {
    await ref.read(profileDisplayNameProvider.notifier).setName(_nameCtrl.text.trim());
    await ref.read(profileAvatarColorProvider.notifier).setColor(_colorIdx);
    await ref.read(profileAvatarLogoProvider.notifier).setLogo(_logoIdx);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = TaskEraTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final settings  = ref.watch(taskeraSettingsProvider);
    final wallpaper = settings.wallpaper;

    return Stack(
      children: [
        Positioned.fill(
            child: WallpaperBackground(wallpaper: wallpaper, dim: settings.wallpaperDim)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskEraTopBar(
                title: AppL10n.of(context).editProfile,
                leading: AddBackButton(onTap: () => context.pop()),
                actions: [
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                      decoration: BoxDecoration(
                        color: TaskEraColors.accBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                      ),
                      child: Text(AppL10n.of(context).save,
                          style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 13,
                              fontWeight: FontWeight.w600, color: colors.textOrPlain(TaskEraColors.acc2), height: 1)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, safeBot + 32),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    _AvatarHero(
                      initials:  _initials,
                      colorIdx:  _colorIdx,
                      logoIdx:   _logoIdx,
                      colors:    colors,
                    ),
                    const SizedBox(height: 16),
                    // ── picker card ─────────────────────────────────────────
                    _PickerCard(
                      tab:      _tab,
                      colorIdx: _colorIdx,
                      logoIdx:  _logoIdx,
                      colors:   colors,
                      onTab:    (t) => setState(() => _tab = t),
                      onColor:  (i) => setState(() { _colorIdx = i; _logoIdx = null; }),
                      onLogo:   (i) => setState(() { _logoIdx = i; }),
                    ),
                    const SizedBox(height: 24),
                    // ── name field ──────────────────────────────────────────
                    _FieldLabel('DISPLAY NAME', colors),
                    const SizedBox(height: 6),
                    _GlassField(
                      controller: _nameCtrl,
                      hint: AppL10n.of(context).yourNameHint,
                      colors: colors,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel('EMAIL', colors),
                    const SizedBox(height: 6),
                    _ReadonlyField(
                      value: ref.watch(currentUserProvider)?.email ?? '—',
                      colors: colors,
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () async {
                        // Actually end the Supabase session, then clear local
                        // profile overrides so the next user starts clean.
                        await ref.read(authServiceProvider).signOut();
                        await ref.read(profileImagePathProvider.notifier).clear();
                        await ref.read(profileDisplayNameProvider.notifier).setName('');
                        if (context.mounted) context.go(TaskEraRoutes.signin);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(width: 0.5, color: const Color(0x33FF3B30)),
                          color: const Color(0x12FF3B30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppL10n.of(context).signOut,
                          style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textOrPlain(TaskEraColors.warn),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ── delete account ──────────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        final ok = await taskeraConfirmDelete(
                          context,
                          message:
                              'This permanently deletes your account and all your '
                              'tasks, habits, goals and notes across every device. '
                              'This cannot be undone.',
                        );
                        if (!ok) return;
                        try {
                          await ref.read(authServiceProvider).deleteAccount();
                          await ref.read(profileImagePathProvider.notifier).clear();
                          await ref
                              .read(profileDisplayNameProvider.notifier)
                              .setName('');
                          if (context.mounted) context.go(TaskEraRoutes.signin);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Could not delete your account. Please try again or contact support.'),
                              ),
                            );
                          }
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          'Delete account',
                          style: TextStyle(
                            fontFamily: TaskEraTheme.of(context).fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF453A),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFF453A),
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Permanently erases your account and data.',
                        style: TextStyle(
                          fontFamily: TaskEraTheme.of(context).fontFamily,
                          fontSize: 11,
                          color: colors.ink3,
                          height: 1.4,
                        ),
                      ),
                    ),
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


// ── Avatar hero ───────────────────────────────────────────────────────────────

class _AvatarHero extends StatelessWidget {
  final String initials;
  final int colorIdx;
  final int? logoIdx;
  final TaskEraColors colors;
  const _AvatarHero({required this.initials, required this.colorIdx,
      required this.logoIdx, required this.colors});

  @override
  Widget build(BuildContext context) {
    final bgColor = kTaskEraAvatarColors[colorIdx];

    Widget face;
    if (logoIdx != null) {
      final logo = _kLogos[logoIdx!];
      face = Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.35),
                blurRadius: 16, offset: const Offset(0, 4))]),
        clipBehavior: Clip.antiAlias,
        child: logo is _AssetLogo
            ? SizedBox.expand(child: Image.asset(logo.path, fit: BoxFit.cover))
            : Center(child: _buildLogoContent(logo, 32)),
      );
    } else {
      face = Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.35),
                blurRadius: 16, offset: const Offset(0, 4))]),
        alignment: Alignment.center,
        child: Text(initials,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 26,
                fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
      );
    }

    return Center(
      child: Stack(clipBehavior: Clip.none, children: [
        face,
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C2E),
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: bgColor),
            ),
            child: const Icon(Icons.edit_rounded, size: 11, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

Widget _buildLogoContent(_Logo logo, double size) {
  return switch (logo) {
    _AssetLogo(:final path) => Image.asset(path, width: size, height: size, fit: BoxFit.contain),
    _SvgLogo(:final path)   => SvgPicture.asset(path, width: size, height: size,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    _EmojiLogo(:final emoji) => Text(emoji,
        style: TextStyle(fontSize: size * 0.72, height: 1)),
  };
}

// ── Picker card ───────────────────────────────────────────────────────────────

class _PickerCard extends StatelessWidget {
  final _PickerTab tab;
  final int colorIdx;
  final int? logoIdx;
  final TaskEraColors colors;
  final ValueChanged<_PickerTab> onTab;
  final ValueChanged<int> onColor;
  final ValueChanged<int> onLogo;

  const _PickerCard({
    required this.tab, required this.colorIdx, required this.logoIdx,
    required this.colors,
    required this.onTab, required this.onColor, required this.onLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── tab row ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _TabRow(tab: tab, colors: colors, onTap: onTab),
        ),
        const SizedBox(height: 12),
        // ── tab body ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: switch (tab) {
            _PickerTab.color => _ColorBody(selected: colorIdx, colors: colors, onTap: onColor),
            _PickerTab.logo  => _LogoBody(selected: logoIdx, colors: colors, colorIdx: colorIdx, onTap: onLogo),
          },
        ),
      ]),
    );
  }
}

// ── Tab row ───────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final _PickerTab tab;
  final TaskEraColors colors;
  final ValueChanged<_PickerTab> onTap;
  const _TabRow({required this.tab, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(width: 0.5, color: colors.bdr),
      ),
      child: Row(children: [
        for (final t in _PickerTab.values)
          Expanded(child: _TabChip(label: _tabLabel(t), selected: tab == t,
              onTap: () { HapticFeedback.selectionClick(); onTap(t); })),
      ]),
    );
  }

  String _tabLabel(_PickerTab t) => switch (t) {
    _PickerTab.color => 'Colour',
    _PickerTab.logo  => 'App logo',
  };
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: selected ? TaskEraColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: selected ? Border.all(width: 0.5, color: const Color(0x4D0A84FF)) : null,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? TaskEraColors.acc2 : TaskEraTheme.of(context).colors.ink3,
                height: 1)),
      ),
    );
  }
}

// ── Colour body ───────────────────────────────────────────────────────────────

class _ColorBody extends StatelessWidget {
  final int selected;
  final TaskEraColors colors;
  final ValueChanged<int> onTap;
  const _ColorBody({required this.selected, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 0; i < kTaskEraAvatarColors.length; i++)
          GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); onTap(i); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width:  selected == i ? 30 : 26,
              height: selected == i ? 30 : 26,
              decoration: BoxDecoration(
                color: kTaskEraAvatarColors[i],
                shape: BoxShape.circle,
                border: selected == i ? Border.all(width: 2.5, color: Colors.white) : null,
                boxShadow: selected == i
                    ? [BoxShadow(color: kTaskEraAvatarColors[i].withValues(alpha: 0.5), blurRadius: 8)]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Logo body ─────────────────────────────────────────────────────────────────

class _LogoBody extends StatelessWidget {
  final int? selected;
  final TaskEraColors colors;
  final int colorIdx;
  final ValueChanged<int> onTap;
  const _LogoBody({required this.selected, required this.colors,
      required this.colorIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = kTaskEraAvatarColors[colorIdx];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kLogos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final sel = selected == i;
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTap(i); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: sel ? bgColor : bgColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: sel
                  ? Border.all(width: 2.5, color: Colors.white)
                  : Border.all(width: 0.5, color: bgColor.withValues(alpha: 0.4)),
              boxShadow: sel
                  ? [BoxShadow(color: bgColor.withValues(alpha: 0.45), blurRadius: 10)]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: _kLogos[i] is _AssetLogo
                ? SizedBox.expand(
                    child: Image.asset((_kLogos[i] as _AssetLogo).path, fit: BoxFit.cover))
                : Center(child: _buildLogoContent(_kLogos[i], 22)),
          ),
        );
      },
    );
  }
}

// ── Form helpers ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final TaskEraColors colors;
  const _FieldLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
            color: colors.ink3, height: 1));
  }
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TaskEraColors colors;
  final ValueChanged<String>? onChanged;
  const _GlassField({required this.controller, required this.hint,
      required this.colors, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.done,
        style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
            color: colors.ink, height: 1.4),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
              color: colors.ink3, height: 1.4),
          contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          border: InputBorder.none,
          isDense: true,
        ),
        cursorColor: TaskEraColors.acc,
        cursorWidth: 1.5,
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String value;
  final TaskEraColors colors;
  const _ReadonlyField({required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.surf2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: colors.bdr0),
      ),
      child: Row(children: [
        Expanded(
          child: Text(value,
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 14,
                  color: colors.ink3, height: 1.4)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          decoration: BoxDecoration(
            color: colors.surf2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.5, color: colors.bdr0),
          ),
          child: Text('locked',
              style: TextStyle(fontFamily: TaskEraTheme.of(context).fontFamily, fontSize: 9,
                  color: colors.ink3, height: 1)),
        ),
      ]),
    );
  }
}
