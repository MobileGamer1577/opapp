// ═══════════════════════════════════════════════════════════════
//  app_info.dart – Datenmodell für die App-Versionsinfos (Über-Screen)
//
//  ✅ HIER ÄNDERN: Felder ergänzen (z.B. Build-Datum)
//  ❌ NICHT ÄNDERN: Klassenstruktur
//
//  QUELLE DER DATEN (siehe app_info_repository.dart):
//    - appName / version / buildNumber → package_info_plus
//      (liest direkt aus den nativen Build-Infos, Android:
//      build.gradle, iOS: Info.plist – KEINE manuelle Pflege nötig)
//    - isRelease → kReleaseMode (von Flutter automatisch gesetzt,
//      true im Release-Build, false z.B. bei "flutter run")
// ═══════════════════════════════════════════════════════════════

class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final bool isRelease;

  const AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.isRelease,
  });

  /// z.B. "1.0.0 (3)" – oder nur "1.0.0" falls keine Build-Nummer gesetzt ist.
  String get displayVersion =>
      buildNumber.isNotEmpty ? '$version ($buildNumber)' : version;

  /// z.B. "RELEASE" oder "DEBUG"
  String get buildLabel => isRelease ? 'RELEASE' : 'DEBUG';
}
