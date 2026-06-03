import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────
//  ThemeMode Provider – speichert und lädt die Theme-Präferenz
// ─────────────────────────────────────────────────────────────

const _prefKey = 'theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored == 'light') state = ThemeMode.light;
    if (stored == 'system') state = ThemeMode.system;
    // Default: dark (bereits gesetzt)
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }

  void toggle() => setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}

// ─────────────────────────────────────────────────────────────
//  AppTheme – generiert ThemeData für Dark & Light
// ─────────────────────────────────────────────────────────────

abstract class AppTheme {
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);
  static ThemeData get light => _buildTheme(brightness: Brightness.light);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final bg      = isDark ? AppColors.darkBackground    : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface       : AppColors.lightSurface;
    final card    = isDark ? AppColors.darkCard           : AppColors.lightCard;
    final border  = isDark ? AppColors.darkBorder         : AppColors.lightBorder;
    final textPri = isDark ? AppColors.darkTextPrimary    : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary  : AppColors.lightTextSecondary;

    final colorScheme = ColorScheme(
      brightness:     brightness,
      primary:        AppColors.accent,
      onPrimary:      Colors.white,
      secondary:      AppColors.accentLight,
      onSecondary:    Colors.white,
      error:          AppColors.error,
      onError:        Colors.white,
      surface:        surface,
      onSurface:      textPri,
    );

    return ThemeData(
      useMaterial3:    true,
      colorScheme:     colorScheme,
      scaffoldBackgroundColor: bg,

      // ─── AppBar ───────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  bg,
        foregroundColor:  textPri,
        elevation:        0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color:       textPri,
          fontSize:    18,
          fontWeight:  FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      // ─── BottomNavigationBar ──────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      surface,
        selectedItemColor:    AppColors.accent,
        unselectedItemColor:  textSec,
        elevation:            0,
        type:                 BottomNavigationBarType.fixed,
        selectedLabelStyle:   const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),

      // ─── Cards ────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:       card,
        elevation:   0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── InputDecoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        card,
        contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle:        TextStyle(color: textSec, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),

      // ─── Text ─────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  TextStyle(color: textPri, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: textPri, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: textPri, fontWeight: FontWeight.w600),
        headlineMedium:TextStyle(color: textPri, fontWeight: FontWeight.w600),
        titleLarge:    TextStyle(color: textPri, fontWeight: FontWeight.w600),
        titleMedium:   TextStyle(color: textPri, fontWeight: FontWeight.w500),
        bodyLarge:     TextStyle(color: textPri),
        bodyMedium:    TextStyle(color: textSec),
        bodySmall:     TextStyle(color: textSec, fontSize: 12),
        labelLarge:    const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
      ),

      // ─── Divider ──────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     border,
        thickness: 1,
        space:     1,
      ),

      // ─── Chips ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:    card,
        selectedColor:      AppColors.accent.withOpacity(0.15),
        side:               BorderSide(color: border),
        labelStyle:         TextStyle(color: textSec, fontSize: 12),
        padding:            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
