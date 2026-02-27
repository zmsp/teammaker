import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Sport Color Presets ───────────────────────────────────────────────────
// High-saturation palettes designed for outdoor glare readability.
// ──────────────────────────────────────────────────────────────────────────

enum SportPalette {
  pitchGreen,
  oceanBlue,
  fireRed,
  sunsetOrange,
  royalPurple,
}

extension SportPaletteInfo on SportPalette {
  String get label {
    switch (this) {
      case SportPalette.pitchGreen:
        return 'Pitch Green';
      case SportPalette.oceanBlue:
        return 'Ocean Blue';
      case SportPalette.fireRed:
        return 'Fire Red';
      case SportPalette.sunsetOrange:
        return 'Sunset Orange';
      case SportPalette.royalPurple:
        return 'Royal Purple';
    }
  }

  String get description {
    switch (this) {
      case SportPalette.pitchGreen:
        return 'Classic field green — football, soccer, cricket';
      case SportPalette.oceanBlue:
        return 'Cool ocean blue — aquatics, beach sports';
      case SportPalette.fireRed:
        return 'Fierce fire red — basketball, volleyball';
      case SportPalette.sunsetOrange:
        return 'Energy amber — running, cycling, tennis';
      case SportPalette.royalPurple:
        return 'Royal purple — ultimate frisbee, netball';
    }
  }

  /// The primary seed color for the preset (shown in the palette swatch).
  Color get seedColor {
    switch (this) {
      case SportPalette.pitchGreen:
        return const Color(0xFF1B8C3A);
      case SportPalette.oceanBlue:
        return const Color(0xFF0277BD);
      case SportPalette.fireRed:
        return const Color(0xFFD32F2F);
      case SportPalette.sunsetOrange:
        return const Color(0xFFE65100);
      case SportPalette.royalPurple:
        return const Color(0xFF6A1B9A);
    }
  }

  /// Secondary accent color (shown alongside in swatches).
  Color get accentColor {
    switch (this) {
      case SportPalette.pitchGreen:
        return const Color(0xFFFF8C00);
      case SportPalette.oceanBlue:
        return const Color(0xFF00BCD4);
      case SportPalette.fireRed:
        return const Color(0xFFFF6F00);
      case SportPalette.sunsetOrange:
        return const Color(0xFFFFC107);
      case SportPalette.royalPurple:
        return const Color(0xFFE91E63);
    }
  }

  IconData get icon {
    switch (this) {
      case SportPalette.pitchGreen:
        return Icons.sports_soccer;
      case SportPalette.oceanBlue:
        return Icons.pool;
      case SportPalette.fireRed:
        return Icons.sports_basketball;
      case SportPalette.sunsetOrange:
        return Icons.directions_run;
      case SportPalette.royalPurple:
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

  SportPalette _palette = SportPalette.pitchGreen;
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
        orElse: () => SportPalette.pitchGreen,
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
    return _buildLight(cs);
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
    return _buildDark(cs, primary);
  }

  // ── Shared light theme structure ─────────────────────────────────────────
  static ThemeData _buildLight(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
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
  static ThemeData _buildDark(ColorScheme cs, Color seedPrimary) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
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
