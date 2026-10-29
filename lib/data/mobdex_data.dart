// ═══════════════════════════════════════════════════════════════
//  mobdex_data.dart – Mob-Liste für den Mobdex (Jägerjob)
//
//  ✅ HIER ÄNDERN: Mobs/Biome ergänzen oder korrigieren, Cooldown-
//                  Dauer (kMobdexCooldown)
//  ❌ NICHT ÄNDERN: Klasse MobdexMob / Variablenname kMobdexMobs.
//                   Der Mob-NAME ist zugleich der Speicher-Schlüssel
//                   für den Fortschritt (SharedPreferences) – einen
//                   bestehenden Namen umzubenennen "vergisst" den Haken
//                   bei diesem Mob. Namen müssen eindeutig sein!
//
//  NEUEN MOB ERGÄNZEN:
//    Custom-Mob:  MobdexMob.custom('Name', 'Farmwelt', 'Biom1, Biom2'),
//    Vanilla-Mob: MobdexMob.vanilla('Name', 'Farmwelt', 'Biom1, Biom2'),
//  Mehrere Welten werden mit " / " getrennt ("Farmwelt / Nether") –
//  der Welt-Filter im Mobdex-Screen arbeitet auf diesen Teilen.
//  "Overworld" gibt es bewusst NICHT mehr: Auf dem Server ist die
//  Overworld dasselbe wie die Farmwelt → einheitlich "Farmwelt".
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
//    - Welten bereinigt: "Overworld" und "Farmwelt" sind auf dem Server
//      dasselbe und wurden zu "Farmwelt" zusammengeführt.
//    - XP-Meilenstein entfernt (gehört nicht in ein reines Mobdex).
// ═══════════════════════════════════════════════════════════════

/// ✅ HIER ÄNDERN: Dauer des Cooldowns nach vollständigem Abschluss.
const Duration kMobdexCooldown = Duration(days: 21);

/// Welten, nach denen im Mobdex-Screen gefiltert werden kann.
const List<String> kMobdexWorldFilters = [
  'Farmwelt',
  'Nether',
  'End',
];

/// Ein Mob im Mobdex.
class MobdexMob {
  final String name;

  /// Welt(en), z.B. "Farmwelt" oder "Farmwelt / Nether / End".
  final String world;

  /// Biome bzw. Spawn-Orte als kommaseparierter Text.
  final String biomes;

  /// true = Custom-Mob des Servers, false = Vanilla-Mob.
  final bool isCustom;

  const MobdexMob.custom(this.name, this.world, this.biomes) : isCustom = true;
  const MobdexMob.vanilla(this.name, this.world, this.biomes)
      : isCustom = false;

  /// Einzelne Welten, z.B. ["Farmwelt", "Nether", "End"].
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
  MobdexMob.vanilla('Axolotl', 'Farmwelt', 'Üppige Höhlen (Lush Caves)'),
  MobdexMob.vanilla(
      'Biene', 'Farmwelt', 'Blumenwiese, Ebene, Sonnenblumen-Ebene'),
  MobdexMob.vanilla(
      'Böe (Breeze)', 'Farmwelt', 'Priesterkammer / Trial Chambers'),
  MobdexMob.vanilla('Creeper', 'Farmwelt', 'Überall (Nacht / Dunkelheit)'),
  MobdexMob.vanilla(
      'Delfin', 'Farmwelt', 'Ozeane (außer Gefrorener Ozean)'),
  MobdexMob.vanilla(
      'Diener (Vindicator)', 'Farmwelt', 'Waldanwesen, Überfälle (Raids)'),
  MobdexMob.vanilla('Dromedar', 'Farmwelt', 'Wüstendörfer'),
  MobdexMob.vanilla('Eisbär', 'Farmwelt',
      'Verschneite Ebenen, Eisspitzen, Gefrorener Ozean'),
  MobdexMob.vanilla('Eisengolem', 'Farmwelt', 'Dörfer, Außenposten'),
  MobdexMob.vanilla(
      'Einwanderer (Trader)', 'Farmwelt', 'Spawnt zufällig beim Spieler'),
  MobdexMob.vanilla('Enderman', 'Farmwelt / Nether / End',
      'Überall, Wirrwald (Warped Forest), Das End'),
  MobdexMob.vanilla('Ertrunkener', 'Farmwelt',
      'Ozeane, Flüsse, Unterwasser-Ruinen'),
  MobdexMob.vanilla('Esel', 'Farmwelt', 'Ebenen, Savanne'),
  MobdexMob.vanilla('Frosch', 'Farmwelt', 'Sumpf, Mangrovensumpf'),
  MobdexMob.vanilla('Fuchs', 'Farmwelt', 'Taiga, Verschneite Taiga'),
  MobdexMob.vanilla('Ghast', 'Nether',
      'Nether-Ödland, Seelensand-Tal, Basaltdeltas'),
  MobdexMob.vanilla('Großwächter', 'Farmwelt', 'Ozeanmonument'),
  MobdexMob.vanilla('Gürteltier', 'Farmwelt', 'Savanne, Ödland (Badlands)'),
  MobdexMob.vanilla(
      'Hexe', 'Farmwelt', 'Sumpfhütte, Überfälle, Nachts überall'),
  MobdexMob.vanilla('Hoglin', 'Nether', 'Karmesinwald (Crimson Forest)'),
  MobdexMob.vanilla(
      'Höhlenspinne', 'Farmwelt', 'Minenschächte (Mineshafts)'),
  MobdexMob.vanilla('Huhn', 'Farmwelt', 'Grasbiome (Ebenen, Wälder)'),
  MobdexMob.vanilla(
      'Kabeljau', 'Farmwelt', 'Ozeane (Normal, Lauwarm, Kalt)'),
  MobdexMob.vanilla(
      'Kaninchen', 'Farmwelt', 'Wüste, Verschneite Ebenen, Taiga'),
  MobdexMob.vanilla('Katze', 'Farmwelt', 'Dörfer, Sumpfhütte'),
  MobdexMob.vanilla('Kuh', 'Farmwelt', 'Grasbiome (Ebenen, Wälder)'),
  MobdexMob.vanilla(
      'Lachs', 'Farmwelt', 'Flüsse, Kalte / Gefrorene Ozeane'),
  MobdexMob.vanilla(
      'Lama', 'Farmwelt', 'Windeingefurchte Hügel, Savanne'),
  MobdexMob.vanilla(
      'Leuchttintenfisch', 'Farmwelt', 'Tiefe Unterwasser-Höhlen'),
  MobdexMob.vanilla(
      'Lohe (Blaze)', 'Nether', 'Netherfestung (Nether Fortress)'),
  MobdexMob.vanilla(
      'Magier (Evoker)', 'Farmwelt', 'Waldanwesen, Überfälle'),
  MobdexMob.vanilla(
      'Magmawürfel', 'Nether', 'Basaltdeltas, Netherfestung'),
  MobdexMob.vanilla('Maultier', 'Farmwelt', 'Zucht (Pferd + Esel)'),
  MobdexMob.vanilla(
      'Mooshroom', 'Farmwelt', 'Pilzland (Mushroom Fields)'),
  MobdexMob.vanilla('Nautilus', 'Farmwelt', 'Ozean / Angeln'),
  MobdexMob.vanilla('Ozelot', 'Farmwelt', 'Dschungel'),
  MobdexMob.vanilla('Panda', 'Farmwelt', 'Dschungel, Bambusdschungel'),
  MobdexMob.vanilla('Papagei', 'Farmwelt', 'Dschungel'),
  MobdexMob.vanilla('Pferd', 'Farmwelt', 'Ebenen, Savanne'),
  MobdexMob.vanilla('Piglin', 'Nether',
      'Karmesinwald, Nether-Ödland, Bastionsruinen'),
  MobdexMob.vanilla('Piglin-Barbar', 'Nether', 'Bastionsruinen'),
  MobdexMob.vanilla('Plünderer (Pillager)', 'Farmwelt',
      'Außenposten, Patrouillen, Überfälle'),
  MobdexMob.vanilla('Schaf', 'Farmwelt', 'Grasbiome'),
  MobdexMob.vanilla('Schildkröte', 'Farmwelt', 'Strände'),
  MobdexMob.vanilla(
      'Schleim', 'Farmwelt', 'Sumpf, Schleim-Chunks (Tiefgaragen)'),
  MobdexMob.vanilla(
      'Schreiter (Strider)', 'Nether', 'Lava-Ozeane im Nether'),
  MobdexMob.vanilla('Schwein', 'Farmwelt', 'Grasbiome'),
  MobdexMob.vanilla(
      'Silberfischchen', 'Farmwelt', 'Festungen (Strongholds), Berge'),
  MobdexMob.vanilla('Skelett', 'Farmwelt / Nether',
      'Überall (Dunkelheit), Seelensand-Tal'),
  MobdexMob.vanilla('Endermite', 'Farmwelt / End',
      'Spawnt beim Werfen von Enderperlen'),
  MobdexMob.vanilla('Spinne', 'Farmwelt', 'Überall (Dunkelheit)'),
  MobdexMob.vanilla('Sumpfskelett (Bogged)', 'Farmwelt',
      'Sumpf, Mangrovensumpf, Trial Chambers'),
  MobdexMob.vanilla('Tintenfisch', 'Farmwelt', 'Flüsse, Ozeane'),
  MobdexMob.vanilla('Tropenfisch', 'Farmwelt',
      'Lauwarme / Warme Ozeane, Üppige Höhlen'),
  MobdexMob.vanilla('Vertrockneter (Husk)', 'Farmwelt', 'Wüste'),
  MobdexMob.vanilla(
      'Verwüster (Ravager)', 'Farmwelt', 'Überfälle (Raids)'),
  MobdexMob.vanilla(
      'Wächter (Guardian)', 'Farmwelt', 'Ozeanmonument'),
  MobdexMob.vanilla('Wärter (Warden)', 'Farmwelt',
      'Tiefes Dunkel (Deep Dark) / Antike Stadt'),
  MobdexMob.vanilla('Wither-Skelett', 'Nether', 'Netherfestung'),
  MobdexMob.vanilla(
      'Wolf', 'Farmwelt', 'Wälder, Taiga, Savanne, Ödland'),
  MobdexMob.vanilla('Wüstenzombie', 'Farmwelt', 'Wüste'),
  MobdexMob.vanilla('Ziege', 'Farmwelt', 'Berge, Verschneite Gipfel'),
  MobdexMob.vanilla(
      'Zoglin', 'Farmwelt', 'Hoglin in die Farmwelt bringen'),
  MobdexMob.vanilla('Zombie', 'Farmwelt', 'Überall (Dunkelheit)'),
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
