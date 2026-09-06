# Release Notes – Server-Info-Erweiterung

## Zusammenfassung
- **Dashboard:** Server-Status-Zeile ist jetzt als abgerundeter Chip/Button
  gestaltet (Hintergrund + Rahmen je nach Status leicht eingefärbt: Grün
  bei Online, Rot bei Offline, neutral bei Laden/Fehler) mit echtem
  Tap-Ripple-Effekt – macht auf den ersten Blick klar, dass man tippen kann.
- **Server-Info-Screen** zeigt jetzt 5 statt 3 Kacheln:
  1. Status & Auslastung – unverändert (reine Online-Zahl, bewusst KEIN
     "X/Y": maxPlayers ist live geprüft immer nur onlinePlayers+1, keine
     echte Kapazität)
  2. **NEU:** Peak heute – höchste Online-Spielerzahl seit Mitternacht
     (Europe/Berlin), inkl. Uhrzeit
  3. **NEU:** Unterstützte Versionen – Versions-Spanne aus der Live-API
     (z. B. "1.8.x – 1.26.x") + feste Zeile zur Farmwelt-Version
  4. Spieler-Rekord (All-Time) – unverändert, nur an Position 4
  5. Server gegründet – Countdown zeigt jetzt zusätzlich die
     Jubiläums-Zahl ("… bis zum 8. Geburtstag" statt "… zum nächsten
     Jubiläum")
- **Backend (opapp-api):** neue D1-Tabelle `daily_peak` + neuer Endpunkt
  `GET /server/peak/today`, pflegt sich im bestehenden 1-Minuten-Cron mit
  (kein zusätzlicher Request an mc-api.io).

## ⚠️ Vor dem Deploy (Backend, einmalig)
1. Migration remote ausführen: `npm run db:migrate-daily-peak`
   (führt `migrations/0004_daily_peak.sql` aus)
2. **Erst danach** `npx wrangler deploy` – sonst schreibt der 1-Minuten-Cron
   in eine noch nicht existierende Tabelle. Das wird zwar nur geloggt (kein
   harter Crash, der All-Time-Rekord bleibt unberührt), aber der Tages-Peak
   bliebe bis zur Migration leer.

## Dateien

**Flutter (opapp)**
- `lib/data/models/server_status.dart` – neues Feld `versionRange` + Regex-
  basierte Normalisierung des rohen `version`-Feldes ("BungeeCord
  1.8.x-26.x" → "1.8.x – 1.26.x")
- `lib/core/app_format.dart` – neue Methode `AppFormat.time()` ("14:32 Uhr")
- `lib/core/api_constants.dart` – neue Konstante `serverPeakToday`
- `lib/data/repositories/server_status_repository.dart` – neuer Provider
  `serverPeakTodayProvider`, neue Konstante `farmWorldVersion`, neue
  Funktion `nextServerBirthdayNumber()`
- `lib/screens/server_info_screen.dart` – 5-Kacheln-Layout
- `lib/screens/dashboard_screen.dart` – `_ServerStatusRow` im
  Chip/Button-Design

**Backend (opapp-api)**
- `migrations/0004_daily_peak.sql` – neue Tabelle `daily_peak`
- `src/worker.js` – `pollPlayerPeak()` erweitert (ein Fetch, zwei Updates),
  neue Helfer `updateAllTimePeak()`, `updateDailyPeak()`, `berlinDateString()`,
  neuer Endpunkt `/server/peak/today`, neue Route im Health-Check
- `package.json` – neue Scripts `db:migrate-daily-peak`, `db:peak-today`
- `MONITORING.md` – Abschnitt 6 um den Tages-Peak ergänzt
