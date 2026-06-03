import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

class OpApp extends ConsumerWidget {
  const OpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router    = ref.watch(routerProvider);

    return MaterialApp.router(
      title:            'OPAPP',
      debugShowCheckedModeBanner: false,

      // ─── Theme ──────────────────────────────────────────────
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  themeMode,

      // ─── Navigation ─────────────────────────────────────────
      routerConfig: router,
    );
  }
}
