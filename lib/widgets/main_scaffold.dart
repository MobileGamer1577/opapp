import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_router.dart';
import '../core/app_colors.dart';

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

    return Container(
      // Gradient-Hintergrund wie im Referenz-Design (dunkel-lila -> fast schwarz)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            AppColors.gradientTop,
            AppColors.gradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Gradient durchscheinen lassen
        body: child,
        bottomNavigationBar: _BottomNav(index: index),
      ),
    );
  }
}

// ─── Styled Bottom Navigation Bar ───────────────────────────
class _BottomNav extends StatelessWidget {
  final int index;
  const _BottomNav({required this.index});

  static const _tabs = [
    AppRoutes.dashboard,
    AppRoutes.market,
    AppRoutes.auctions,
    AppRoutes.shards,
    AppRoutes.help,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon:       Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label:      'Dashboard',
                isActive:   index == 0,
                onTap:      () => context.go(_tabs[0]),
              ),
              _NavItem(
                icon:       Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label:      'Markt',
                isActive:   index == 1,
                onTap:      () => context.go(_tabs[1]),
              ),
              _NavItem(
                icon:       Icons.gavel_outlined,
                activeIcon: Icons.gavel,
                label:      'Auktionen',
                isActive:   index == 2,
                onTap:      () => context.go(_tabs[2]),
              ),
              _NavItem(
                icon:       Icons.diamond_outlined,
                activeIcon: Icons.diamond,
                label:      'OPShards',
                isActive:   index == 3,
                onTap:      () => context.go(_tabs[3]),
              ),
              _NavItem(
                icon:       Icons.help_outline,
                activeIcon: Icons.help,
                label:      'Hilfe',
                isActive:   index == 4,
                onTap:      () => context.go(_tabs[4]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aktiv-Indikator-Dot oben
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:  isActive ? 20 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color:        AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              isActive ? activeIcon : icon,
              color:   isActive ? AppColors.accent : AppColors.darkTextHint,
              size:    22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:      isActive ? AppColors.accent : AppColors.darkTextHint,
                fontSize:   10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
