import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    AppRoutes.dashboard,
    AppRoutes.market,
    AppRoutes.auctions,
    AppRoutes.shards,
    AppRoutes.help,
  ];

  int _currentIndex(String location) {
    for (var i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index    = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i]),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Markt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_outlined),
            activeIcon: Icon(Icons.gavel),
            label: 'Auktionen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            activeIcon: Icon(Icons.diamond),
            label: 'OPShards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: 'Hilfe',
          ),
        ],
      ),
    );
  }
}
