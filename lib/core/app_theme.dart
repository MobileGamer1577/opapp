import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

// ─── ThemeMode Provider ──────────────────────────────────────
const _prefKey = 'theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored == 'light') state = ThemeMode.light;
    if (stored == 'system') state = ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  void toggle() =>
      setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

// ─── AppTheme ────────────────────────────────────────────────
abstract class AppTheme {
  static ThemeData get dark  => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg      = isDark ? AppColors.darkBackground    : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface       : AppColors.lightSurface;
    final card    = isDark ? AppColors.darkCard           : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder         : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkTextPrimary    : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary  : AppColors.lightTextSecondary;

    // Statusbar-Icons hell im Dark Mode
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final colorScheme = ColorScheme(
      brightness:  brightness,
      primary:     AppColors.accent,
      onPrimary:   Colors.white,
      secondary:   AppColors.accentLight,
      onSecondary: Colors.white,
      error:       AppColors.error,
      onError:     Colors.white,
      surface:     surface,
      onSurface:   textPri,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  colorScheme,
      // Transparent damit der Gradient-Container aus main_scaffold durchscheint
      scaffoldBackgroundColor: Colors.transparent,

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:          Colors.transparent,
        foregroundColor:          textPri,
        elevation:                0,
        scrolledUnderElevation:   0,
        systemOverlayStyle:       overlayStyle,
        titleTextStyle: TextStyle(
          color:       textPri,
          fontSize:    18,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),

      // ── Bottom Navigation Bar ───────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedItemColor:    AppColors.accent,
        unselectedItemColor:  textSec,
        elevation:            0,
        type:                 BottomNavigationBarType.fixed,
        selectedLabelStyle:   const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),

      // ── Cards ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:     card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:         true,
        fillColor:      card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:      TextStyle(color: textSec, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),

      // ── Text ────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  TextStyle(color: textPri, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: textPri, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: textPri, fontWeight: FontWeight.w700),
        headlineMedium:TextStyle(color: textPri, fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: textPri, fontWeight: FontWeight.w700),
        titleMedium:   TextStyle(color: textPri, fontWeight: FontWeight.w600),
        bodyLarge:     TextStyle(color: textPri),
        bodyMedium:    TextStyle(color: textSec),
        bodySmall:     TextStyle(color: textSec, fontSize: 12),
        labelLarge:    const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     border,
        thickness: 1,
        space:     1,
      ),

      // ── Chips ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor:   AppColors.accent.withOpacity(0.20),
        side:            BorderSide(color: border),
        labelStyle:      TextStyle(color: textSec, fontSize: 12),
        padding:         const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // ── ElevatedButton ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation:       0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
