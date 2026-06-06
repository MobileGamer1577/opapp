// ═══════════════════════════════════════════════════════════════
//  app_router.dart – Navigation der App
//
//  ✅ HIER ÄNDERN: Neue Routen registrieren
//  ✅ HIER ÄNDERN: Route-Namen (AppRoutes Klasse)
//  ❌ NICHT ÄNDERN: routerProvider Struktur
//
//  NEUE ROUTE HINZUFÜGEN:
//    1. String-Konstante in AppRoutes ergänzen
//    2. GoRoute in der routes: [...] Liste ergänzen
//
//  NAVIGATION IM CODE:
//    context.push(AppRoutes.market)   → mit Back-Button
//    context.go(AppRoutes.dashboard)  → ohne Back-Button
//    context.pop()                    → zurück
// ═══════════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/dashboard_screen.dart';
import '../screens/market_screen.dart';
import '../screens/auctions_screen.dart';
import '../screens/shards_screen.dart';
import '../screens/help_screen.dart';
// ← Neue Screen-Imports hier hinzufügen

// ── Route-Namen als Konstanten ────────────────────────────────
// Immer diese Konstanten verwenden, nie '/market' direkt im Code.
// So muss bei einer URL-Änderung nur diese Klasse angepasst werden.
abstract class AppRoutes {
  static const dashboard = '/';
  static const market    = '/market';
  static const auctions  = '/auctions';
  static const shards    = '/shards';
  static const help      = '/help';
  // ← Neue Route hier ergänzen, z.B.:
  // static const stats = '/stats';
}

// ── Router Provider ───────────────────────────────────────────
// routerProvider wird in lib/app.dart verwendet.
// Kein ShellRoute – Gradient-Hintergrund kommt vom AppBackground Widget.
// context.push() sorgt dafür dass der Back-Button automatisch erscheint.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path:    AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path:    AppRoutes.market,
        builder: (_, __) => const MarketScreen(),
      ),
      GoRoute(
        path:    AppRoutes.auctions,
        builder: (_, __) => const AuctionsScreen(),
      ),
      GoRoute(
        path:    AppRoutes.shards,
        builder: (_, __) => const ShardsScreen(),
      ),
      GoRoute(
        path:    AppRoutes.help,
        builder: (_, __) => const HelpScreen(),
      ),
      // ← Neue GoRoute hier ergänzen, z.B.:
      // GoRoute(
      //   path:    AppRoutes.stats,
      //   builder: (_, __) => const StatsScreen(),
      // ),
    ],
  );
});
