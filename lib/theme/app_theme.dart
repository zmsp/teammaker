import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Sport Color Presets ───────────────────────────────────────────────────
// High-saturation palettes designed for outdoor glare readability.
// ──────────────────────────────────────────────────────────────────────────

enum SportPalette {
  volleyball, // #1 globally
  basketball,
  football,
  cricket,
  tennis,
  rugby,
  handball,
  netball,
}

extension SportPaletteInfo on SportPalette {
  String get label {
    switch (this) {
      case SportPalette.volleyball:
        return 'Volleyball';
      case SportPalette.basketball:
        return 'Basketball';
      case SportPalette.football:
        return 'Football';
      case SportPalette.cricket:
        return 'Cricket';
      case SportPalette.tennis:
        return 'Tennis';
      case SportPalette.rugby:
        return 'Rugby';
      case SportPalette.handball:
        return 'Handball';
      case SportPalette.netball:
        return 'Netball';
    }
  }

  String get description {
    switch (this) {
      case SportPalette.volleyball:
        return 'Sky blue & gold — beach & indoor';
      case SportPalette.basketball:
        return 'Court orange & black — NBA energy';
      case SportPalette.football:
        return 'Pitch green & white — the beautiful game';
      case SportPalette.cricket:
        return 'Willow cream & forest — Lords & MCG';
      case SportPalette.tennis:
        return 'Wimbledon purple & green — clay to grass';
      case SportPalette.rugby:
        return 'Deep crimson & slate — tough & bold';
      case SportPalette.handball:
        return 'Electric blue & amber — fast & powerful';
      case SportPalette.netball:
        return 'Royal purple & pink — fast and fluid';
    }
  }

  Color get seedColor {
    switch (this) {
      case SportPalette.volleyball:
        return const Color(0xFF0277BD); // sky blue
      case SportPalette.basketball:
        return const Color(0xFFE35205); // NBA orange
      case SportPalette.football:
        return const Color(0xFF1B8C3A); // pitch green
      case SportPalette.cricket:
        return const Color(0xFF33691E); // forest green
      case SportPalette.tennis:
        return const Color(0xFF4A148C); // Wimbledon purple
      case SportPalette.rugby:
        return const Color(0xFFC62828); // deep crimson
      case SportPalette.handball:
        return const Color(0xFF0D47A1); // electric blue
      case SportPalette.netball:
        return const Color(0xFF6A1B9A); // royal purple
    }
  }

  Color get accentColor {
    switch (this) {
      case SportPalette.volleyball:
        return const Color(0xFFFFD600); // gold
      case SportPalette.basketball:
        return const Color(0xFF1A1A1A); // court black
      case SportPalette.football:
        return const Color(0xFFFFFFFF); // white lines
      case SportPalette.cricket:
        return const Color(0xFFFFF9C4); // willow cream
      case SportPalette.tennis:
        return const Color(0xFF76FF03); // Wimbledon green
      case SportPalette.rugby:
        return const Color(0xFF424242); // slate dark
      case SportPalette.handball:
        return const Color(0xFFFFAB00); // amber
      case SportPalette.netball:
        return const Color(0xFFE91E63); // vivid pink
    }
  }

  /// Material icon representing this sport — used throughout the UI.
  IconData get icon {
    switch (this) {
      case SportPalette.volleyball:
        return Icons.sports_volleyball;
      case SportPalette.basketball:
        return Icons.sports_basketball;
      case SportPalette.football:
        return Icons.sports_soccer;
      case SportPalette.cricket:
        return Icons.sports_cricket;
      case SportPalette.tennis:
        return Icons.sports_tennis;
      case SportPalette.rugby:
        return Icons.sports_rugby;
      case SportPalette.handball:
        return Icons.sports_handball;
      case SportPalette.netball:
        return Icons.sports;
    }
  }
}

// ─── Theme Controller ─────────────────────────────────────────────────────
/// Single source of truth for the active palette and mode.
/// Persists selections to SharedPreferences.
class ThemeController extends ChangeNotifier {
  static const _keyPalette = 'theme_palette';
  static const _keyMode = 'theme_mode';

  SportPalette _palette = SportPalette.volleyball;
  ThemeMode _mode = ThemeMode.dark;

  SportPalette get palette => _palette;
  ThemeMode get mode => _mode;

  ThemeController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final paletteName = prefs.getString(_keyPalette);
    final modeName = prefs.getString(_keyMode);

    if (paletteName != null) {
      _palette = SportPalette.values.firstWhere(
        (e) => e.name == paletteName,
        orElse: () => SportPalette.volleyball,
      );
    }
    if (modeName != null) {
      _mode = modeName == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setPalette(SportPalette palette) async {
    _palette = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPalette, palette.name);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  ThemeData get lightTheme => AppTheme.light(_palette);
  ThemeData get darkTheme => AppTheme.dark(_palette);

  /// The sport icon for the current palette — use this in sport-context UI.
  IconData get sportIcon => _palette.icon;
}

// ─── Sport Icon Theme Extension ───────────────────────────────────────────────
/// Carries the active sport's IconData into the widget tree via Theme.
/// Read it with: `Theme.of(context).extension<SportIconExtension>()?.icon`
class SportIconExtension extends ThemeExtension<SportIconExtension> {
  final IconData icon;
  const SportIconExtension(this.icon);

  @override
  SportIconExtension copyWith({IconData? icon}) =>
      SportIconExtension(icon ?? this.icon);

  @override
  SportIconExtension lerp(SportIconExtension? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

// ─── App Theme Builder ────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // Dark neutral bases shared across palettes
  static const _darkBase = Color(0xFF0D1218);
  static const _darkSurface = Color(0xFF131A22);
  static const _darkCard = Color(0xFF1A2435);

  // ── Public theme factories ──────────────────────────────────────────────
  static ThemeData light(SportPalette palette) {
    final primary = palette.seedColor;
    final secondary = palette.accentColor;
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      secondary: secondary,
    ).copyWith(
      secondary: secondary,
      secondaryContainer: secondary.withValues(alpha: 0.15),
      onSecondaryContainer: secondary,
    );
    return _buildLight(cs, palette);
  }

  static ThemeData dark(SportPalette palette) {
    final primary = palette.seedColor;
    final secondary = palette.accentColor;
    final cs = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: _lighten(primary, 0.35),
      secondary: _lighten(secondary, 0.25),
      surface: _darkSurface,
      surfaceContainer: _darkCard,
      surfaceContainerHighest: const Color(0xFF222F40),
    ).copyWith(
      secondary: _lighten(secondary, 0.25),
      secondaryContainer: secondary.withValues(alpha: 0.25),
    );
    return _buildDark(cs, primary, palette);
  }

  // ── Shared light theme structure ─────────────────────────────────────────
  static ThemeData _buildLight(ColorScheme cs, SportPalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      extensions: [SportIconExtension(palette.icon)],
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: cs.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.secondary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.primary.withValues(alpha: 0.1),
        selectedColor: cs.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? cs.primary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primary.withValues(alpha: 0.4)
                : Colors.grey.shade300),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  // ── Shared dark theme structure ──────────────────────────────────────────
  static ThemeData _buildDark(
      ColorScheme cs, Color seedPrimary, SportPalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      extensions: [SportIconExtension(palette.icon)],
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: _darkBase,
      drawerTheme: const DrawerThemeData(backgroundColor: _darkSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: const Color(0xFFE8EDF2),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 0.3,
          color: Color(0xFFE8EDF2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCard,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: cs.primary.withValues(alpha: 0.15),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: cs.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8EDF2),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 4,
          shadowColor: cs.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.secondary,
          foregroundColor: cs.onSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: cs.primary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primary
                : const Color(0xFF4A5568)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primary.withValues(alpha: 0.4)
                : const Color(0xFF2D3748)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.primary.withValues(alpha: 0.12),
        selectedColor: cs.primary,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Color(0xFFE8EDF2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: cs.primary.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2435),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3748)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3748)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF8A99A8)),
        prefixIconColor: cs.primary,
        hintStyle: const TextStyle(color: Color(0xFF4A5568)),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: cs.primary,
        collapsedIconColor: const Color(0xFF8A99A8),
        textColor: const Color(0xFFE8EDF2),
      ),
      dividerTheme:
          const DividerThemeData(color: Color(0xFF2D3748), thickness: 1),
      listTileTheme: ListTileThemeData(
        textColor: const Color(0xFFE8EDF2),
        iconColor: cs.primary,
      ),
    );
  }

  // ── Color utility ────────────────────────────────────────────────────────
  /// Lightens a color by mixing it toward white by [amount] (0–1).
  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }
}
