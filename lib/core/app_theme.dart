import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

// ─── Nur Dark Mode ───────────────────────────────────────────
// Light Mode entfernt – App ist dauerhaft dunkel
abstract class AppTheme {
  static ThemeData get dark {
    const textPri = AppColors.darkTextPrimary;
    const textSec = AppColors.darkTextSecondary;
    const card    = AppColors.darkCard;
    const border  = AppColors.darkBorder;

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness:  Brightness.dark,
        primary:     AppColors.accent,
        onPrimary:   Colors.white,
        secondary:   AppColors.accentLight,
        onSecondary: Colors.white,
        error:       AppColors.error,
        onError:     Colors.white,
        surface:     AppColors.darkSurface,
        onSurface:   textPri,
      ),
      scaffoldBackgroundColor: Colors.transparent,

      appBarTheme: const AppBarTheme(
        backgroundColor:        Colors.transparent,
        foregroundColor:        textPri,
        elevation:              0,
        scrolledUnderElevation: 0,
        systemOverlayStyle:     SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color:       textPri,
          fontSize:    18,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),

      cardTheme: CardThemeData(
        color:     card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:         true,
        fillColor:      card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:      const TextStyle(color: textSec, fontSize: 14),
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

      textTheme: const TextTheme(
        displayLarge:   TextStyle(color: textPri, fontWeight: FontWeight.w800),
        displayMedium:  TextStyle(color: textPri, fontWeight: FontWeight.w700),
        headlineLarge:  TextStyle(color: textPri, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPri, fontWeight: FontWeight.w600),
        titleLarge:     TextStyle(color: textPri, fontWeight: FontWeight.w700),
        titleMedium:    TextStyle(color: textPri, fontWeight: FontWeight.w600),
        bodyLarge:      TextStyle(color: textPri),
        bodyMedium:     TextStyle(color: textSec),
        bodySmall:      TextStyle(color: textSec, fontSize: 12),
        labelLarge:     TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
      ),

      dividerTheme: DividerThemeData(
        color:     border,
        thickness: 1,
        space:     1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor:   AppColors.accent.withOpacity(0.20),
        side:            BorderSide(color: border),
        labelStyle:      const TextStyle(color: textSec, fontSize: 12),
        padding:         const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation:       0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }
}
