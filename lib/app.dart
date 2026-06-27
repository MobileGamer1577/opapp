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
      // ✅ Web-Kompatibilität: Begrenzt die Breite auf Desktop-Browsern
      // auf Handy-Format (480px), damit das Phone-Layout nicht über
      // den ganzen Bildschirm gestreckt wird. Auf dem iPhone (Safari,
      // ~390–430px breit) greift diese Begrenzung ohnehin nie.
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child!,
          ),
        );
      },
    );
  }
}
