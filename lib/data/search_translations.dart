// ═══════════════════════════════════════════════════════════════
//  search_translations.dart – Deutsch↔Englisch-Mapping für die
//  Item-Suche (Markt & Auktionshaus)
//
//  ✅ HIER ÄNDERN: Begriffe ergänzen/korrigieren
//  ❌ NICHT ÄNDERN: matchesWithTranslation()-Logik
//
//  HINTERGRUND: /market/items liefert alle Namen nur auf Englisch
//  (siehe api.opsucht.net), die App zeigt sie entsprechend nur
//  englisch formatiert an (_formatMaterial in market_item.dart
//  übersetzt NICHT, sondern schreibt nur groß + trennt Unterstriche
//  – reine Anzeige-Logik, wird hier NICHT angefasst). Eine deutsche
//  Sucheingabe wie "Diamant" würde daher nie etwas finden – dieses
//  Mapping schließt die Suchlücke, ohne die Anzeige selbst zu ändern.
//
//  Bewusst KEIN 1:1-Ersetzen des Suchbegriffs, sondern eine
//  ZUSÄTZLICHE Erweiterung: Die normale Suche (Name/Material enthält
//  Suchbegriff) läuft immer zuerst; trifft ein deutscher Begriff hier
//  zusätzlich zu, wird der zugehörige englische Begriff ZUSÄTZLICH
//  geprüft.
// ═══════════════════════════════════════════════════════════════

/// Deutscher Begriff (klein geschrieben) → englischer Teil-Begriff,
/// wie er im (englischen) Item-Namen bzw. der Material-ID vorkommt.
const Map<String, String> germanToEnglishTerms = {
  // ── Erze & Mineralien ──
  'diamant': 'diamond',
  'eisen': 'iron',
  'gold': 'gold',
  'kohle': 'coal',
  'redstone': 'redstone',
  'lapis': 'lapis',
  'smaragd': 'emerald',
  'netherit': 'netherite',
  'quarz': 'quartz',
  'kupfer': 'copper',
  'amethyst': 'amethyst',

  // ── Steine & Erde ──
  'stein': 'stone',
  'kopfsteinpflaster': 'cobblestone',
  'kies': 'gravel',
  'sand': 'sand',
  'erde': 'dirt',
  'gras': 'grass',
  'andesit': 'andesite',
  'diorit': 'diorite',
  'granit': 'granite',
  'basalt': 'basalt',
  'obsidian': 'obsidian',
  'tiefenschiefer': 'deepslate',
  'schiefer': 'deepslate',
  'ton': 'clay',
  'tuffstein': 'tuff',

  // ── Holzarten ──
  'eiche': 'oak',
  'birke': 'birch',
  'fichte': 'spruce',
  'akazie': 'acacia',
  'dschungel': 'jungle',
  'tropenbaum': 'jungle',
  'schwarzeiche': 'dark_oak',
  'mangrove': 'mangrove',
  'kirsche': 'cherry',
  'blasseiche': 'pale_oak',
  'bambus': 'bamboo',
  'stamm': 'log',
  'planke': 'plank',
  'planken': 'planks',
  'blatt': 'leaves',
  'blätter': 'leaves',
  'setzling': 'sapling',

  // ── Werkzeuge & Waffen ──
  'schwert': 'sword',
  'spitzhacke': 'pickaxe',
  'axt': 'axe',
  'schaufel': 'shovel',
  'hacke': 'hoe',
  'bogen': 'bow',
  'pfeil': 'arrow',
  'dreizack': 'trident',
  'armbrust': 'crossbow',

  // ── Rüstung ──
  'helm': 'helmet',
  'brustplatte': 'chestplate',
  'hose': 'leggings',
  'stiefel': 'boots',
  'schild': 'shield',

  // ── Nahrung ──
  'apfel': 'apple',
  'brot': 'bread',
  'karotte': 'carrot',
  'kartoffel': 'potato',
  'kuchen': 'cake',
  'kekse': 'cookie',
  'melone': 'melon',
  'kürbis': 'pumpkin',
  'fisch': 'fish',
  'rindfleisch': 'beef',
  'schweinefleisch': 'porkchop',
  'hühnchen': 'chicken',

  // ── Sonstiges / häufig gesucht ──
  'truhe': 'chest',
  'leiter': 'ladder',
  'glas': 'glass',
  'wolle': 'wool',
  'teppich': 'carpet',
  'fackel': 'torch',
  'laterne': 'lantern',
  'schienen': 'rails',
  'boot': 'boat',
  'sattel': 'saddle',
  'leder': 'leather',
  'schleimball': 'slime_ball',
  'ei': 'egg',
  'knochen': 'bone',
  'perle': 'pearl',
  'spinnenauge': 'spider_eye',
  'buch': 'book',
  'papier': 'paper',
  'eimer': 'bucket',
  'wasser': 'water',
  'lava': 'lava',
  'schwamm': 'sponge',
  'blume': 'flower',
};

/// Prüft, ob [query] auf [target] (z.B. Item-Name ODER Material-ID)
/// passt – entweder direkt (bisheriges Verhalten) oder über die
/// deutsch→englisch-Erweiterung oben.
bool matchesWithTranslation(String query, String target) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  final t = target.toLowerCase();

  if (t.contains(q)) return true;

  // Deutschen Suchbegriff auf einen englischen Teil-Begriff abbilden
  // und zusätzlich damit prüfen. .contains() statt exaktem Vergleich,
  // damit auch zusammengesetzte Begriffe (z.B. "eichenstamm") grob
  // funktionieren, auch wenn nicht jede Kombination im Wörterbuch steht.
  for (final entry in germanToEnglishTerms.entries) {
    if (q.contains(entry.key) && t.contains(entry.value)) return true;
  }
  return false;
}
