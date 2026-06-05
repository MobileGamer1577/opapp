import 'command_model.dart';

/// Alle Server-Commands für OPSUCHT.NET
/// Hier werden die Commands gepflegt – keine API nötig
const List<ServerCommand> kServerCommands = [

  // ══════════════════════════════════════
  //  WIRTSCHAFT & SHOP
  // ══════════════════════════════════════
  ServerCommand(
    command:     '/shop',
    description: 'Öffnet den Server-Shop.',
    category:    CommandCategory.economy,
    aliases:     ['/s'],
  ),
  ServerCommand(
    command:     '/sell',
    description: 'Verkauft Items aus der Hand oder dem Inventar.',
    category:    CommandCategory.economy,
    aliases:     ['/sellall'],
  ),
  ServerCommand(
    command:     '/balance',
    description: 'Zeigt das eigene Guthaben an.',
    category:    CommandCategory.economy,
    aliases:     ['/bal', '/money'],
  ),
  ServerCommand(
    command:     '/pay',
    description: 'Überweist Geld an einen anderen Spieler.',
    category:    CommandCategory.economy,
  ),
  ServerCommand(
    command:     '/baltop',
    description: 'Rangliste der reichsten Spieler.',
    category:    CommandCategory.economy,
  ),

  // ══════════════════════════════════════
  //  AUKTIONSHAUS
  // ══════════════════════════════════════
  ServerCommand(
    command:     '/ah',
    description: 'Öffnet das Auktionshaus.',
    category:    CommandCategory.auction,
    aliases:     ['/auktionshaus'],
  ),
  ServerCommand(
    command:     '/ah sell',
    description: 'Stellt das Item in der Hand ins Auktionshaus ein.',
    category:    CommandCategory.auction,
  ),
  ServerCommand(
    command:     '/ah list',
    description: 'Zeigt eigene aktive Auktionen an.',
    category:    CommandCategory.auction,
  ),

  // ══════════════════════════════════════
  //  SPIELER & TELEPORT
  // ══════════════════════════════════════
  ServerCommand(
    command:     '/spawn',
    description: 'Teleportiert zurück zum Spawn.',
    category:    CommandCategory.teleport,
  ),
  ServerCommand(
    command:     '/home',
    description: 'Teleportiert zum gesetzten Zuhause.',
    category:    CommandCategory.teleport,
    aliases:     ['/h'],
  ),
  ServerCommand(
    command:     '/sethome',
    description: 'Setzt das aktuelle Zuhause.',
    category:    CommandCategory.teleport,
  ),
  ServerCommand(
    command:     '/tpa',
    description: 'Sendet eine Teleport-Anfrage an einen Spieler.',
    category:    CommandCategory.teleport,
  ),
  ServerCommand(
    command:     '/tpaccept',
    description: 'Akzeptiert eine eingehende Teleport-Anfrage.',
    category:    CommandCategory.teleport,
    aliases:     ['/tpyes'],
  ),
  ServerCommand(
    command:     '/warp',
    description: 'Öffnet das Warp-Menü oder teleportiert zu einem Warp-Punkt.',
    category:    CommandCategory.teleport,
    aliases:     ['/warps'],
  ),

  // ══════════════════════════════════════
  //  GRUNDSTÜCKE / PLOTS
  // ══════════════════════════════════════
  ServerCommand(
    command:     '/plot claim',
    description: 'Beansprucht das aktuelle Plot.',
    category:    CommandCategory.plot,
    aliases:     ['/p claim'],
  ),
  ServerCommand(
    command:     '/plot info',
    description: 'Zeigt Informationen zum aktuellen Plot an.',
    category:    CommandCategory.plot,
    aliases:     ['/p info'],
  ),
  ServerCommand(
    command:     '/plot trust',
    description: 'Gibt einem Spieler vollen Zugriff auf dein Plot.',
    category:    CommandCategory.plot,
  ),
  ServerCommand(
    command:     '/plot add',
    description: 'Fügt einen Spieler als Besucher hinzu.',
    category:    CommandCategory.plot,
  ),
  ServerCommand(
    command:     '/plot home',
    description: 'Teleportiert zum eigenen Plot.',
    category:    CommandCategory.plot,
    aliases:     ['/p home'],
  ),

  // ══════════════════════════════════════
  //  SONSTIGES
  // ══════════════════════════════════════
  ServerCommand(
    command:     '/msg',
    description: 'Sendet eine private Nachricht an einen Spieler.',
    category:    CommandCategory.misc,
    aliases:     ['/tell', '/pm'],
  ),
  ServerCommand(
    command:     '/r',
    description: 'Antwortet auf die letzte private Nachricht.',
    category:    CommandCategory.misc,
    aliases:     ['/reply'],
  ),
  ServerCommand(
    command:     '/rules',
    description: 'Zeigt die Server-Regeln an.',
    category:    CommandCategory.misc,
  ),
  ServerCommand(
    command:     '/discord',
    description: 'Zeigt den Discord-Einladungslink an.',
    category:    CommandCategory.misc,
  ),
];
