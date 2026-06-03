import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────
///  AppColors – zentrales Farbsystem für OPAPP
///
///  Alle Farben werden hier definiert. Wechsel des Themes
///  (z.B. Akzentfarbe) erfolgt NUR in dieser Datei.
///
///  Aktuelles Theme: Dark Mode Standard, Akzent Cyan/Teal
/// ─────────────────────────────────────────────────────────
abstract class AppColors {
  // ─── Primäre Akzentfarbe (später über ThemeProvider änderbar) ──
  static const Color accent        = Color(0xFF00BFA5); // Teal
  static const Color accentLight   = Color(0xFF4DD0C4);
  static const Color accentDark    = Color(0xFF00897B);

  // ─── Dark Theme Hintergründe ────────────────────────────────
  static const Color darkBackground    = Color(0xFF0F1117);
  static const Color darkSurface       = Color(0xFF1A1D27);
  static const Color darkCard          = Color(0xFF1E2130);
  static const Color darkCardElevated  = Color(0xFF252840);
  static const Color darkBorder        = Color(0xFF2A2D3E);
  static const Color darkDivider       = Color(0xFF1E2130);

  // ─── Dark Theme Text ────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFF0F2FF);
  static const Color darkTextSecondary = Color(0xFF8B91B0);
  static const Color darkTextHint      = Color(0xFF555A75);

  // ─── Light Theme Hintergründe ───────────────────────────────
  static const Color lightBackground   = Color(0xFFF5F7FA);
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightCard         = Color(0xFFFFFFFF);
  static const Color lightBorder       = Color(0xFFE0E4EF);

  // ─── Light Theme Text ───────────────────────────────────────
  static const Color lightTextPrimary  = Color(0xFF0F1117);
  static const Color lightTextSecondary= Color(0xFF5A607A);

  // ─── Semantische Farben (theme-unabhängig) ──────────────────
  static const Color success  = Color(0xFF4CAF82);
  static const Color warning  = Color(0xFFFFC107);
  static const Color error    = Color(0xFFEF5350);
  static const Color info     = Color(0xFF42A5F5);

  // ─── Kauf / Verkauf Farben ──────────────────────────────────
  static const Color buyColor  = Color(0xFF4CAF82);  // Grün = kaufen
  static const Color sellColor = Color(0xFFEF5350);  // Rot = verkaufen

  // ─── Spezial ────────────────────────────────────────────────
  static const Color gold   = Color(0xFFFFD700);
  static const Color silver = Color(0xFFB0BEC5);
}
