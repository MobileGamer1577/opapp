import 'package:flutter/material.dart';

/// AppColors – Farbsystem für OPAPP
/// Inspiriert vom dunklen Premium-Design (Deep Purple / Space)
abstract class AppColors {

  // === DARK THEME HINTERGRUENDE =====================================
  static const Color darkBackground   = Color(0xFF0A0814); // Tiefstes Dunkel-Lila
  static const Color darkSurface      = Color(0xFF100E20); // Etwas heller
  static const Color darkCard         = Color(0xFF16142C); // Karten-Hintergrund
  static const Color darkCardElevated = Color(0xFF1E1C38); // Hover / elevated
  static const Color darkBorder       = Color(0xFF2A2650); // Subtile Ränder

  // Gradient-Farben (Top -> Bottom wie im Referenz-Design)
  static const Color gradientTop      = Color(0xFF180F3D); // Lila-dunkel oben
  static const Color gradientBottom   = Color(0xFF060410); // Fast schwarz unten

  // === DARK THEME TEXT ===============================================
  static const Color darkTextPrimary   = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9090B8);
  static const Color darkTextHint      = Color(0xFF50507A);

  // === LICHT THEME (Fallback) ========================================
  static const Color lightBackground    = Color(0xFFF4F2FF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightBorder        = Color(0xFFE2DEFC);
  static const Color lightTextPrimary   = Color(0xFF0D0B1E);
  static const Color lightTextSecondary = Color(0xFF5E5A80);

  // === PRIMÄRER AKZENT (Lila / Violet) ==============================
  static const Color accent      = Color(0xFF7C5CF6); // Haupt-Lila
  static const Color accentLight = Color(0xFFA98EFA);
  static const Color accentDark  = Color(0xFF5438C8);

  // === SECTION-FARBEN (Icon-Hintergründe) ===========================
  // Jede Sektion hat eine eigene Farbe wie im Orbit-Design
  static const Color sectionMarket   = Color(0xFF00B894); // Grün  – Markt
  static const Color sectionAuction  = Color(0xFFE17055); // Orange – Auktionen
  static const Color sectionShards   = Color(0xFF7C5CF6); // Lila  – OPShards
  static const Color sectionHelp     = Color(0xFF74B9FF); // Blau  – Hilfe

  // === SEMANTISCHE FARBEN ===========================================
  static const Color success  = Color(0xFF00B894);
  static const Color warning  = Color(0xFFFDCB6E);
  static const Color error    = Color(0xFFEF5350);
  static const Color info     = Color(0xFF74B9FF);

  // === MARKT-FARBEN =================================================
  static const Color buyColor  = Color(0xFF00B894); // Kaufen  – Grün
  static const Color sellColor = Color(0xFFEF5350); // Verkaufen – Rot

  // === SPEZIAL ======================================================
  static const Color gold      = Color(0xFFFFD700);
  static const Color silver    = Color(0xFFB0BEC5);
}
