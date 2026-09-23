import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/wallpaper_background.dart';
import 'prefs_provider.dart';

class TaskEraSettingsState {
  final int wallpaperIndex;
  // Per-theme wallpaper brightness (dim). Each theme remembers its own value so
  // switching theme immediately restores that theme's brightness. Read the
  // active theme's value via the `wallpaperDim` getter.
  final double dimDark;
  final double dimLight;
  final double dimGlass;
  final Map<String, bool> toggles;
  final int theme;
  final int accent;
  final int font;
  final int fontSize;
  final int lineSpacing;
  final int layout;
  final int qnames;
  final int lang;

  // Sensible per-theme brightness defaults: dark stays heavily dimmed, glass
  // medium, light barely washed so the wallpaper reads bright and airy.
  static const defaultDimDark  = 0.85;
  static const defaultDimGlass = 0.70;
  static const defaultDimLight = 0.30;

  const TaskEraSettingsState({
    this.wallpaperIndex = 0,
    this.dimDark  = defaultDimDark,
    this.dimLight = defaultDimLight,
    this.dimGlass = defaultDimGlass,
    this.toggles = const {
      'scoreRec':    true, 'quoteSplash': true, 'eodReflect':   true,
      // habits/calendar/notes/inbox default OFF — auto-unlock by install age (see main.dart)
      'habits':      false, 'calendar':   false, 'notes':        false, 'inbox':      false,
      'listsGrid':   true,
      'focusPeak':   true, 'focusBrain':  true,
      'calSync':     true, 'gmailSync':   true, 'suggestTasks':  true, 'messages':   true,
      'cloudSync':   true, 'q1Alert':     true, 'q2Nudge':       true, 'reminders':  true,
      'overload':    true, 'q2Neglect':   true,
      'notifTasks':    true, 'notifHabits': true, 'notifGoals':    true,
      'notifCalendar': true, 'notifInbox':  true, 'notifFocus':    true,
      // Do The Next ongoing notification (music-player-style lock-screen card)
      'dtnNotif':      true, 'dtnLockScreen': true,
    },
    this.theme = 2,
    this.accent = 0,
    this.font = 0,
    this.fontSize = 1,
    this.lineSpacing = 1,
    this.layout = 0,
    this.qnames = 0,
    this.lang = 0,
  });

  bool sw(String key) => toggles[key] ?? true;

  static const _wallpapers = [
    TaskEraWallpaper.ocean,
    TaskEraWallpaper.aurora3,
    TaskEraWallpaper.beach,
    TaskEraWallpaper.nightSky,
    TaskEraWallpaper.tree,
  ];

  TaskEraWallpaper get wallpaper =>
      _wallpapers[wallpaperIndex.clamp(0, _wallpapers.length - 1)];

  // Brightness for the currently-active theme (theme: 0=dark, 1=light,
  // 2=glass, 3=system→glass).
  double get wallpaperDim => switch (theme) {
        0 => dimDark,
        1 => dimLight,
        _ => dimGlass,
      };

  TaskEraSettingsState withToggle(String key, bool value) => TaskEraSettingsState(
    wallpaperIndex: wallpaperIndex,
    dimDark: dimDark, dimLight: dimLight, dimGlass: dimGlass,
    toggles: {...toggles, key: value},
    theme: theme, accent: accent, font: font,
    fontSize: fontSize, lineSpacing: lineSpacing,
    layout: layout, qnames: qnames, lang: lang,
  );

  TaskEraSettingsState copyWith({
    int? wallpaperIndex, double? dimDark, double? dimLight, double? dimGlass,
    int? theme, int? accent, int? font,
    int? fontSize, int? lineSpacing, int? layout, int? qnames, int? lang,
  }) => TaskEraSettingsState(
    wallpaperIndex: wallpaperIndex ?? this.wallpaperIndex,
    dimDark:  dimDark  ?? this.dimDark,
    dimLight: dimLight ?? this.dimLight,
    dimGlass: dimGlass ?? this.dimGlass,
    toggles: toggles,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    font: font ?? this.font,
    fontSize: fontSize ?? this.fontSize,
    lineSpacing: lineSpacing ?? this.lineSpacing,
    layout: layout ?? this.layout,
    qnames: qnames ?? this.qnames,
    lang: lang ?? this.lang,
  );
}

// ── Persistence keys ──────────────────────────────────────────────────────────

class _K {
  static const wallpaper    = 'taskera.wallpaper';
  static const wallpaperDim = 'taskera.wallpaperDim'; // legacy single value (migrated)
  static const dimDark      = 'taskera.wallpaperDim.dark';
  static const dimLight     = 'taskera.wallpaperDim.light';
  static const dimGlass     = 'taskera.wallpaperDim.glass';
  static const theme        = 'taskera.theme';
  static const accent      = 'taskera.accent';
  static const font        = 'taskera.font';
  static const fontSize    = 'taskera.fontSize';
  static const lineSpacing = 'taskera.lineSpacing';
  static const layout      = 'taskera.layout';
  static const qnames      = 'taskera.qnames';
  static const lang        = 'taskera.lang';
  static String toggle(String k) => 'taskera.toggle.$k';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TaskEraSettingsNotifier extends Notifier<TaskEraSettingsState> {
  SharedPreferences get _p => ref.read(sharedPreferencesProvider);

  @override
  TaskEraSettingsState build() {
    final p = ref.read(sharedPreferencesProvider);
    const d = TaskEraSettingsState();

    final Map<String, bool> loadedToggles = {
      for (final e in d.toggles.entries)
        e.key: p.getBool(_K.toggle(e.key)) ?? e.value,
    };

    // Migrate the old single brightness value: if a user had set it before the
    // per-theme split, seed every theme bucket from it as a baseline.
    final legacyDim = p.getDouble(_K.wallpaperDim);
    return TaskEraSettingsState(
      wallpaperIndex: p.getInt(_K.wallpaper)       ?? d.wallpaperIndex,
      dimDark:  p.getDouble(_K.dimDark)  ?? legacyDim ?? d.dimDark,
      // Light always starts at its airy default — the old shared value produced
      // the over-washed light theme this feature fixes.
      dimLight: p.getDouble(_K.dimLight) ?? d.dimLight,
      dimGlass: p.getDouble(_K.dimGlass) ?? legacyDim ?? d.dimGlass,
      toggles:        loadedToggles,
      theme:          p.getInt(_K.theme)        ?? d.theme,
      accent:         p.getInt(_K.accent)       ?? d.accent,
      font:           p.getInt(_K.font)         ?? d.font,
      fontSize:       p.getInt(_K.fontSize)     ?? d.fontSize,
      lineSpacing:    p.getInt(_K.lineSpacing)  ?? d.lineSpacing,
      layout:         p.getInt(_K.layout)       ?? d.layout,
      qnames:         p.getInt(_K.qnames)       ?? d.qnames,
      lang:           p.getInt(_K.lang)         ?? d.lang,
    );
  }

  void _persist(TaskEraSettingsState s) {
    _p
      ..setInt(_K.wallpaper,       s.wallpaperIndex)
      ..setDouble(_K.dimDark,      s.dimDark)
      ..setDouble(_K.dimLight,     s.dimLight)
      ..setDouble(_K.dimGlass,     s.dimGlass)
      ..setInt(_K.theme,           s.theme)
      ..setInt(_K.accent,      s.accent)
      ..setInt(_K.font,        s.font)
      ..setInt(_K.fontSize,    s.fontSize)
      ..setInt(_K.lineSpacing, s.lineSpacing)
      ..setInt(_K.layout,      s.layout)
      ..setInt(_K.qnames,      s.qnames)
      ..setInt(_K.lang,        s.lang);
    for (final e in s.toggles.entries) {
      _p.setBool(_K.toggle(e.key), e.value);
    }
  }

  void toggle(String key, bool value) {
    state = state.withToggle(key, value);
    _persist(state);
  }

  void setWallpaper(int i) {
    state = state.copyWith(wallpaperIndex: i);
    _persist(state);
  }

  void setTheme(int i) {
    state = state.copyWith(theme: i);
    _persist(state);
  }

  void setAccent(int i) {
    state = state.copyWith(accent: i);
    _persist(state);
  }

  void setFont(int i) {
    state = state.copyWith(font: i);
    _persist(state);
  }

  void setFontSize(int i) {
    state = state.copyWith(fontSize: i);
    _persist(state);
  }

  void setLineSpacing(int i) {
    state = state.copyWith(lineSpacing: i);
    _persist(state);
  }

  void setLayout(int i) {
    state = state.copyWith(layout: i);
    _persist(state);
  }

  void setQnames(int i) {
    state = state.copyWith(qnames: i);
    _persist(state);
  }

  void setLang(int i) {
    state = state.copyWith(lang: i);
    _persist(state);
  }

  // Writes brightness to the active theme's bucket so each theme keeps its own.
  void setWallpaperDim(double v) {
    final c = v.clamp(0.0, 1.0);
    state = switch (state.theme) {
      0 => state.copyWith(dimDark: c),
      1 => state.copyWith(dimLight: c),
      _ => state.copyWith(dimGlass: c),
    };
    _persist(state);
  }
}

final taskeraSettingsProvider =
    NotifierProvider<TaskEraSettingsNotifier, TaskEraSettingsState>(
  TaskEraSettingsNotifier.new,
);
