import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'core/app_router.dart';

class OpApp extends ConsumerWidget {
  const OpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title:            'OPAPP',
      debugShowCheckedModeBanner: false,
      theme:            AppTheme.dark,   // Immer Dark Mode
      themeMode:        ThemeMode.dark,
      routerConfig:     router,
    );
  }
}
