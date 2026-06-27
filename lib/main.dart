import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Statusbar / Navigationbar transparent (Android)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.light,
      systemNavigationBarColor:  Colors.transparent,
    ),
  );

  // Nur Portrait-Modus (kann später erweitert werden)
  // ✅ Web-Kompatibilität: kIsWeb-Check, da setPreferredOrientations()
  // im Browser ohnehin keine Wirkung hat (kein Fehler, aber unnötig).
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(
    // ProviderScope ist das Root-Widget für Riverpod
    const ProviderScope(
      child: OpApp(),
    ),
  );
}
