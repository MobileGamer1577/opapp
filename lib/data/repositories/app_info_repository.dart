// ═══════════════════════════════════════════════════════════════
//  app_info_repository.dart – Lädt App-Name, Version & Build-Typ
//
//  ✅ HIER ÄNDERN: nichts Spezielles nötig, läuft automatisch
//  ❌ NICHT ÄNDERN: Provider-Name appInfoProvider
//
//  SETUP:
//    flutter pub add package_info_plus
//
//  Versionsnummer & Build-Nummer kommen direkt aus den nativen
//  Build-Infos – beim Release einfach wie gewohnt in der
//  pubspec.yaml hochzählen (version: 1.0.0+1), hier muss NICHTS
//  manuell angepasst werden.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_info.dart';

final appInfoProvider = FutureProvider.autoDispose<AppInfo>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppInfo(
    appName:     info.appName,
    version:     info.version,
    buildNumber: info.buildNumber,
    isRelease:   kReleaseMode,
  );
});
