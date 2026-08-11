// ═══════════════════════════════════════════════════════════════
//  network_icon.dart – Wiederverwendbares Icon mit Lade-/Fehler-Fallback
//
//  ✅ HIER ÄNDERN: fallback-Icon im jeweiligen Aufruf anpassen
//  ❌ NICHT ÄNDERN: Grundstruktur
//
//  Für Markt- und Auktions-Kategorie-Icons (alle kommen von
//  img.mc-api.io). Bewusst eigenständige Datei, damit market_screen.dart
//  unangetastet bleibt – falls du dort später auch umstellen willst,
//  einfach die private _NetworkIcon-Klasse dort durch diese ersetzen.
//
//  ÄNDERUNGEN (Auktionshaus-Icon-Update):
//    - NEU: optionaler Parameter assetFallback – wenn gesetzt, wird
//      VOR dem generischen [fallback]-Icon zusätzlich ein lokales
//      Asset probiert (3-stufig: Netzwerk-URL → lokales Asset →
//      generisches Icon). Bleibt assetFallback null (Standard),
//      verhält sich das Widget exakt wie bisher (2-stufig) – alle
//      bestehenden Aufrufer (Markt-/Auktions-Kategorie-Chips) sind
//      davon unberührt.
//    - NEU: minecraftAssetPath() – baut den lokalen Asset-Pfad aus
//      einer Material-ID (siehe pubspec.yaml: assets/icons/minecraft/).
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Baut den lokalen Asset-Pfad zu einer Material-ID, z.B.
/// "YELLOW_SHULKER_BOX" → "assets/icons/minecraft/minecraft_yellow_shulker_box.png"
String minecraftAssetPath(String material) =>
    'assets/icons/minecraft/minecraft_${material.toLowerCase()}.png';

class NetworkIcon extends StatelessWidget {
  final String? url;
  final double size;
  final IconData fallback;

  /// ✅ NEU (Auktionshaus-Icon-Update): optionaler Pfad zu einem
  /// lokalen Minecraft-Asset (z.B. via minecraftAssetPath()), der
  /// probiert wird, BEVOR auf das generische [fallback]-Icon
  /// zurückgefallen wird. Bleibt null, überspringt diese Stufe
  /// komplett (bisheriges 2-stufiges Verhalten).
  final String? assetFallback;

  const NetworkIcon({
    super.key,
    required this.url,
    this.size = 28,
    this.fallback = Icons.inventory_2_outlined,
    this.assetFallback,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildAssetOrFallback();
    }
    return Image.network(
      url!,
      width:  size,
      height: size,
      fit:    BoxFit.contain,
      filterQuality: FilterQuality.none, // Pixel-Art bleibt scharf
      errorBuilder: (_, __, ___) => _buildAssetOrFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: const CircularProgressIndicator(
                  strokeWidth: 1.5, color: AppColors.accent),
            ),
          ),
        );
      },
    );
  }

  /// Stufe 2 (lokales Asset, falls [assetFallback] gesetzt) → Stufe 3
  /// (generisches [fallback]-Icon).
  Widget _buildAssetOrFallback() {
    if (assetFallback == null || assetFallback!.isEmpty) {
      return Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6);
    }
    return Image.asset(
      assetFallback!,
      width:  size,
      height: size,
      fit:    BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, __, ___) =>
          Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6),
    );
  }
}
