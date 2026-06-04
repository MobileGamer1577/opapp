# OPAPP – Companion App für OPSUCHT.NET

Eine moderne Flutter Companion-App für den **OPSUCHT.NET** Minecraft Citybuild Server.

---

## 📱 Download

> Alle Releases findest du im **[Releases-Bereich](../../releases)** dieses Repositories.

### 🤖 Android (APK)

1. Gehe zu **[Releases](../../releases)** und öffne die neueste Version
2. Lade die Datei **`opapp-release_VERSION.apk`** herunter
3. Auf dem Gerät öffnen → bei Bedarf *Unbekannte Quellen* in den Einstellungen erlauben
4. Installieren – fertig

### 🍎 iOS (iPhone / iPad)

1. Gehe zu **[Releases](../../releases)** und öffne die neueste Version
2. Lade die Datei **`opapp_VERSION.ipa`** herunter
3. Installiere [AltStore](https://altstore.io) auf deinem iPhone (kein Jailbreak nötig)
4. Öffne die IPA-Datei in AltStore und installiere sie

> **Hinweis:** Die iOS-Version ist nicht im App Store verfügbar und wird per Sideloading installiert.
> AltStore ist kostenlos und erfordert keinen Jailbreak.

---

## ✨ Features

| Bereich | Beschreibung |
|---------|--------------|
| 🏠 **Dashboard** | Schnellübersicht – Kurs, Auktionen, Navigation |
| 🏪 **Markt** | Alle Items mit Kauf-/Verkaufspreisen & Kategoriefilter |
| 🔨 **Auktionshaus** | Live-Auktionen, alle 30 Sek. aktualisiert, Enchants & Lore |
| 💎 **OPShards** | Aktueller Wechselkurs des Händlers |
| ❓ **Hilfe** | Commands, Regelwerk, Restriktionen & globale Suche |

---

## 🛠 Tech Stack

| Bereich | Technologie |
|---------|-------------|
| Framework | Flutter |
| State Management | Riverpod |
| Navigation | GoRouter |
| HTTP | http |
| Theme | Custom Dark/Light System |
| Persistenz | SharedPreferences |

---

## 👨‍💻 Für Entwickler

### Voraussetzungen

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (stable channel)
- Android Studio oder VS Code mit Flutter Extension
- Für iOS-Builds: macOS mit Xcode (wird automatisch via GitHub Actions gebaut)

### Projekt lokal starten

```bash
flutter pub get
flutter run
```

### Build-Script (Windows)

Das enthaltene PowerShell-Script `build_opapp.ps1` übernimmt den gesamten Build-Workflow:

```powershell
# Normaler Build
.\build_opapp.ps1

# Alle lokalen Backups löschen
.\build_opapp.ps1 -Clear
```

Das Script:
- Fragt nach Versions-Bump (Patch / Minor / Major)
- Baut die Android APK
- Erstellt lokales Backup + ZIP
- Pusht optional einen Git-Tag → GitHub Actions baut dann automatisch iOS IPA + erstellt den Release

### Automatische Builds (GitHub Actions)

Bei jedem Tag-Push (`v*.*.*`) wird automatisch:
- 🤖 Android APK auf Ubuntu gebaut
- 🍎 iOS IPA auf macOS gebaut
- 📢 GitHub Release mit beiden Dateien erstellt

### Projektstruktur

```
lib/
├── core/
│   ├── constants/     API-URLs, Timeouts
│   ├── routing/       GoRouter Navigation
│   └── theme/         Dark/Light Theme System
├── data/
│   ├── models/        Datenmodelle (Markt, Auktionen, Shards)
│   ├── repositories/  Riverpod Provider & Datenabruf
│   └── services/      HTTP API-Service
├── features/
│   ├── dashboard/     Dashboard Screen
│   ├── market/        Markt Screen
│   ├── auctions/      Auktionshaus Screen
│   ├── shards/        OPShards Screen
│   └── help/          Hilfe, Commands, Regelwerk
└── shared/
    └── widgets/       Wiederverwendbare Widgets
```

---

## 📄 Lizenz

MIT License – siehe [LICENSE](LICENSE)

---

> Dieses Projekt ist ein Community-Projekt und steht in keiner offiziellen Verbindung mit OPSUCHT.NET.
