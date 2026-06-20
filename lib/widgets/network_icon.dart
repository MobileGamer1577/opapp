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
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class NetworkIcon extends StatelessWidget {
  final String? url;
  final double size;
  final IconData fallback;

  const NetworkIcon({
    super.key,
    required this.url,
    this.size = 28,
    this.fallback = Icons.inventory_2_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6);
    }
    return Image.network(
      url!,
      width:  size,
      height: size,
      fit:    BoxFit.contain,
      filterQuality: FilterQuality.none, // Pixel-Art bleibt scharf
      errorBuilder: (_, __, ___) =>
          Icon(fallback, color: AppColors.darkTextHint, size: size * 0.6),
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
}
