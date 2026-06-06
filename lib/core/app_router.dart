import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/dashboard_screen.dart';
import '../screens/market_screen.dart';
import '../screens/auctions_screen.dart';
import '../screens/shards_screen.dart';
import '../screens/help_screen.dart';

// ─── Route-Namen ─────────────────────────────────────────────
abstract class AppRoutes {
  static const dashboard = '/';
  static const market    = '/market';
  static const auctions  = '/auctions';
  static const shards    = '/shards';
  static const help      = '/help';
}

// ─── Router ──────────────────────────────────────────────────
// Kein ShellRoute mehr – keine Bottom Nav
// Navigation: context.push() von Dashboard, back-Button in AppBar
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
    ],
  );
});
