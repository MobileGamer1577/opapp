// ═══════════════════════════════════════════════════════════════
//  mobdex_data.dart – Mob-Liste für den Mobdex (Jägerjob)
//
//  ✅ HIER ÄNDERN: Mobs/Biome ergänzen oder korrigieren, Cooldown-
//                  Dauer (kMobdexCooldown), XP-Ziel (kHunterMilestoneXp)
//  ❌ NICHT ÄNDERN: Klasse MobdexMob / Variablenname kMobdexMobs.
//                   Der Mob-NAME ist zugleich der Speicher-Schlüssel
//                   für den Fortschritt (SharedPreferences) – einen
//                   bestehenden Namen umzubenennen "vergisst" den Haken
//                   bei diesem Mob. Namen müssen eindeutig sein!
//
//  NEUEN MOB ERGÄNZEN:
//    Custom-Mob:  MobdexMob.custom('Name', 'Farmwelt', 'Biom1, Biom2'),
//    Vanilla-Mob: MobdexMob.vanilla('Name', 'Overworld', 'Biom1, Biom2'),
//  Mehrere Welten werden mit " / " getrennt ("Overworld / Nether") –
//  der Welt-Filter im Mobdex-Screen arbeitet auf diesen Teilen.
//
//  QUELLE: Custom-Mobs mit Biomen aus dem OPSUCHT Wiki, Vanilla-Mobs
//  mit Welt/Standard-Biomen (vom Projektinhaber geliefert).
//
//  ÄNDERUNGEN (Mobdex-Update):
//    - NEU: Datei. Die ursprünglich gelieferte Map-Struktur
//      (MobdexData.customMobs / vanillaMobs) ist hier in eine typisierte
//      Klasse MobdexMob überführt (gleicher Inhalt, kein Map-Zugriff
//      per String-Schlüssel mehr). kMobdexMobs enthält beide Gruppen
//      zusammen, alphabetisch sortiert (Umlaute wie Grundbuchstaben).
// ═══════════════════════════════════════════════════════════════

/// ✅ HIER ÄNDERN: Dauer des Cooldowns nach vollständigem Abschluss.
const Duration kMobdexCooldown = Duration(days: 21);

/// ✅ HIER ÄNDERN: XP-Meilenstein im Jägerjob.
const int kHunterMilestoneXp = 10000000;

/// Welten, nach denen im Mobdex-Screen gefiltert werden kann.
const List<String> kMobdexWorldFilters = [
  'Farmwelt',
  'Overworld',
  'Nether',
  'End',
];

/// Ein Mob im Mobdex.
class MobdexMob {
  final String name;

  /// Welt(en), z.B. "Farmwelt" oder "Overworld / Nether / End".
  final String world;

  /// Biome bzw. Spawn-Orte als kommaseparierter Text.
  final String biomes;

  /// true = Custom-Mob des Servers, false = Vanilla-Mob.
  final bool isCustom;

  const MobdexMob.custom(this.name, this.world, this.biomes) : isCustom = true;
  const MobdexMob.vanilla(this.name, this.world, this.biomes)
      : isCustom = false;

  /// Einzelne Welten, z.B. ["Overworld", "Nether", "End"].
  List<String> get worlds => world.split(' / ');

  /// Sortierschlüssel: klein geschrieben, Umlaute wie Grundbuchstaben,
  /// damit z.B. "Wächter" bei "W" einsortiert wird und nicht hinter "Z".
  String get sortKey => name
      .toLowerCase()
      .replaceAll('ä', 'a')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ß', 'ss');
}

// ── Custom-Mobs (exakte Biome aus dem OPSUCHT Wiki) ───────────
const List<MobdexMob> _customMobs = [
  MobdexMob.custom('Adler', 'Farmwelt',
      'Verschneite Taiga, Eisspitzen, Gefrorene Gipfel, Savannenplateau, Alte Kiefern-/Fichten-Taiga, Berge'),
  MobdexMob.custom('Alligator', 'Farmwelt',
      'Savannenplateau, Windgepeitschte Savanne, Sumpf, Mangrovensumpf'),
  MobdexMob.custom(
      'Elefant', 'Farmwelt', 'Savannenplateau, Windgepeitschte Savanne'),
  MobdexMob.custom('Eule', 'Farmwelt',
      'Taiga, Wald, Birkenwald, Dunkler Wald, Berge, Alte Kiefern-/Fichten-Taiga'),
  MobdexMob.custom('Eichhörnchen', 'Farmwelt',
      'Wald, Birkenwald, Dunkler Wald, Berge, Alte Kiefern-/Fichten-Taiga'),
  MobdexMob.custom('Hase / Kaninchen (Custom)', 'Farmwelt',
      'Verschneite Taiga, Taiga, Wald, Birkenwald, Gefrorener Fluss, Schneebedeckte Ebenen, Kirschhain'),
  MobdexMob.custom('Hirsch', 'Farmwelt',
      'Verschneite Taiga, Taiga, Wald, Alte Kiefern-/Fichten-Taiga, Gefrorener Fluss, Verschneiter Strand'),
  MobdexMob.custom('Kasuar', 'Farmwelt', 'Wüste'),
  MobdexMob.custom(
      'Löwe', 'Farmwelt', 'Savannenplateau, Windgepeitschte Savanne'),
  MobdexMob.custom('Maulwurf', 'Farmwelt',
      'Alte Kiefern-/Fichten-Taiga, Wald, Birkenwald, Dunkler Wald'),
  MobdexMob.custom('Nilpferd', 'Farmwelt',
      'Savannenplateau, Windgepeitschte Savanne, Fluss, Sumpf, Mangrovensumpf'),
  MobdexMob.custom('Pinguin', 'Farmwelt',
      'Eisspitzen, Verschneite Taiga, Gefrorene Gipfel, Verschneiter Strand'),
  MobdexMob.custom('Seepferdchen', 'Farmwelt / Ozean',
      'Tiefsee, Lauwarmes Meer, Tieflauwarmes Meer'),
  MobdexMob.custom('Wellensittich', 'Farmwelt',
      'Taiga, Wald, Birkenwald, Dunkler Wald, Berge, Dschungel, Lichter Dschungel, Bambusdschungel, Mangrovensumpf'),
  MobdexMob.custom('Tiger', 'Farmwelt',
      'Savannenplateau, Windgepeitschte Savanne, Dschungel, Bambusdschungel, Lichter Dschungel'),
  MobdexMob.custom('Wildschwein', 'Farmwelt',
      'Alte Kiefern-/Fichten-Taiga, Dunkler Wald, Taiga, Wald, Birkenwald, Mangrovensumpf, Sumpf, Blasser Garten'),
  MobdexMob.custom('Chamäleon', 'Farmwelt',
      'Dschungel, Mangrovensumpf, Sumpf, Savanne'),
  MobdexMob.custom(
      'Hammerhai', 'Farmwelt / Ozean', 'Tiefsee, Ozean, Lauwarmes Meer'),
  MobdexMob.custom('Orca', 'Farmwelt / Ozean',
      'Kalter Ozean, Gefrorener Ozean, Tiefsee'),
  MobdexMob.custom('Weißer Hai', 'Farmwelt / Ozean', 'Tiefsee, Ozean'),
];

// ── Vanilla-Mobs (Welt + Standard-Biome) ──────────────────────
const List<MobdexMob> _vanillaMobs = [
  MobdexMob.vanilla('Axolotl', 'Overworld', 'Üppige Höhlen (Lush Caves)'),
  MobdexMob.vanilla(
      'Biene', 'Overworld', 'Blumenwiese, Ebene, Sonnenblumen-Ebene'),
  MobdexMob.vanilla(
      'Böe (Breeze)', 'Overworld', 'Priesterkammer / Trial Chambers'),
  MobdexMob.vanilla('Creeper', 'Overworld', 'Überall (Nacht / Dunkelheit)'),
  MobdexMob.vanilla(
      'Delfin', 'Overworld', 'Ozeane (außer Gefrorener Ozean)'),
  MobdexMob.vanilla(
      'Diener (Vindicator)', 'Overworld', 'Waldanwesen, Überfälle (Raids)'),
  MobdexMob.vanilla('Dromedar', 'Overworld', 'Wüstendörfer'),
  MobdexMob.vanilla('Eisbär', 'Overworld',
      'Verschneite Ebenen, Eisspitzen, Gefrorener Ozean'),
  MobdexMob.vanilla('Eisengolem', 'Overworld', 'Dörfer, Außenposten'),
  MobdexMob.vanilla(
      'Einwanderer (Trader)', 'Overworld', 'Spawnt zufällig beim Spieler'),
  MobdexMob.vanilla('Enderman', 'Overworld / Nether / End',
      'Überall, Wirrwald (Warped Forest), Das End'),
  MobdexMob.vanilla('Ertrunkener', 'Overworld',
      'Ozeane, Flüsse, Unterwasser-Ruinen'),
  MobdexMob.vanilla('Esel', 'Overworld', 'Ebenen, Savanne'),
  MobdexMob.vanilla('Frosch', 'Overworld', 'Sumpf, Mangrovensumpf'),
  MobdexMob.vanilla('Fuchs', 'Overworld', 'Taiga, Verschneite Taiga'),
  MobdexMob.vanilla('Ghast', 'Nether',
      'Nether-Ödland, Seelensand-Tal, Basaltdeltas'),
  MobdexMob.vanilla('Großwächter', 'Overworld', 'Ozeanmonument'),
  MobdexMob.vanilla('Gürteltier', 'Overworld', 'Savanne, Ödland (Badlands)'),
  MobdexMob.vanilla(
      'Hexe', 'Overworld', 'Sumpfhütte, Überfälle, Nachts überall'),
  MobdexMob.vanilla('Hoglin', 'Nether', 'Karmesinwald (Crimson Forest)'),
  MobdexMob.vanilla(
      'Höhlenspinne', 'Overworld', 'Minenschächte (Mineshafts)'),
  MobdexMob.vanilla('Huhn', 'Overworld', 'Grasbiome (Ebenen, Wälder)'),
  MobdexMob.vanilla(
      'Kabeljau', 'Overworld', 'Ozeane (Normal, Lauwarm, Kalt)'),
  MobdexMob.vanilla(
      'Kaninchen', 'Overworld', 'Wüste, Verschneite Ebenen, Taiga'),
  MobdexMob.vanilla('Katze', 'Overworld', 'Dörfer, Sumpfhütte'),
  MobdexMob.vanilla('Kuh', 'Overworld', 'Grasbiome (Ebenen, Wälder)'),
  MobdexMob.vanilla(
      'Lachs', 'Overworld', 'Flüsse, Kalte / Gefrorene Ozeane'),
  MobdexMob.vanilla(
      'Lama', 'Overworld', 'Windeingefurchte Hügel, Savanne'),
  MobdexMob.vanilla(
      'Leuchttintenfisch', 'Overworld', 'Tiefe Unterwasser-Höhlen'),
  MobdexMob.vanilla(
      'Lohe (Blaze)', 'Nether', 'Netherfestung (Nether Fortress)'),
  MobdexMob.vanilla(
      'Magier (Evoker)', 'Overworld', 'Waldanwesen, Überfälle'),
  MobdexMob.vanilla(
      'Magmawürfel', 'Nether', 'Basaltdeltas, Netherfestung'),
  MobdexMob.vanilla('Maultier', 'Overworld', 'Zucht (Pferd + Esel)'),
  MobdexMob.vanilla(
      'Mooshroom', 'Overworld', 'Pilzland (Mushroom Fields)'),
  MobdexMob.vanilla('Nautilus', 'Overworld', 'Ozean / Angeln'),
  MobdexMob.vanilla('Ozelot', 'Overworld', 'Dschungel'),
  MobdexMob.vanilla('Panda', 'Overworld', 'Dschungel, Bambusdschungel'),
  MobdexMob.vanilla('Papagei', 'Overworld', 'Dschungel'),
  MobdexMob.vanilla('Pferd', 'Overworld', 'Ebenen, Savanne'),
  MobdexMob.vanilla('Piglin', 'Nether',
      'Karmesinwald, Nether-Ödland, Bastionsruinen'),
  MobdexMob.vanilla('Piglin-Barbar', 'Nether', 'Bastionsruinen'),
  MobdexMob.vanilla('Plünderer (Pillager)', 'Overworld',
      'Außenposten, Patrouillen, Überfälle'),
  MobdexMob.vanilla('Schaf', 'Overworld', 'Grasbiome'),
  MobdexMob.vanilla('Schildkröte', 'Overworld', 'Strände'),
  MobdexMob.vanilla(
      'Schleim', 'Overworld', 'Sumpf, Schleim-Chunks (Tiefgaragen)'),
  MobdexMob.vanilla(
      'Schreiter (Strider)', 'Nether', 'Lava-Ozeane im Nether'),
  MobdexMob.vanilla('Schwein', 'Overworld', 'Grasbiome'),
  MobdexMob.vanilla(
      'Silberfischchen', 'Overworld', 'Festungen (Strongholds), Berge'),
  MobdexMob.vanilla('Skelett', 'Overworld / Nether',
      'Überall (Dunkelheit), Seelensand-Tal'),
  MobdexMob.vanilla('Endermite', 'Overworld / End',
      'Spawnt beim Werfen von Enderperlen'),
  MobdexMob.vanilla('Spinne', 'Overworld', 'Überall (Dunkelheit)'),
  MobdexMob.vanilla('Sumpfskelett (Bogged)', 'Overworld',
      'Sumpf, Mangrovensumpf, Trial Chambers'),
  MobdexMob.vanilla('Tintenfisch', 'Overworld', 'Flüsse, Ozeane'),
  MobdexMob.vanilla('Tropenfisch', 'Overworld',
      'Lauwarme / Warme Ozeane, Üppige Höhlen'),
  MobdexMob.vanilla('Vertrockneter (Husk)', 'Overworld', 'Wüste'),
  MobdexMob.vanilla(
      'Verwüster (Ravager)', 'Overworld', 'Überfälle (Raids)'),
  MobdexMob.vanilla(
      'Wächter (Guardian)', 'Overworld', 'Ozeanmonument'),
  MobdexMob.vanilla('Wärter (Warden)', 'Overworld',
      'Tiefes Dunkel (Deep Dark) / Antike Stadt'),
  MobdexMob.vanilla('Wither-Skelett', 'Nether', 'Netherfestung'),
  MobdexMob.vanilla(
      'Wolf', 'Overworld', 'Wälder, Taiga, Savanne, Ödland'),
  MobdexMob.vanilla('Wüstenzombie', 'Overworld', 'Wüste'),
  MobdexMob.vanilla('Ziege', 'Overworld', 'Berge, Verschneite Gipfel'),
  MobdexMob.vanilla(
      'Zoglin', 'Overworld', 'Hoglin in die Overworld bringen'),
  MobdexMob.vanilla('Zombie', 'Overworld', 'Überall (Dunkelheit)'),
  MobdexMob.vanilla('Zombifizierter Piglin', 'Nether',
      'Nether-Ödland, Basaltdeltas, Karmesinwald'),
];

/// Alle Mobs (Custom + Vanilla), alphabetisch sortiert.
final List<MobdexMob> kMobdexMobs = _sorted([
  ..._customMobs,
  ..._vanillaMobs,
]);

List<MobdexMob> _sorted(List<MobdexMob> mobs) {
  final copy = [...mobs]..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  return List.unmodifiable(copy);
}
