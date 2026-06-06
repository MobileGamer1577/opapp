// ═══════════════════════════════════════════════════════════════
//  app_colors.dart – Das komplette Farbsystem
//
//  ✅ HIER ÄNDERN: Farben anpassen
//  ✅ HIER ÄNDERN: Neue Farben ergänzen
//  ❌ NICHT ÄNDERN: Klassennamen / Struktur
//
//  GRUNDREGEL:
//  Niemals Farben direkt in Screens schreiben (Color(0xFF...)).
//  Immer AppColors.xyz verwenden – so reicht eine Änderung hier.
//
//  AKZENTFARBE ÄNDERN (für komplett neues Farbschema):
//  Nur die drei 'accent' Werte ändern, alles andere passt sich an.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

abstract class AppColors {

  // ── Primärer Akzent ───────────────────────────────────────
  // Diese drei Werte bestimmen die Hauptfarbe der App.
  // Für ein anderes Farbschema: nur hier ändern.
  static const Color accent      = Color(0xFF7C5CF6); // Haupt-Lila
  static const Color accentLight = Color(0xFFA98EFA); // Aufgehellt (für Hover etc.)
  static const Color accentDark  = Color(0xFF5438C8); // Abgedunkelt (für Pressed etc.)

  // ── Dark Theme Hintergründe ───────────────────────────────
  // Von dunkelst nach hellst:
  static const Color gradientTop      = Color(0xFF180F3D); // Gradient oben (lila)
  static const Color gradientBottom   = Color(0xFF060410); // Gradient unten (fast schwarz)
  static const Color darkBackground   = Color(0xFF0A0814); // Standard-Hintergrund
  static const Color darkSurface      = Color(0xFF100E20); // Oberflächen (AppBar, BottomNav)
  static const Color darkCard         = Color(0xFF16142C); // Karten-Hintergrund
  static const Color darkCardElevated = Color(0xFF1E1C38); // Hervorgehobene Karten
  static const Color darkBorder       = Color(0xFF2A2650); // Rahmen / Trennlinien

  // ── Dark Theme Text ───────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFFFFFFF); // Überschriften, wichtig
  static const Color darkTextSecondary = Color(0xFF9090B8); // Beschreibungen, Labels
  static const Color darkTextHint      = Color(0xFF50507A); // Platzhalter, Hints

  // ── Light Theme (Fallback) ────────────────────────────────
  // Momentan nicht aktiv (App ist dauerhaft dunkel).
  // Für Light Mode: app_theme.dart anpassen + ThemeModeNotifier reaktivieren.
  static const Color lightBackground    = Color(0xFFF4F2FF);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightBorder        = Color(0xFFE2DEFC);
  static const Color lightTextPrimary   = Color(0xFF0D0B1E);
  static const Color lightTextSecondary = Color(0xFF5E5A80);

  // ── Section-Farben (Dashboard Icon-Hintergründe) ─────────
  // Jede Hauptsektion hat eine eigene Erkennungsfarbe.
  // Im Dashboard als Icon-Hintergrund + Rahmenfarbe verwendet.
  static const Color sectionMarket   = Color(0xFF00B894); // Grün  – Markt
  static const Color sectionAuction  = Color(0xFFE17055); // Orange – Auktionen
  static const Color sectionShards   = Color(0xFF7C5CF6); // Lila  – OPShards
  static const Color sectionHelp     = Color(0xFF74B9FF); // Blau  – Hilfe
  // ← Neue Sektion hier ergänzen:
  // static const Color sectionStats = Color(0xFFFF7675); // Rot – Statistiken

  // ── Semantische Farben ────────────────────────────────────
  // Diese Farben haben eine feste Bedeutung – nicht für Design verwenden.
  static const Color success = Color(0xFF00B894); // ✓ Erfolg, positiv, kaufen
  static const Color warning = Color(0xFFFDCB6E); // ⚠ Warnung, Achtung
  static const Color error   = Color(0xFFEF5350); // ✗ Fehler, negativ, verkaufen
  static const Color info    = Color(0xFF74B9FF); // ℹ Information

  // ── Markt-Preisfarben ─────────────────────────────────────
  static const Color buyColor  = Color(0xFF00B894); // Kaufpreis (grün = gut für Käufer)
  static const Color sellColor = Color(0xFFEF5350); // Verkaufspreis (rot = niedriger)

  // ── Spezial ───────────────────────────────────────────────
  static const Color gold   = Color(0xFFFFD700); // Sofort-Kauf Preis im Auktionshaus
  static const Color silver = Color(0xFFB0BEC5); // Sekundäre Hervorhebungen
}
