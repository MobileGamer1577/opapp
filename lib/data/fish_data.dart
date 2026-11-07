// ═══════════════════════════════════════════════════════════════
//  fish_data.dart – Fisch-Liste für das Fischerei-Logbuch (Fischerjob)
//
//  ✅ HIER ÄNDERN: Fische/Biomgruppen ergänzen oder korrigieren,
//                  Job-XP je Seltenheit (FishRarity.xp)
//  ❌ NICHT ÄNDERN: Klassen FishSpecies / FishRarity / Variablenname
//                   kFishSpecies. Der Fisch-NAME ist zugleich der
//                   Speicher-Schlüssel für den Fortschritt
//                   (SharedPreferences) – einen bestehenden Namen
//                   umzubenennen "vergisst" den Haken bei diesem
//                   Fisch. Namen müssen eindeutig sein (auch gruppen-
//                   übergreifend)!
//
//  NEUEN FISCH ERGÄNZEN (Reihenfolge je Gruppe: Häufig → Sensation):
//    FishSpecies.common('Name', _gruppe),
//    FishSpecies.epic('Name', _gruppe),
//    FishSpecies.legendary('Name', _gruppe),
//    FishSpecies.spectacular('Name', _gruppe),
//    FishSpecies.sensation('Name', _gruppe),
//  Neue Biomgruppe: Konstante unten anlegen UND in kFishBiomeGroups
//  eintragen (steuert die Filter-Chips im Logbuch-Screen).
//
//  QUELLE: OPSUCHT Wiki – Angler → Fangsystem
//  (wiki.opsucht.net/opsucht-features/wirtschaft/jobs/angler/fangsystem/)
//  Je Biomgruppe gibt es genau 13 Custom-Fische: 5 Häufige, 4 Epische,
//  2 Legendäre, 1 Spektakulärer und 1 Sensation → 8 × 13 = 104.
//
//  ÄNDERUNGEN (Fischerei-Logbuch-Update):
//    - NEU: Datei. Aufbau analog zu mobdex_data.dart (typisierte
//      Klasse statt Map, const-Liste, Name = Speicher-Schlüssel).
//    - Fisch-Zuordnung (Gruppe + Seltenheit) stammt 1:1 aus der
//      Wiki-Tabelle. Die in der Aufgabenstellung gelieferte Liste war
//      gegenüber dem Wiki jeweils um eine Position verschoben (z.B.
//      "Felsenbarsch" stand unter Flüsse statt Kalte & bergige Biome,
//      "Äsche" war Häufig statt Episch) – es gilt das Wiki.
// ═══════════════════════════════════════════════════════════════

/// Seltenheitsstufen der Custom-Fische (aufsteigend).
enum FishRarity {
  common(label: 'Häufig', xp: 150),
  epic(label: 'Episch', xp: 200),
  legendary(label: 'Legendär', xp: 750),
  spectacular(label: 'Spektakulär', xp: 3500),
  sensation(label: 'Sensation', xp: 50000);

  const FishRarity({required this.label, required this.xp});

  /// Anzeigename (deutsch).
  final String label;

  /// Job-XP pro Fang (Referenzwert aus dem Wiki).
  final int xp;
}

// ── Biomgruppen ───────────────────────────────────────────────
const String _end = 'End';
const String _rivers = 'Flüsse & Binnengewässer';
const String _cold = 'Kalte & bergige Biome';
const String _seas = 'Meere & Küsten';
const String _nether = 'Nether';
const String _plot = 'Plotwelt';
const String _swamp = 'Sumpf & Tropen';
const String _warm = 'Warme & trockene Biome';

/// Biomgruppen in Anzeige-Reihenfolge (Filter-Chips im Screen).
const List<String> kFishBiomeGroups = [
  _end,
  _rivers,
  _cold,
  _seas,
  _nether,
  _plot,
  _swamp,
  _warm,
];

/// Ein Custom-Fisch im Fischerei-Logbuch.
class FishSpecies {
  final String name;

  /// Biomgruppe, z.B. "Nether" (siehe kFishBiomeGroups).
  final String biomeGroup;
  final FishRarity rarity;

  const FishSpecies.common(this.name, this.biomeGroup)
      : rarity = FishRarity.common;
  const FishSpecies.epic(this.name, this.biomeGroup)
      : rarity = FishRarity.epic;
  const FishSpecies.legendary(this.name, this.biomeGroup)
      : rarity = FishRarity.legendary;
  const FishSpecies.spectacular(this.name, this.biomeGroup)
      : rarity = FishRarity.spectacular;
  const FishSpecies.sensation(this.name, this.biomeGroup)
      : rarity = FishRarity.sensation;
}

/// Alle 104 Custom-Fische, sortiert nach Biomgruppe, dann Seltenheit.
const List<FishSpecies> kFishSpecies = [
  // ══ End ═══════════════════════════════════════════════════
  FishSpecies.common('Dickschädel', _end),
  FishSpecies.common('Wildcods', _end),
  FishSpecies.common('Schimmerauge', _end),
  FishSpecies.common('Flinkling', _end),
  FishSpecies.common('Zopperino', _end),
  FishSpecies.epic('Weißgroppe', _end),
  FishSpecies.epic('Leuchthummer', _end),
  FishSpecies.epic('Orakelfisch', _end),
  FishSpecies.epic('Zwielichtflosse', _end),
  FishSpecies.legendary('Auroralia', _end),
  FishSpecies.legendary('Voidstachler', _end),
  FishSpecies.spectacular('Schimmernder Rochen', _end),
  FishSpecies.sensation('Drachenfisch', _end),

  // ══ Flüsse & Binnengewässer ═══════════════════════════════
  FishSpecies.common('Blauer Sonnenbarsch', _rivers),
  FishSpecies.common('Rotauge', _rivers),
  FishSpecies.common('Barsch', _rivers),
  FishSpecies.common('Forelle', _rivers),
  FishSpecies.common('Brasse', _rivers),
  FishSpecies.epic('Äsche', _rivers),
  FishSpecies.epic('Hecht', _rivers),
  FishSpecies.epic('Schleie', _rivers),
  FishSpecies.epic('Felchen', _rivers),
  FishSpecies.legendary('Crappie', _rivers),
  FishSpecies.legendary('Pico', _rivers),
  FishSpecies.spectacular('Stör', _rivers),
  FishSpecies.sensation('Teamlerfisch', _rivers),

  // ══ Kalte & bergige Biome ═════════════════════════════════
  FishSpecies.common('Felsenbarsch', _cold),
  FishSpecies.common('Wildlachs', _cold),
  FishSpecies.common('Trommlerfisch', _cold),
  FishSpecies.common('Muschel', _cold),
  FishSpecies.common('Kabeljochen', _cold),
  FishSpecies.epic('Lengdorsch', _cold),
  FishSpecies.epic('Heilbutt', _cold),
  FishSpecies.epic('Kohlenfisch', _cold),
  FishSpecies.epic('Thunfisch', _cold),
  FishSpecies.legendary('Schwertfisch', _cold),
  FishSpecies.legendary('Mondfisch', _cold),
  FishSpecies.spectacular('Tintenfisch', _cold),
  FishSpecies.sensation('Creatorfisch', _cold),

  // ══ Meere & Küsten ════════════════════════════════════════
  FishSpecies.common('Hering', _seas),
  FishSpecies.common('Auster', _seas),
  FishSpecies.common('Miesmuschel', _seas),
  FishSpecies.common('Meeresschnecke', _seas),
  FishSpecies.common('Krabbe', _seas),
  FishSpecies.epic('Makrele', _seas),
  FishSpecies.epic('Oktopus', _seas),
  FishSpecies.epic('Seeigel', _seas),
  FishSpecies.epic('Seestern', _seas),
  FishSpecies.legendary('Hummer', _seas),
  FishSpecies.legendary('Seegurke', _seas),
  FishSpecies.spectacular('Hai', _seas),
  FishSpecies.sensation('Maselfisch', _seas),

  // ══ Nether ════════════════════════════════════════════════
  FishSpecies.common('Glühfisch', _nether),
  FishSpecies.common('Heißling', _nether),
  FishSpecies.common('Kohlspitze', _nether),
  FishSpecies.common('Giftsauger', _nether),
  FishSpecies.common('Lavaclown', _nether),
  FishSpecies.epic('Lavalachs', _nether),
  FishSpecies.epic('Schwarzhummer', _nether),
  FishSpecies.epic('Glumaral', _nether),
  FishSpecies.epic('Panzerwels', _nether),
  FishSpecies.legendary('Giftklinger', _nether),
  FishSpecies.legendary('Hitzeflunder', _nether),
  FishSpecies.spectacular('Netheraal', _nether),
  FishSpecies.sensation('Willfisch', _nether),

  // ══ Plotwelt ══════════════════════════════════════════════
  FishSpecies.common('Bonito', _plot),
  FishSpecies.common('Tilapia', _plot),
  FishSpecies.common('Zackenbarsch', _plot),
  FishSpecies.common('Plotbarsch', _plot),
  FishSpecies.common('Stadtforelle', _plot),
  FishSpecies.epic('Zander', _plot),
  FishSpecies.epic('Grumpy', _plot),
  FishSpecies.epic('Flunder', _plot),
  FishSpecies.epic('Lukasfisch', _plot),
  FishSpecies.legendary('Entdeckerfisch', _plot),
  FishSpecies.legendary('Maseli', _plot),
  FishSpecies.spectacular('Allayfisch', _plot),
  FishSpecies.sensation('Philfisch', _plot),

  // ══ Sumpf & Tropen ════════════════════════════════════════
  FishSpecies.common('Frosch', _swamp),
  FishSpecies.common('Schlingel', _swamp),
  FishSpecies.common('Schleicher', _swamp),
  FishSpecies.common('Garnele', _swamp),
  FishSpecies.common('Kugelfisch', _swamp),
  FishSpecies.epic('Aal', _swamp),
  FishSpecies.epic('Wels', _swamp),
  FishSpecies.epic('Karpfen', _swamp),
  FishSpecies.epic('Schwarzbarsch', _swamp),
  FishSpecies.legendary('Tarpun', _swamp),
  FishSpecies.legendary('Murkel', _swamp),
  FishSpecies.spectacular('Knochenhecht', _swamp),
  FishSpecies.sensation('Contentfisch', _swamp),

  // ══ Warme & trockene Biome ════════════════════════════════
  FishSpecies.common('Sardelle', _warm),
  FishSpecies.common('Sardine', _warm),
  FishSpecies.common('Seebarsch', _warm),
  FishSpecies.common('Schnapper', _warm),
  FishSpecies.common('Kobia', _warm),
  FishSpecies.epic('Qualle', _warm),
  FishSpecies.epic('Fliegender Fisch', _warm),
  FishSpecies.epic('Sherpel', _warm),
  FishSpecies.epic('Barrakuda', _warm),
  FishSpecies.legendary('Königsfisch', _warm),
  FishSpecies.legendary('Goldmakrele', _warm),
  FishSpecies.spectacular('Marlin', _warm),
  FishSpecies.sensation('Emmyfisch', _warm),
];
