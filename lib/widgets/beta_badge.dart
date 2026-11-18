// ═══════════════════════════════════════════════════════════════
//  beta_badge.dart – Auffälliges "BETA"-Label
//
//  ✅ HIER ÄNDERN: Farbe, Größe, Text
//  ❌ NICHT ÄNDERN: Klassenname BetaBadge
//
//  Wird überall dort eingesetzt, wo ein Feature noch im Aufbau ist
//  (aktuell: Item-Datenbank – Karte in "Tools & Hilfe" und AppBar des
//  Item-Datenbank-Screens). Bewusst als gefüllte Pille in der
//  Warnfarbe (AppColors.warning) mit dunkler Schrift, damit sie
//  neben den sonst eher dezenten Labels sofort ins Auge fällt.
//
//  ÄNDERUNGEN (Item-Datenbank-Update):
//    - NEU: Datei.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          color: AppColors.darkBackground,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
