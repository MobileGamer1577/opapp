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
    command: '/auktionshaus',
    description: 'Öffnet das Auktionshaus.',
    category: CommandCategory.economy,
    aliases: ['/ah'],
    subCommands: [
      SubCommand(
          command: '/ah sell [Preis]',
          description: 'Stellt das Item in der Hand ein.'),
      SubCommand(
          command: '/ah list', description: 'Zeigt deine aktiven Auktionen.'),
      SubCommand(
          command: '/ah expired',
          description: 'Zeigt abgelaufene Auktionen zum Abholen.'),
    ],
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
    aliases: ['/reward'],
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
    aliases: ['/im'],
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
    aliases: ['/op'],
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
  ),
  ServerCommand(
    command: '/shop',
    description: 'Sendet dir den Link zum Online-Shop.',
    category: CommandCategory.economy,
    aliases: ['/store'],
    subCommands: [
      SubCommand(
          command: '/shopcreate', description: 'Erstellt einen ChestShop.'),
      SubCommand(
          command: '/shopinfo',
          description: 'Infos über den Shop in deiner Nähe.',
          aliases: ['/sinfo']),
      SubCommand(
          command: '/shopupdate',
          description: 'Importiert deinen ehemaligen Rang.'),
      SubCommand(
          command: '/cstoggle',
          description: 'Deaktiviert Nachrichten deiner Shopkisten.'),
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
    description: 'Öffnet das Home-Menü.',
    category: CommandCategory.teleport,
    subCommands: [
      SubCommand(
          command: '/sethome',
          description: 'Setzt ein Home an deiner aktuellen Position.',
          aliases: ['/home set <name>']),
      SubCommand(
          command: '/delhome <name>',
          description: 'Löscht einen Home.',
          aliases: ['/home delete <name>']),
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
          command: '/swarp',
          description: 'Gibt dir Informationen über die Swarp-Befehle.'),
    ],
  ),
  ServerCommand(
    command: '/tpa',
    description: 'Sendet eine TPA an einen Spieler.',
    category: CommandCategory.teleport,
    subCommands: [
      SubCommand(
          command: '/tpahere',
          description: 'Sendet eine TPAHERE an einen Spieler.'),
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
    description: 'Öffnet das Plot-Menü.',
    category: CommandCategory.plot,
    aliases: ['/p'],
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
  //  ⭐ RANG – Rang-Features je nach Rang
  // ══════════════════════════════════════════════════════════

  ServerCommand(
    command: '/disguise',
    description: 'Öffnet das Verwandlungs-Menü.',
    category: CommandCategory.rank,
    aliases: ['/dis'],
    subCommands: [
      SubCommand(command: '/undis', description: 'Hebt deine Verwandlung auf.'),
    ],
  ),
  ServerCommand(
    command: '/farben',
    description: 'Zeigt alle Chat-Farben an.',
    category: CommandCategory.rank,
    aliases: ['/colorcodes', '/chatcolor'],
  ),
  ServerCommand(
    command: '/feed',
    description: 'Stillt deinen Hunger.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/fly',
    description: 'Lässt dich fliegen.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/gift <rang> <spieler>',
    description: 'Verschenkt den gewünschten Rang an einen Spieler.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/hat',
    description: 'Setzt dir das Item in deiner Hand auf den Kopf.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/heal',
    description: 'Füllt dein Leben auf.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/nick',
    description: 'Vergibt den gewünschten Nickname.',
    category: CommandCategory.rank,
    subCommands: [
      SubCommand(command: '/unnick', description: 'Hebt deinen Nickname auf.'),
    ],
  ),
  ServerCommand(
    command: '/prefix',
    description: 'Öffnet das Prefix-Menü.',
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
    description: 'Signiert dein Item.',
    category: CommandCategory.rank,
  ),
  ServerCommand(
    command: '/skull',
    description: 'Gibt dir den Skull deiner Wahl.',
    category: CommandCategory.rank,
    aliases: ['/head'],
  ),
  ServerCommand(
    command: '/werbung',
    description: 'Sendet deine Nachricht in Form einer Werbung.',
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
    description: 'Gibt dir den echten Namen eines Spielers (bei Nick).',
    category: CommandCategory.misc,
  ),

  // ← Weitere Sonstige-Commands hier einfügen
];
