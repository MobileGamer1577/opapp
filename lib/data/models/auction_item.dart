// ═══════════════════════════════════════════════════════════════
//  auction_item.dart – Datenmodell für Auktionen
//
//  ✅ HIER ÄNDERN: Neue Felder aus der API ergänzen
//  ❌ NICHT ÄNDERN: _parseTimestamp (deckt alle bekannten Formate ab)
//
//  ÄNDERUNGEN (Auktionshaus-Update):
//    - 🐛 id kam vorher immer leer raus – API liefert "uid", nicht
//      "id"/"uuid". Jetzt korrekt geprüft.
//    - 🐛 buyNowPrice wurde nie befüllt – API liefert "instantBuyPrice",
//      das wurde vorher gar nicht abgefragt.
//    - NEU: startBid (Startpreis, getrennt vom currentBid)
//    - NEU: startTime (Beginn der Auktion, nullable wie endsAt)
//    - sellerName → sellerId  (enthält die UUID, Name kommt via API)
//    - endsAt ist nullable (DateTime?)
//    - isExpired ist nur true wenn Endzeit BEKANNT und vergangen ist
//    - _parseTimestamp erkennt ISO-String, Unix-Sek, Unix-Ms, Zahl-als-String
// ═══════════════════════════════════════════════════════════════

/// Repräsentiert eine laufende Auktion im OPSUCHT Auktionshaus
class AuctionItem {
  final String id;
  final String itemName;
  final String category;
  final double startBid;
  final double currentBid;
  final double? buyNowPrice;
  final int amount;

  /// Beginn der Auktion. null = konnte aus der API nicht ausgelesen werden.
  final DateTime? startTime;

  /// Endzeitpunkt der Auktion. null = konnte aus der API nicht
  /// ausgelesen werden → wird NICHT als abgelaufen behandelt.
  final DateTime? endsAt;

  /// Rohe Spieler-ID des Verkäufers (UUID, kein Klarname!).
  /// Anzeigename kommt über playerNameProvider(sellerId).
  final String sellerId;
  final List<String> enchants;
  final List<String> lore;

  const AuctionItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.startBid,
    required this.currentBid,
    this.buyNowPrice,
    required this.amount,
    required this.startTime,
    required this.endsAt,
    required this.sellerId,
    required this.enchants,
    required this.lore,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    // ── Das Item ist ein verschachteltes Objekt ───────────
    // API-Format: { "item": { "displayName": "...", "lore": [...], ... } }
    final itemData = json['item'] as Map<String, dynamic>? ?? {};

    // Name aus item.displayName oder Fallbacks
    final itemName = itemData['displayName']?.toString()
                  ?? itemData['name']?.toString()
                  ?? json['itemName']?.toString()
                  ?? json['name']?.toString()
                  ?? _formatMaterial(itemData['material']?.toString() ?? '')
                  ?? 'Unbekanntes Item';

    // Menge aus verschachteltem item oder direkt
    final amount = (itemData['amount'] as num?)?.toInt()
                ?? (json['amount']    as num?)?.toInt()
                ?? 1;

    // Lore: Liste, leere Strings rausfiltern
    final lore = _parseStringList(itemData['lore'] ?? json['lore'])
        .where((s) => s.isNotEmpty)
        .toList();

    // Enchants: kann {} (Map) oder [] (Liste) sein
    final enchants = _parseEnchants(
      itemData['enchantments'] ?? itemData['enchants'] ??
      json['enchantments']    ?? json['enchants'],
    );

    // ── Startzeit ──────────────────────────────────────────
    final startTimeRaw = json['startTime']  ?? json['start_time']
                       ?? json['startedAt'] ?? json['begin'];
    final startTime = _parseTimestamp(startTimeRaw);

    // ── Endzeit – viele mögliche Feldnamen + Zahl-ODER-String ──
    // Bug bisher: API liefert endsAt als Unix-Timestamp (Zahl).
    // .toString() + DateTime.tryParse() hat das immer auf DateTime.now()
    // zurückfallen lassen → alle Auktionen waren sofort "abgelaufen".
    final endsAtRaw = json['endsAt']   ?? json['end_time'] ?? json['endTime']
                   ?? json['expiry']   ?? json['expires']  ?? json['expiresAt']
                   ?? json['expireAt'] ?? json['until']    ?? json['deadline'];
    final endsAt = _parseTimestamp(endsAtRaw);

    // Verkäufer – aktuell UUID, Klarname kommt über PlayerNameRepository
    final sellerId = json['sellerName']?.toString()
                  ?? json['seller']?.toString()
                  ?? json['owner']?.toString()
                  ?? '';

    return AuctionItem(
      // 🐛 "uid" ist der echte API-Feldname (siehe /auctions/active) –
      // vorher wurde nur "id"/"uuid" geprüft, die ID war dadurch leer.
      id:          json['uid']?.toString()
                ?? json['id']?.toString()
                ?? json['uuid']?.toString()
                ?? '',
      itemName:    itemName,
      category:    json['category']?.toString() ?? 'Sonstiges',
      startBid:    (json['startBid']  as num?)?.toDouble()
                ?? (json['start_bid'] as num?)?.toDouble()
                ?? 0.0,
      currentBid:  (json['currentBid']  as num?)?.toDouble()
                ?? (json['bid']         as num?)?.toDouble()
                ?? (json['current_bid'] as num?)?.toDouble()
                ?? 0.0,
      // 🐛 "instantBuyPrice" ist der echte API-Feldname – vorher
      // wurde er nicht geprüft, Sofort-Kauf war nie befüllt.
      buyNowPrice: (json['instantBuyPrice'] as num?)?.toDouble()
                ?? (json['buyNowPrice']     as num?)?.toDouble()
                ?? (json['buyNow']          as num?)?.toDouble()
                ?? (json['buy_now']         as num?)?.toDouble(),
      amount:      amount,
      startTime:   startTime,
      endsAt:      endsAt,
      sellerId:    sellerId,
      enchants:    enchants,
      lore:        lore,
    );
  }

  // ── Hilfsmethoden ──────────────────────────────────────

  /// ACACIA_LEAVES → Acacia Leaves
  static String? _formatMaterial(String? material) {
    if (material == null || material.isEmpty) return null;
    return material.split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Parst Lore-Listen
  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) return [raw];
    return [];
  }

  /// Parst Enchants – kann [] Liste oder {} Map sein
  static List<String> _parseEnchants(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map && raw.isNotEmpty) {
      // { "SHARPNESS": 5, "UNBREAKING": 3 } → ["Sharpness 5", "Unbreaking 3"]
      return raw.entries.map((e) {
        final name = e.key.toString().split('_')
            .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
        return '$name ${e.value}';
      }).toList();
    }
    return [];
  }

  /// Versteht alle gängigen Timestamp-Formate der OPSUCHT-API:
  ///   - ISO-8601-String:   "2026-06-18T08:08:05.242Z"
  ///   - Unix-Sekunden:     1750000000
  ///   - Unix-Millisekunden: 1750000000000
  ///   - Zahl als String:   "1750000000"
  static DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;

    if (raw is num) {
      // Heuristik: > 10 Stellen → Millisekunden, sonst Sekunden
      final isMillis = raw > 9999999999;
      return DateTime.fromMillisecondsSinceEpoch(
        isMillis ? raw.toInt() : raw.toInt() * 1000,
      );
    }

    if (raw is String) {
      // Zuerst als ISO-Datum versuchen
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
      // Sonst als Zahl in String-Form (z.B. "1750000000")
      final asNum = num.tryParse(raw);
      if (asNum != null) return _parseTimestamp(asNum);
    }

    return null;
  }

  // ── Berechnete Eigenschaften ──────────────────────────

  /// null wenn Endzeit unbekannt, sonst verbleibende Zeit
  Duration? get timeLeft => endsAt?.difference(DateTime.now());

  /// Nur true wenn die Endzeit BEKANNT ist UND in der Vergangenheit liegt.
  /// endsAt == null wird NICHT als abgelaufen interpretiert.
  bool get isExpired   => timeLeft != null && timeLeft!.isNegative;
  bool get hasEnchants => enchants.isNotEmpty;
  bool get hasLore     => lore.isNotEmpty;
  bool get hasBuyNow   => buyNowPrice != null;
}
