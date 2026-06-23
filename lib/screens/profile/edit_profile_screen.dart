import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:go_router/go_router.dart';
import '../../l10n/app_l10n.dart';
import '../../widgets/add_back_button.dart';
import '../../widgets/kaal_top_bar.dart';
import '../../data/providers/auth_provider.dart'
    show profileImagePathProvider, profileAvatarColorProvider, profileAvatarLogoProvider,
         profileDisplayNameProvider, displayNameProvider;
import '../../widgets/kaal_avatar.dart' show kKaalAvatarColors;
import '../../routing/routes.dart';
import '../../settings/kaal_settings.dart';
import '../../theme/kaal_colors.dart';
import '../../theme/kaal_theme.dart';
import '../../widgets/wallpaper_background.dart';

// ── Picker tab ────────────────────────────────────────────────────────────────

enum _PickerTab { color, logo, photo }


// ── App logo definitions ──────────────────────────────────────────────────────

sealed class _Logo { const _Logo(); }
class _AssetLogo  extends _Logo { final String path; const _AssetLogo(this.path); }
class _SvgLogo    extends _Logo { final String path; const _SvgLogo(this.path); }
class _EmojiLogo  extends _Logo { final String emoji; const _EmojiLogo(this.emoji); }

const _kLogos = <_Logo>[
  _AssetLogo('assets/logo/kaal_logo.png'),
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
  XFile?     _image;

  final _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) setState(() { _image = file; _tab = _PickerTab.photo; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'photos'}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    await ref.read(profileDisplayNameProvider.notifier).setName(_nameCtrl.text.trim());
    await ref.read(profileAvatarColorProvider.notifier).setColor(_colorIdx);
    await ref.read(profileAvatarLogoProvider.notifier).setLogo(_logoIdx);
    if (_image != null) {
      final docsDir = await getApplicationDocumentsDirectory();
      final dest = File('${docsDir.path}/kaal_profile_avatar.jpg');
      await File(_image!.path).copy(dest.path);
      await ref.read(profileImagePathProvider.notifier).setPath(dest.path);
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors    = KaalTheme.of(context).colors;
    final safeBot   = MediaQuery.of(context).padding.bottom;
    final wallpaper = ref.watch(kaalSettingsProvider).wallpaper;

    return Stack(
      children: [
        Positioned.fill(child: WallpaperBackground(wallpaper: wallpaper)),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KaalTopBar(
                title: AppL10n.of(context).editProfile,
                leading: AddBackButton(onTap: () => context.pop()),
                actions: [
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
                      decoration: BoxDecoration(
                        color: KaalColors.accBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.5, color: const Color(0x4D0A84FF)),
                      ),
                      child: Text(AppL10n.of(context).save,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                              fontWeight: FontWeight.w600, color: KaalColors.acc2, height: 1)),
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
                      image:     _image,
                      colors:    colors,
                    ),
                    const SizedBox(height: 16),
                    // ── picker card ─────────────────────────────────────────
                    _PickerCard(
                      tab:      _tab,
                      colorIdx: _colorIdx,
                      logoIdx:  _logoIdx,
                      image:    _image,
                      colors:   colors,
                      onTab:    (t) => setState(() => _tab = t),
                      onColor:  (i) => setState(() { _colorIdx = i; _logoIdx = null; _image = null; }),
                      onLogo:   (i) => setState(() { _logoIdx = i; _image = null; }),
                      onPickGallery: () => _pickImage(ImageSource.gallery),
                      onPickCamera:  () => _pickImage(ImageSource.camera),
                      onClearImage:  () => setState(() => _image = null),
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
                    _ReadonlyField(value: 'r@jumbarthi.com', colors: colors),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () async {
                        await ref.read(profileImagePathProvider.notifier).clear();
                        if (context.mounted) context.go(KaalRoutes.signin);
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
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KaalColors.warn,
                            height: 1,
                          ),
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
  final XFile? image;
  final KaalColors colors;
  const _AvatarHero({required this.initials, required this.colorIdx,
      required this.logoIdx, required this.image, required this.colors});

  @override
  Widget build(BuildContext context) {
    final bgColor = kKaalAvatarColors[colorIdx];

    Widget face;
    if (image != null) {
      face = ClipOval(
        child: Image.file(File(image!.path), width: 72, height: 72, fit: BoxFit.cover),
      );
    } else if (logoIdx != null) {
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
            style: const TextStyle(fontFamily: 'Inter', fontSize: 26,
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
  final XFile? image;
  final KaalColors colors;
  final ValueChanged<_PickerTab> onTab;
  final ValueChanged<int> onColor;
  final ValueChanged<int> onLogo;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onClearImage;

  const _PickerCard({
    required this.tab, required this.colorIdx, required this.logoIdx,
    required this.image, required this.colors,
    required this.onTab, required this.onColor, required this.onLogo,
    required this.onPickGallery, required this.onPickCamera, required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
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
            _PickerTab.photo => _PhotoBody(image: image, colors: colors,
                onGallery: onPickGallery, onCamera: onPickCamera, onClear: onClearImage),
          },
        ),
      ]),
    );
  }
}

// ── Tab row ───────────────────────────────────────────────────────────────────

class _TabRow extends StatelessWidget {
  final _PickerTab tab;
  final KaalColors colors;
  final ValueChanged<_PickerTab> onTap;
  const _TabRow({required this.tab, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
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
    _PickerTab.photo => 'Photo',
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
          color: selected ? KaalColors.accBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: selected ? Border.all(width: 0.5, color: const Color(0x4D0A84FF)) : null,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? KaalColors.acc2 : KaalTheme.of(context).colors.ink3,
                height: 1)),
      ),
    );
  }
}

// ── Colour body ───────────────────────────────────────────────────────────────

class _ColorBody extends StatelessWidget {
  final int selected;
  final KaalColors colors;
  final ValueChanged<int> onTap;
  const _ColorBody({required this.selected, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        for (int i = 0; i < kKaalAvatarColors.length; i++)
          GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); onTap(i); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width:  selected == i ? 30 : 26,
              height: selected == i ? 30 : 26,
              decoration: BoxDecoration(
                color: kKaalAvatarColors[i],
                shape: BoxShape.circle,
                border: selected == i ? Border.all(width: 2.5, color: Colors.white) : null,
                boxShadow: selected == i
                    ? [BoxShadow(color: kKaalAvatarColors[i].withValues(alpha: 0.5), blurRadius: 8)]
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
  final KaalColors colors;
  final int colorIdx;
  final ValueChanged<int> onTap;
  const _LogoBody({required this.selected, required this.colors,
      required this.colorIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bgColor = kKaalAvatarColors[colorIdx];

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

// ── Photo body ────────────────────────────────────────────────────────────────

class _PhotoBody extends StatelessWidget {
  final XFile? image;
  final KaalColors colors;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onClear;
  const _PhotoBody({required this.image, required this.colors,
      required this.onGallery, required this.onCamera, required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(image!.path),
              width: 56, height: 56, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppL10n.of(context).photoSelected,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w500, color: colors.ink, height: 1.2)),
            const SizedBox(height: 3),
            Text(AppL10n.of(context).tapToReplace,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1.3)),
          ]),
        ),
        GestureDetector(
          onTap: onClear,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0x1FFF2D55),
              shape: BoxShape.circle,
              border: Border.all(width: 0.5, color: const Color(0x33FF2D55)),
            ),
            child: const Icon(Icons.close_rounded, size: 14, color: KaalColors.warn),
          ),
        ),
      ]);
    }

    return Column(children: [
      _PhotoBtn(
        icon: Icons.photo_library_outlined,
        label: 'Upload from gallery',
        sub: 'JPG, PNG · max 10 MB',
        onTap: onGallery,
        colors: colors,
      ),
      const SizedBox(height: 8),
      _PhotoBtn(
        icon: Icons.camera_alt_outlined,
        label: 'Take a photo',
        sub: 'Use device camera',
        onTap: onCamera,
        colors: colors,
      ),
    ]);
  }
}

class _PhotoBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final KaalColors colors;
  const _PhotoBtn({required this.icon, required this.label, required this.sub,
      required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: colors.bdr),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: KaalColors.accBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: KaalColors.acc2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    fontWeight: FontWeight.w500, color: colors.ink, height: 1.2)),
            Text(sub,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: colors.ink3, height: 1.3)),
          ])),
          Icon(Icons.chevron_right_rounded, size: 18, color: colors.ink3),
        ]),
      ),
    );
  }
}

// ── Form helpers ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final KaalColors colors;
  const _FieldLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(fontFamily: 'Inter', fontSize: 9,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
            color: colors.ink3, height: 1));
  }
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final KaalColors colors;
  final ValueChanged<String>? onChanged;
  const _GlassField({required this.controller, required this.hint,
      required this.colors, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: const Color(0x33FFFFFF)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.done,
        style: TextStyle(fontFamily: 'Inter', fontSize: 14,
            color: colors.ink, height: 1.4),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14,
              color: colors.ink3, height: 1.4),
          contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          border: InputBorder.none,
          isDense: true,
        ),
        cursorColor: KaalColors.acc,
        cursorWidth: 1.5,
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String value;
  final KaalColors colors;
  const _ReadonlyField({required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(value,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                  color: colors.ink3, height: 1.4)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.5, color: const Color(0x1AFFFFFF)),
          ),
          child: Text('locked',
              style: TextStyle(fontFamily: 'Inter', fontSize: 9,
                  color: colors.ink3, height: 1)),
        ),
      ]),
    );
  }
}
