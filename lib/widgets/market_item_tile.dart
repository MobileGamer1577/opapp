// ═══════════════════════════════════════════════════════════════
//  market_item_tile.dart – Item-Zeile im Markt (Icon, Name,
//  Kategorie · Aufträge, Kauf-/Verkaufspreis)
//
//  ✅ HIER ÄNDERN: Kartendesign, Farben, angezeigte Felder
//  ❌ NICHT ÄNDERN: Preisanzeige über item.displayBuyPrice /
//                   item.displaySellPrice ("–" bei fehlendem Preis)
//
//  Wird von der Markt-Hauptseite ("Meistgehandelt") UND der
//  Markt-Liste verwendet – so sehen beide identisch aus. Die
//  Navigation (Tap) kommt von außen über [onTap].
//
//  ÄNDERUNGEN (Markt-Update, Nachbesserung):
//    - Kauf-/Verkaufspreise sind neutral (weiß) statt grün/rot, wie
//      in der offiziellen App. "–" bei fehlendem Preis bleibt gedämpft.
//
//  Enthält außerdem formatCount() – Ganzzahlen mit Tausenderpunkt
//  (3133 → "3.133"), auch vom Detail-Screen genutzt.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/models/market_item.dart';
import 'network_icon.dart';

/// Ganzzahl mit Tausenderpunkten, z.B. 231284 → "231.284".
String formatCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}$buffer';
}

class MarketItemTile extends StatelessWidget {
  final MarketItem item;
  final VoidCallback onTap;

  const MarketItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ─ Icon ─────────────────────────────────────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Center(
                  child: NetworkIcon(
                    url: item.icon,
                    size: 28,
                    assetFallback: item.material.isNotEmpty
                        ? minecraftAssetPath(item.material)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ─ Name + Kategorie · Aufträge ──────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.category} \u00b7 ${formatCount(item.totalOrders)} Aufträge',
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ─ Preise ───────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PriceLine(
                    label:  'Kaufen',
                    text:   item.displayBuyPrice,
                    active: item.hasBuyPrice,
                  ),
                  const SizedBox(height: 4),
                  _PriceLine(
                    label:  'Verkaufen',
                    text:   item.displaySellPrice,
                    active: item.hasSellPrice,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label, text;
  final bool active;
  const _PriceLine({
    required this.label,
    required this.text,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color:      active ? AppColors.darkTextPrimary : AppColors.darkTextHint,
            fontWeight: FontWeight.w700,
            fontSize:   14,
          ),
        ),
      ],
    );
  }
}
