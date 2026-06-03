# OPAPP – Companion App für OPSUCHT.NET

Eine moderne, professionelle Flutter-App für den OPSUCHT.NET Minecraft Citybuild Server.

## Features

- **Dashboard** – Markt, Auktionen & OPShard-Kurs auf einen Blick
- **Markt** – Alle Items mit Kauf-/Verkaufspreisen & Kategorien
- **Auktionshaus** – Live-Auktionen mit 30-Sekunden-Refresh, Enchants & Lore
- **OPShards** – Aktueller Wechselkurs des Händlers
- **Hilfe** – Commands, Regelwerk, Restriktionen & globale Suche

## Tech Stack

| Bereich           | Technologie           |
|-------------------|-----------------------|
| Framework         | Flutter               |
| State Management  | Riverpod              |
| Navigation        | GoRouter              |
| HTTP              | http                  |
| Theming           | Custom ThemeSystem    |
| Persistenz        | SharedPreferences     |

## Erste Schritte

```bash
# 1. Repository klonen
git clone https://github.com/DEIN-USER/opapp.git
cd opapp

# 2. Dependencies installieren
flutter pub get

# 3. App starten
flutter run
```

## Build

```powershell
# APK bauen + Backup erstellen (Windows)
.\build_opapp.ps1

# Alle Backups löschen
.\build_opapp.ps1 -Clear
```

## Projektstruktur

```
lib/
├── core/
│   ├── constants/   # API-URLs, Konstanten
│   ├── routing/     # GoRouter Navigation
│   └── theme/       # Dark/Light Theme System
├── data/
│   ├── models/      # Datenmodelle
│   ├── repositories/# Daten-Provider (Riverpod)
│   └── services/    # API-Service
├── features/
│   ├── dashboard/   # Dashboard Screen
│   ├── market/      # Markt Screen
│   ├── auctions/    # Auktionshaus Screen
│   ├── shards/      # OPShards Screen
│   └── help/        # Hilfe Screen + Commands
└── shared/
    └── widgets/     # Wiederverwendbare Widgets
```

## Lizenz

MIT License – siehe [LICENSE](LICENSE)

---

> **Hinweis:** Dieses Projekt ist ein Community-Projekt und steht in keiner offiziellen Verbindung mit OPSUCHT.NET.
