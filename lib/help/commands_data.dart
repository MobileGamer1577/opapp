// ═══════════════════════════════════════════════════════════════
//  commands_data.dart – Alle offiziellen OPSUCHT.NET Commands
//
//  ✅ HIER ÄNDERN: Commands ergänzen oder anpassen
//  ❌ NICHT ÄNDERN: Import und Variablenname kServerCommands
//
//  NEUEN COMMAND:
//    ServerCommand(command: '/x', description: '...', category: CommandCategory.misc)
//
//  VERWANDTE COMMANDS (Unter-Commands):
//    subCommands: [ SubCommand(command: '/x sub', description: '...') ]
// ═══════════════════════════════════════════════════════════════

import 'command_model.dart';

const List<ServerCommand> kServerCommands = [
  // ══════════════════════════════════════════════════════════
  //  💰 WIRTSCHAFT – Shop, Markt, Auktionshaus, Geld
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/album',
    description:
        'Öffnet das Sammelalbum-Menü. Sammelkarten erhält man durch Booster Packs aus dem Battle Pass oder Server-Kisten.',
    category: CommandCategory.economy,
  ),
  ServerCommand(
    command: '/auktionshaus',
    description: 'Öffnet das Auktionshaus.',
    category: CommandCategory.economy,
    aliases: ['/ah', '/auction', '/auctions', '/auktion'],
  ),
  ServerCommand(
    command: '/bank',
    description: 'Zeigt deinen aktuellen Kontostand.',
    category: CommandCategory.economy,
    aliases: ['/money'],
  ),
  ServerCommand(
    command: '/belohnung',
    description: 'Öffnet das Belohnungs-Menü.',
    category: CommandCategory.economy,
    aliases: ['/reward', '/rewards'],
  ),
  ServerCommand(
    command: '/booster',
    description: 'Öffnet das Booster-Menü.',
    category: CommandCategory.economy,
  ),
  ServerCommand(
    command: '/immo',
    description: 'Öffnet den Immobilienmarkt.',
    category: CommandCategory.economy,
    aliases: ['/im', '/imarkt', '/immomarkt'],
  ),
  ServerCommand(
    command: '/jobs',
    description: 'Öffnet das Job-Menü.',
    category: CommandCategory.economy,
    aliases: ['/job'],
  ),
  ServerCommand(
    command: '/kit',
    description: 'Gibt dir das gewählte Kit.',
    category: CommandCategory.economy,
    aliases: ['/kits'],
  ),
  ServerCommand(
    command: '/kompressor',
    description: 'Öffnet das Kompressor-Menü.',
    category: CommandCategory.economy,
  ),
  ServerCommand(
    command: '/minion',
    description: 'Öffnet das Minion-Menü.',
    category: CommandCategory.economy,
  ),
  ServerCommand(
    command: '/oppass',
    description: 'Öffnet den OP Pass.',
    category: CommandCategory.economy,
    aliases: ['/op', '/battlepass', '/pass'],
  ),
  ServerCommand(
    command: '/pay',
    description: 'Überweist einem Spieler die angegebene Summe.',
    category: CommandCategory.economy,
  ),
  ServerCommand(
    command: '/perks',
    description: 'Öffnet das Perks-Menü.',
    category: CommandCategory.economy,
    aliases: ['/perk'],
  ),
  ServerCommand(
    command: '/rang',
    description: 'Öffnet den Rang-Shop.',
    category: CommandCategory.economy,
    aliases: ['/rank', '/ranks', '/rankshop'],
  ),
  ServerCommand(
    command: '/shopcreate',
    description: 'Erstellt eine ChestShop-Kiste.',
    category: CommandCategory.economy,
    subCommands: [
      SubCommand(
          command: '/shopinfo',
          description: 'Infos über den Shop in deiner Nähe.',
          aliases: ['/sinfo']),
      SubCommand(
          command: '/cstoggle',
          description: 'Deaktiviert Nachrichten deiner Shopkisten.'),
      SubCommand(
          command: '/shoptransactions',
          description: 'Zeigt die Transaktionen deiner Shopkiste an.'),
    ],
  ),

  // ← Weitere Wirtschafts-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  ✈️ TELEPORT – Spawn, Home, TPA, Warp, Server
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/citybuild',
    description: 'Verbindet dich zum CityBuild-Server.',
    category: CommandCategory.teleport,
    aliases: ['/cb'],
  ),
  ServerCommand(
    command: '/farm',
    description: 'Öffnet den Navigator zu den Farmwelten.',
    category: CommandCategory.teleport,
    aliases: ['/farmserver'],
  ),
  ServerCommand(
    command: '/home',
    description: 'Öffnet das Home-Interface.',
    category: CommandCategory.teleport,
    subCommands: [
      SubCommand(
          command: '/home <name>',
          description: 'Teleportiert dich zu deinem Home.'),
      SubCommand(
          command: '/home create <name>',
          description: 'Erstellt ein Home mit dem angegebenen Namen.'),
      SubCommand(
          command: '/home delete <name>',
          description: 'Löscht ein Home mit dem angegebenen Namen.'),
      SubCommand(
          command: '/home update <name>',
          description: 'Aktualisiert ein Home mit dem angegebenen Namen.'),
      SubCommand(
          command: '/home rename <alter Name> <neuer Name>',
          description: 'Ändert den Namen eines Homes.'),
      SubCommand(
          command: '/home list',
          description: 'Listet alle von dir erstellten Homes auf.'),
      SubCommand(
          command: '/home help', description: 'Zeigt alle Home-Befehle an.'),
    ],
  ),
  ServerCommand(
    command: '/lobby',
    description: 'Bringt dich in die Lobby.',
    category: CommandCategory.teleport,
    aliases: ['/l', '/hub'],
  ),
  ServerCommand(
    command: '/navigator',
    description: 'Öffnet den Navigator.',
    category: CommandCategory.teleport,
    aliases: ['/nav', '/server'],
  ),
  ServerCommand(
    command: '/pvp',
    description: 'Verbindet dich mit dem PVP-Server.',
    category: CommandCategory.teleport,
  ),
  ServerCommand(
    command: '/randomteleport',
    description: 'Teleportiert dich an einen zufälligen Ort in der Farmwelt.',
    category: CommandCategory.teleport,
    aliases: ['/rtp'],
  ),
  ServerCommand(
    command: '/redstone',
    description: 'Verbindet dich mit dem Redstone-Server.',
    category: CommandCategory.teleport,
  ),
  ServerCommand(
    command: '/spawn',
    description: 'Bringt dich an den Spawn.',
    category: CommandCategory.teleport,
  ),
  ServerCommand(
    command: '/sw',
    description: 'Öffnet das Swarp-Menü.',
    category: CommandCategory.teleport,
    subCommands: [
      SubCommand(
          command: '/swarp create <name>',
          description: 'Erstellt einen neuen Swarp.'),
      SubCommand(
          command: '/swarp delete <name>', description: 'Löscht einen Swarp.'),
      SubCommand(
          command: '/swarp update <name>',
          description: 'Aktualisiert einen Swarp.'),
      SubCommand(
          command: '/swarp list', description: 'Listet alle Swarps auf.'),
      SubCommand(
          command: '/swarp info <name>',
          description: 'Zeigt Infos über einen Swarp.'),
      SubCommand(
          command: '/swarp top', description: 'Zeigt die beliebtesten Swarps.'),
    ],
  ),
  ServerCommand(
    command: '/tpa',
    description: 'Sendet eine TPA an einen Spieler.',
    category: CommandCategory.teleport,
    subCommands: [
      SubCommand(
          command: '/tpahere',
          description: 'Sendet eine TPAHERE an einen Spieler. (Rang-Feature)'),
      SubCommand(
          command: '/tpaccept',
          description: 'Akzeptiert eine TPA.',
          aliases: ['/tpy', '/tpyes', '/tpaaccept']),
      SubCommand(
          command: '/tpadeny',
          description: 'Lehnt eine TPA ab.',
          aliases: ['/tpn', '/tpno', '/tpadecline']),
      SubCommand(
          command: '/tpatoggle',
          description: 'Schränkt ein, wer dir eine TPA senden darf.',
          aliases: ['/tptoggle']),
    ],
  ),

  // ← Weitere Teleport-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  🏠 GRUNDSTÜCKE – Plot, Karte, Umzug
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/plot',
    description: 'Öffnet das Plot-Menü und zeigt alle Plot-Befehle.',
    category: CommandCategory.plot,
    aliases: ['/p'],
    subCommands: [
      SubCommand(
          command: '/plot claim',
          description: 'Beansprucht das aktuelle Plot.',
          aliases: ['/plot c']),
      SubCommand(
          command: '/plot auto',
          description: 'Beansprucht das nächstgelegene freie Plot.',
          aliases: ['/plot a']),
      SubCommand(
          command: '/plot middle',
          description: 'Teleportiert dich in die Mitte des Plots.',
          aliases: ['/plot center', '/plot centre']),
      SubCommand(
          command: '/plot visit <Spieler>',
          description: 'Besucht das Plot eines anderen Spielers.',
          aliases: ['/plot v', '/plot tp', '/plot goto', '/plot warp']),
      SubCommand(
          command: '/plot trust <Spieler>',
          description: 'Erlaubt Bauen & WorldEdit auch wenn du offline bist.',
          aliases: ['/plot t']),
      SubCommand(
          command: '/plot deny <Spieler>',
          description: 'Verbietet den Zugang eines Spielers zu deinem Plot.',
          aliases: ['/plot d', '/plot ban']),
      SubCommand(
          command: '/plot remove <Spieler>',
          description: 'Entfernt einen Spieler vom Plot.',
          aliases: ['/plot r', '/plot untrust', '/plot undeny', '/plot unban']),
      SubCommand(
          command: '/plot kick <Spieler>',
          description: 'Wirft einen Spieler von deinem Plot.',
          aliases: ['/plot k']),
      SubCommand(
          command: '/plot info',
          description: 'Zeigt Informationen über das aktuelle Plot an.',
          aliases: ['/plot i']),
      SubCommand(
          command: '/plot list <mine|shared|...>',
          description:
              'Listet Plots auf (mine, shared, world, top, all, forsale, unowned).',
          aliases: ['/plot l', '/plot find', '/plot search']),
      SubCommand(
          command: '/plot clear',
          description:
              'Leert das Plot auf dem du stehst (alles wird gelöscht!).',
          aliases: ['/plot reset']),
      SubCommand(
          command: '/plot delete',
          description: 'Löscht das Plot auf dem du stehst.',
          aliases: ['/plot dispose', '/plot del']),
      SubCommand(
          command: '/plot merge <Richtung>',
          description: 'Verbindet dein Plot mit einem benachbarten Plot.',
          aliases: ['/plot m']),
      SubCommand(
          command: '/plot unlink',
          description: 'Trennt ein zusammengeführtes Mega-Plot.',
          aliases: ['/plot u', '/plot unmerge']),
      SubCommand(
          command: '/plot caps',
          description: 'Zeigt Plot-Einheitsbegrenzungen an.'),
      SubCommand(
          command: '/plot confirm',
          description: 'Bestätigt eine Plot-Aktion (z.B. nach /plot delete).'),
    ],
  ),
  ServerCommand(
    command: '/kopieren',
    description: 'Kopiert deine Karte.',
    category: CommandCategory.plot,
    aliases: ['/kartekopieren', '/mapcopy'],
  ),
  ServerCommand(
    command: '/umzug',
    description: 'Öffnet das Umzug-Menü.',
    category: CommandCategory.plot,
  ),

  // ← Weitere Grundstücke-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  ⚒️ CRAFTING – Amboss, Werkbank, Enderchest, Tresor
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/anvil',
    description: 'Öffnet den Amboss.',
    category: CommandCategory.crafting,
  ),
  ServerCommand(
    command: '/enderchest',
    description: 'Öffnet die Enderchest.',
    category: CommandCategory.crafting,
    aliases: ['/ec'],
  ),
  ServerCommand(
    command: '/trash',
    description: 'Öffnet den Mülleimer.',
    category: CommandCategory.crafting,
    aliases: ['/disposal'],
  ),
  ServerCommand(
    command: '/tresor',
    description: 'Öffnet den Tresor.',
    category: CommandCategory.crafting,
    aliases: ['/safe'],
  ),
  ServerCommand(
    command: '/werkbank',
    description: 'Öffnet die Werkbank.',
    category: CommandCategory.crafting,
    aliases: ['/wb'],
  ),

  // ← Weitere Crafting-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  ⭐ RANG – Features je nach Rang (nur für bestimmte Ränge)
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/disguise',
    description:
        'Öffnet das Verwandlungs-Menü. Ab Ultra-Rang. Höhere Ränge haben mehr Verwandlungsoptionen.',
    category: CommandCategory.rank,
    aliases: ['/dis'],
    subCommands: [
      SubCommand(
          command: '/undis',
          description: 'Hebt deine aktuelle Verwandlung auf.',
          aliases: ['/ud']),
    ],
  ),
  ServerCommand(
    command: '/farben',
    description:
        'Zeigt alle Chat-Farben an. Verfügbar für alle Ränge. Farbiges Schreiben im Chat ab Premium-Rang.',
    category: CommandCategory.rank,
    aliases: ['/colorcode', '/colorcodes', '/chatcolor'],
  ),
  ServerCommand(
    command: '/feed',
    description:
        'Stillt deinen Hunger. Ab Platin-Rang, alle 10 Minuten nutzbar.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/fly',
    description:
        'Lässt dich fliegen. Ab Supreme-Rang, nur in der Plotwelt verfügbar.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/gift <rang> <spieler>',
    description:
        'Verschenkt einen Rang für 7 Tage. Platin kann Premium verschenken, OP kann Diamond verschenken.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/hat',
    description:
        'Setzt dir das Item in deiner Hand auf den Kopf. Ab Diamond-Rang.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/heal',
    description:
        'Füllt dein Leben auf. Ab Platin-Rang, alle 15 Minuten nutzbar.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/nick',
    description:
        'Vergibt den gewünschten Nickname. Ab Diamond-Rang. Ab Legende-Rang sind farbige Nicknames möglich.',
    category: CommandCategory.rank,
    subCommands: [
      SubCommand(
          command: '/unnick',
          description: 'Hebt deinen aktuellen Nickname auf.'),
    ],
  ),
  ServerCommand(
    command: '/prefix',
    description: 'Öffnet das Prefix-Menü. Ab OP-Rang.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/rainbow',
    description: 'Schreibt deine Nachricht in Regenbogenfarben.',
    category: CommandCategory.rank,
    aliases: ['/rb'],
  ),
  ServerCommand(
    command: '/rename',
    description: 'Benennt das gewünschte Item um.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/sign',
    description: 'Signiert dein Item. Ab Supreme-Rang.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/skull',
    description:
        'Gibt dir den Skull deiner Wahl. Ab Ultra-Rang, alle 30 Tage. Höhere Ränge können /skull häufiger nutzen.',
    category: CommandCategory.rank,
    aliases: ['/head'],
  ),
  ServerCommand(
    command: '/werbung',
    description:
        'Sendet deine Nachricht in Form einer Server-Werbung. Ab Ultra-Rang.',
    category: CommandCategory.rank,
  ),

  // ← Weitere Rang-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  👥 COMMUNITY – Clan, Freunde, Nachrichten, Social
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/clan',
    description: 'Zeigt alle Clan-Befehle.',
    category: CommandCategory.social,
    aliases: ['/c'],
  ),
  ServerCommand(
    command: '/discord',
    description: 'Sendet dir den Discord-Link.',
    category: CommandCategory.social,
    aliases: ['/dc'],
    subCommands: [
      SubCommand(
          command: '/dlink',
          description: 'Verifiziert deinen Minecraft-Account mit Discord.',
          aliases: ['/link']),
      SubCommand(
          command: '/dunlink',
          description: 'Hebt die Discord-Verifizierung auf.',
          aliases: ['/unlink']),
    ],
  ),
  ServerCommand(
    command: '/emoji',
    description: 'Öffnet das Emoji-Menü.',
    category: CommandCategory.social,
    aliases: ['/smiley'],
  ),
  ServerCommand(
    command: '/freund',
    description: 'Öffnet das Freunde-Menü.',
    category: CommandCategory.social,
    aliases: ['/freunde'],
  ),
  ServerCommand(
    command: '/geburtstag',
    description: 'Öffnet das Geburtstags-Menü.',
    category: CommandCategory.social,
  ),
  ServerCommand(
    command: '/haustiere',
    description: 'Öffnet das Haustier-Menü.',
    category: CommandCategory.social,
    aliases: ['/pet'],
  ),
  ServerCommand(
    command: '/ignore',
    description: 'Ignoriert einen Spieler.',
    category: CommandCategory.social,
  ),
  ServerCommand(
    command: '/msg',
    description: 'Sendet eine Nachricht an den Spieler deiner Wahl.',
    category: CommandCategory.social,
    subCommands: [
      SubCommand(
          command: '/reply',
          description: 'Antwortet deinem letzten Chat-Partner.',
          aliases: ['/r']),
      SubCommand(
          command: '/msgtoggle',
          description: 'Schränkt ein, wer dir schreiben kann.'),
    ],
  ),
  ServerCommand(
    command: '/teamspeak',
    description: 'Sendet dir die TeamSpeak-IP.',
    category: CommandCategory.social,
    aliases: ['/ts3', '/ts'],
    subCommands: [
      SubCommand(
          command: '/verify', description: 'Verifiziert dich auf TeamSpeak.'),
      SubCommand(
          command: '/unverify',
          description: 'Hebt deine TeamSpeak-Verifizierung auf.'),
    ],
  ),

  // ← Weitere Community-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  🖥️ SERVER – Vote, Wiki, Social Media, Infos
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/code',
    description: 'Öffnet das Affiliate-System.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/erfolge',
    description: 'Öffnet das Erfolge-Menü.',
    category: CommandCategory.server,
    aliases: ['/achievements'],
  ),
  ServerCommand(
    command: '/instagram',
    description: 'Sendet dir den Instagram-Link.',
    category: CommandCategory.server,
    aliases: ['/insta'],
  ),
  ServerCommand(
    command: '/online',
    description: 'Zeigt deine Spielzeit.',
    category: CommandCategory.server,
    aliases: ['/onlinetime', '/spielzeit'],
  ),
  ServerCommand(
    command: '/regeln',
    description: 'Sendet dir den Link zu den Regeln.',
    category: CommandCategory.server,
    aliases: ['/regel'],
  ),
  ServerCommand(
    command: '/shop',
    description: 'Sendet dir den Link zum Online-Shop.',
    category: CommandCategory.server,
    aliases: ['/store'],
  ),
  ServerCommand(
    command: '/shopupdate',
    description: 'Importiert deinen ehemaligen Rang in das aktuelle System.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/skiptutorial',
    description: 'Überspringt das Tutorial.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/tutorial',
    description: 'Sendet dir den Link zum Tutorial.',
    category: CommandCategory.server,
    aliases: ['/hilfe'],
  ),
  ServerCommand(
    command: '/twitch',
    description: 'Sendet dir den Link zu unserem Twitch.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/twitter',
    description: 'Sendet dir den Link zu unserem Twitter.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/vote',
    description: 'Sendet dir den Link zu unserer Vote-Seite.',
    category: CommandCategory.server,
  ),
  ServerCommand(
    command: '/wiki',
    description: 'Sendet dir den Link zum Wiki.',
    category: CommandCategory.server,
  ),

  // ← Weitere Server-Commands hier einfügen

  // ══════════════════════════════════════════════════════════
  //  ⚙️ SONSTIGES – 2FA, Inventar, Item-Infos
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/2fa',
    description: 'Aktiviert die Zwei-Faktor-Authentifizierung.',
    category: CommandCategory.misc,
  ),
  ServerCommand(
    command: '/armor',
    description: 'Zeigt dir die Rüstung eines Spielers.',
    category: CommandCategory.misc,
    aliases: ['/invsee <player> armor'],
  ),
  ServerCommand(
    command: '/inventorysee',
    description: 'Lässt dich in das Inventar eines Spielers schauen.',
    category: CommandCategory.misc,
    aliases: ['/invsee'],
  ),
  ServerCommand(
    command: '/iteminfo',
    description: 'Gibt dir Informationen über das gewünschte Item.',
    category: CommandCategory.misc,
    aliases: ['/iinfo'],
  ),
  ServerCommand(
    command: '/realname',
    description: 'Gibt dir den echten Namen eines Spielers (bei aktivem Nick).',
    category: CommandCategory.misc,
  ),

  // ← Weitere Sonstige-Commands hier einfügen
];
