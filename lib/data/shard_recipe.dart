// ═══════════════════════════════════════════════════════════════
//  shard_recipe.dart – Rezepte für die drei Sammel-Items im
//  Wertstoffhändler (Gräbergemisch, Holzbündel, Steinplatten)
//
//  ✅ HIER ÄNDERN: Rohstoff-Option ergänzen/entfernen oder
//                  amountPerUnit anpassen, falls sich ein Rezept auf
//                  dem Server mal ändern sollte
//  ❌ NICHT ÄNDERN: Klassenstruktur ShardRecipe/RecipeOption
//
//  WICHTIG: Für jede Einheit wird IMMER nur EINE Rohstoff-Sorte in
//  der angegebenen Menge benötigt – die Optionen sind Alternativen,
//  keine Mischung (z.B. 576× NUR Kies ODER NUR Sand, nicht gemischt).
//
//  "material" muss exakt mit der Material-ID aus /market/prices bzw.
//  /market/items übereinstimmen (siehe MarketItem.material), damit
//  der Rechner (shard_calculator.dart) den Marktpreis dazu findet.
//
//  Schlüssel der Map = ShardItem.displayName. Custom-Items haben
//  keine eigene material-ID (athKey fällt dann auf displayName
//  zurück – siehe shard_rate.dart), gleiches Prinzip hier.
//
//  Items OHNE Eintrag hier (z.B. Diamant Block, Netherite Barren,
//  alle aktuellen RedCoins-Items) sind "einfache" Items – dafür wird
//  im Rechner direkt der Marktpreis über ShardItem.material
//  nachgeschlagen, kein Rezept nötig (siehe shard_calculator.dart).
// ═══════════════════════════════════════════════════════════════

/// Eine mögliche Rohstoff-Option für ein Rezept.
class RecipeOption {
  final String material; // z.B. "OAK_LOG" – muss zu MarketItem.material passen
  final String displayName; // z.B. "Eichenstamm"

  const RecipeOption({required this.material, required this.displayName});
}

/// Rezept für ein Custom-Item: [amountPerUnit] Stück EINER der
/// [options] ergeben 1 Einheit des Ziel-Items.
class ShardRecipe {
  final int amountPerUnit;
  final List<RecipeOption> options;

  const ShardRecipe({required this.amountPerUnit, required this.options});
}

/// Bekannte Rezepte, Schlüssel = ShardItem.displayName.
const Map<String, ShardRecipe> shardRecipes = {
  'Gräbergemisch': ShardRecipe(
    amountPerUnit: 576,
    options: [
      RecipeOption(material: 'GRAVEL', displayName: 'Kies'),
      RecipeOption(material: 'RED_SAND', displayName: 'Roter Sand'),
      RecipeOption(material: 'SAND', displayName: 'Sand'),
    ],
  ),
  'Holzbündel': ShardRecipe(
    amountPerUnit: 576,
    options: [
      RecipeOption(material: 'ACACIA_LOG', displayName: 'Akazienstamm'),
      RecipeOption(material: 'BIRCH_LOG', displayName: 'Birkenstamm'),
      RecipeOption(material: 'CHERRY_LOG', displayName: 'Kirschstamm'),
      RecipeOption(material: 'DARK_OAK_LOG', displayName: 'Schwarzeichenstamm'),
      RecipeOption(material: 'JUNGLE_LOG', displayName: 'Tropenbaumstamm'),
      RecipeOption(material: 'MANGROVE_LOG', displayName: 'Mangrovenstamm'),
      RecipeOption(material: 'OAK_LOG', displayName: 'Eichenstamm'),
      RecipeOption(material: 'PALE_OAK_LOG', displayName: 'Blasseichenstamm'),
      RecipeOption(material: 'SPRUCE_LOG', displayName: 'Fichtenstamm'),
    ],
  ),
  'Steinplatten': ShardRecipe(
    amountPerUnit: 576,
    options: [
      RecipeOption(material: 'ANDESITE', displayName: 'Andesit'),
      RecipeOption(material: 'DIORITE', displayName: 'Diorit'),
      RecipeOption(material: 'GRANITE', displayName: 'Granit'),
    ],
  ),
};
