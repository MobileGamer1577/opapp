import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Gradient-Hintergrund – wird von jedem Screen verwendet
/// da kein ShellRoute / MainScaffold mehr vorhanden ist
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [AppColors.gradientTop, AppColors.gradientBottom],
        ),
      ),
      child: child,
    );
  }
}
