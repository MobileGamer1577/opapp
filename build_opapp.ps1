# ============================================================
#  OPAPP – Build & Release Script (Automatische Versionierung)
#
#  Normaler Aufruf:      .\build_opapp.ps1
#  Alle Backups loeschen: .\build_opapp.ps1 -Clear
#
#  Was passiert automatisch:
#    1. Version aus pubspec.yaml auslesen
#    2. Art des Updates abfragen (Patch / Minor / Major)
#    3. Neue Version berechnen + Build-Nummer erhoehen
#    4. pubspec.yaml automatisch aktualisieren
#    5. flutter clean + pub get + build apk --release
#    6. APK umbenennen + Backup-Ordner erstellen
#    7. ZIP mit Quellcode packen
#    8. Alte Backups aufraumen (letzte 10 behalten)
#
#  Danach manuell auf GitHub:
#    -> Releases -> Draft a new release -> APK hochladen
#    -> iOS IPA: GitHub Actions -> "Build iOS IPA" -> Run workflow
# ============================================================

param(
    [switch]$Clear   # .\build_opapp.ps1 -Clear loescht alle Backups
)

$ProjectRoot  = $PSScriptRoot
$BackupBase   = Join-Path $ProjectRoot "_backups"
$PubspecPath  = Join-Path $ProjectRoot "pubspec.yaml"

# ════════════════════════════════════════════════════════════
#  HILFSFUNKTIONEN
# ════════════════════════════════════════════════════════════

function Step($Nr, $Total, $Text) {
    Write-Host ""
    Write-Host "  [$Nr/$Total] $Text" -ForegroundColor Cyan
    Write-Host "  $('-' * 44)" -ForegroundColor DarkGray
}

function OK($Text)    { Write-Host "  [OK]    $Text" -ForegroundColor Green }
function WARN($Text)  { Write-Host "  [WARN]  $Text" -ForegroundColor Yellow }
function ERR($Text)   { Write-Host "  [ERR]   $Text" -ForegroundColor Red }
function INFO($Text)  { Write-Host "  [INFO]  $Text" -ForegroundColor White }
function SKIP($Text)  { Write-Host "  [skip]  $Text" -ForegroundColor DarkGray }

# -------------------------------------───────────────────────
#  Liest die aktuelle Version aus pubspec.yaml
# -------------------------------------───────────────────────
function Read-PubspecVersion {
    if (-not (Test-Path $PubspecPath)) {
        Write-Host ""
        ERR "pubspec.yaml nicht gefunden: $PubspecPath"
        exit 1
    }

    $content = Get-Content $PubspecPath -Raw

    if ($content -match 'version:\s*(\d+)\.(\d+)\.(\d+)(?:-([a-zA-Z0-9]+))?(?:\+(\d+))?') {
        return @{
            Major = [int]$Matches[1]
            Minor = [int]$Matches[2]
            Patch = [int]$Matches[3]
            Pre   = if ($Matches[4]) { $Matches[4] } else { "" }
            Build = if ($Matches[5]) { [int]$Matches[5] } else { 0 }
        }
    }

    Write-Host ""
    ERR "Konnte Version nicht aus pubspec.yaml lesen!"
    ERR "Erwartet: 'version: X.Y.Z' oder 'version: X.Y.Z-pre+build'"
    exit 1
}

function Build-VersionString($v) {
    $base = "$($v.Major).$($v.Minor).$($v.Patch)"
    if ($v.Pre -ne "") { $base += "-$($v.Pre)" }
    if ($v.Build -gt 0) { $base += "+$($v.Build)" }
    return $base
}

function Write-PubspecVersion($NewVersionString) {
    $content = Get-Content $PubspecPath -Raw
    $updated = $content -replace 'version:\s*\d+\.\d+\.\d+(?:-[a-zA-Z0-9]+)?(?:\+\d+)?', "version: $NewVersionString"
    Set-Content -Path $PubspecPath -Value $updated -Encoding UTF8 -NoNewline
}

function Show-Menu($Title, $Options) {
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor White
    Write-Host ""
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "    [$($i+1)] $($Options[$i])" -ForegroundColor Cyan
    }
    Write-Host ""

    while ($true) {
        $raw = Read-Host "  Auswahl (1-$($Options.Count))"
        $num = 0
        if ([int]::TryParse($raw.Trim(), [ref]$num) -and $num -ge 1 -and $num -le $Options.Count) {
            return $num - 1
        }
        WARN "Ungueltige Eingabe. Bitte 1 bis $($Options.Count) eingeben."
    }
}

# ════════════════════════════════════════════════════════════
#  -Clear: Alle Backups loeschen
# ════════════════════════════════════════════════════════════
if ($Clear) {
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Red
    Write-Host "   OPAPP - Alle Backups loeschen" -ForegroundColor Red
    Write-Host "  ========================================" -ForegroundColor Red
    Write-Host ""

    if (-not (Test-Path $BackupBase)) {
        SKIP "Keine Backups gefunden (_backups Ordner existiert nicht)."
        Write-Host ""
        exit 0
    }

    $AllItems = Get-ChildItem -Path $BackupBase
    if ($AllItems.Count -eq 0) {
        SKIP "Keine Backups vorhanden."
        Write-Host ""
        exit 0
    }

    INFO "Folgende Elemente werden geloescht:"
    foreach ($item in $AllItems) {
        Write-Host "    - $($item.Name)" -ForegroundColor DarkGray
    }
    Write-Host ""

    $Confirm = Read-Host "  Wirklich alle Backups loeschen? (j/n)"
    if ($Confirm -ne "j" -and $Confirm -ne "J") {
        Write-Host ""
        WARN "Abgebrochen."
        Write-Host ""
        exit 0
    }

    Remove-Item -Path "$BackupBase\*" -Recurse -Force
    Write-Host ""
    OK "Alle Backups geloescht."
    Write-Host ""
    exit 0
}

# ════════════════════════════════════════════════════════════
#  NORMALER BUILD & RELEASE ABLAUF
# ════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   OPAPP - Build & Release Script" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan

# -------------------------------------───────────────────────
#  PHASE 0: Version aus pubspec.yaml lesen
# -------------------------------------───────────────────────
Write-Host ""
INFO "Lese aktuelle Version aus pubspec.yaml..."

$v = Read-PubspecVersion
$CurrentString = Build-VersionString $v

Write-Host ""
Write-Host "  Aktuelle Version: " -NoNewline
Write-Host $CurrentString -ForegroundColor Yellow
Write-Host ""

# -------------------------------------───────────────────────
#  PHASE 1: Art des Updates waehlen
# -------------------------------------───────────────────────

$patchEx = "$($v.Major).$($v.Minor).$($v.Patch + 1)"
$minorEx = "$($v.Major).$($v.Minor + 1).0"
$majorEx = "$($v.Major + 1).0.0"

$updateChoice = Show-Menu "Welches Update?" @(
    "Patch  -> $patchEx   (Bugfixes, kleine Aenderungen)"
    "Minor  -> $minorEx   (Neue Features, kein Breaking Change)"
    "Major  -> $majorEx   (Grosse Aenderungen, Breaking Change)"
    "Nur Build-Nummer erhoehen (kein Versions-Bump)"
)

$newV = @{
    Major = $v.Major
    Minor = $v.Minor
    Patch = $v.Patch
    Pre   = $v.Pre
    Build = $v.Build + 1
}

switch ($updateChoice) {
    0 { $newV.Patch = $v.Patch + 1 }
    1 { $newV.Minor = $v.Minor + 1; $newV.Patch = 0 }
    2 { $newV.Major = $v.Major + 1; $newV.Minor = 0; $newV.Patch = 0 }
    3 { <# Nur Build #> }
}

# -------------------------------------───────────────────────
#  PHASE 2: Pre-Release-Tag waehlen (optional)
# -------------------------------------───────────────────────

$preChoice = Show-Menu "Pre-Release-Tag?" @(
    "Unveraendert lassen  (aktuell: $(if ($v.Pre -eq '') { 'keiner' } else { $v.Pre }))"
    "beta  setzen"
    "alpha setzen"
    "Tag entfernen (stabile Version)"
    "Manuell eingeben"
)

switch ($preChoice) {
    0 { <# Nichts aendern #> }
    1 { $newV.Pre = "beta" }
    2 { $newV.Pre = "alpha" }
    3 { $newV.Pre = "" }
    4 {
        $manual = Read-Host "  Pre-Release-Tag eingeben (z.B. rc1)"
        $newV.Pre = $manual.Trim()
    }
}

# -------------------------------------───────────────────────
#  Neue Version zusammenbauen + Bestaetigung
# -------------------------------------───────────────────────

$NewVersionString = Build-VersionString $newV

Write-Host ""
Write-Host "  +-------------------------------------+" -ForegroundColor DarkGray
Write-Host "  |  Versionsaenderung                  |" -ForegroundColor DarkGray
Write-Host "  |                                     |" -ForegroundColor DarkGray
Write-Host "  |  Vorher:  " -NoNewline -ForegroundColor DarkGray
Write-Host $CurrentString.PadRight(26) -NoNewline -ForegroundColor Yellow
Write-Host "|" -ForegroundColor DarkGray
Write-Host "  |  Nachher: " -NoNewline -ForegroundColor DarkGray
Write-Host $NewVersionString.PadRight(26) -NoNewline -ForegroundColor Green
Write-Host "|" -ForegroundColor DarkGray
Write-Host "  |                                     |" -ForegroundColor DarkGray
Write-Host "  +-------------------------------------+" -ForegroundColor DarkGray
Write-Host ""

$confirm = Read-Host "  Weiter mit diesem Build? (j/n)"
if ($confirm -ne "j" -and $confirm -ne "J") {
    Write-Host ""
    WARN "Abgebrochen. pubspec.yaml wurde NICHT veraendert."
    Write-Host ""
    exit 0
}

# -------------------------------------───────────────────────
#  pubspec.yaml aktualisieren
# -------------------------------------───────────────────────

Write-Host ""
INFO "Schreibe neue Version in pubspec.yaml..."
Write-PubspecVersion $NewVersionString
OK "pubspec.yaml aktualisiert: $NewVersionString"

# ════════════════════════════════════════════════════════════
#  BUILD-PIPELINE (5 Schritte)
# ════════════════════════════════════════════════════════════

Set-Location $ProjectRoot

# ── SCHRITT 1: flutter clean ─────────────────────────────────
Step "1" "5" "flutter clean"
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    ERR "flutter clean fehlgeschlagen!"
    WARN "pubspec.yaml wurde bereits auf $NewVersionString aktualisiert."
    exit 1
}
OK "clean"

# ── SCHRITT 2: flutter pub get ───────────────────────────────
Step "2" "5" "flutter pub get"
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    ERR "flutter pub get fehlgeschlagen!"
    exit 1
}
OK "pub get"

# ── SCHRITT 3: flutter build apk --release ───────────────────
Step "3" "5" "flutter build apk --release  (Android)"
INFO "iOS IPA: GitHub Actions -> Run workflow -> 'Build iOS IPA'"
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    ERR "Build fehlgeschlagen!"
    exit 1
}
OK "Build erfolgreich"

# ── SCHRITT 4: Backup erstellen ──────────────────────────────
Step "4" "5" "Backup erstellen"

$Timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm"
$VersionSafe = $NewVersionString -replace '\+', 'b'
$FolderName = "${Timestamp}_${VersionSafe}"
$Dest       = Join-Path $BackupBase $FolderName

New-Item -ItemType Directory -Force -Path $Dest | Out-Null

$Items = @(
    @{ Src = "lib";                   Recurse = $true  },
    @{ Src = "assets";                Recurse = $true  },
    @{ Src = "pubspec.yaml";          Recurse = $false },
    @{ Src = "README.md";             Recurse = $false },
    @{ Src = "analysis_options.yaml"; Recurse = $false },
    @{ Src = "LICENSE";               Recurse = $false }
)

# Gradle-Datei optional mitsichern
$GradleFile = Join-Path $ProjectRoot "android\app\build.gradle.kts"
if (Test-Path $GradleFile) {
    $Items += @{ Src = "android\app\build.gradle.kts"; Recurse = $false }
}

# APK suchen
$ApkSource = $null
$ApkSearchPaths = @(
    "build\flutter-apk\app-release.apk",
    "build\app\outputs\flutter-apk\app-release.apk",
    "build\app\outputs\apk\release\app-release.apk"
)
foreach ($p in $ApkSearchPaths) {
    $full = Join-Path $ProjectRoot $p
    if (Test-Path $full) { $ApkSource = $full; break }
}

$ApkName = "opapp-release_${VersionSafe}.apk"
$ApkDest = Join-Path $Dest $ApkName

$CopiedFiles = 0
foreach ($item in $Items) {
    $Src = Join-Path $ProjectRoot $item.Src
    if (-not (Test-Path $Src)) {
        SKIP $item.Src
        continue
    }
    if ($item.Recurse) {
        $RelDest = Join-Path $Dest $item.Src
        Copy-Item -Path $Src -Destination $RelDest -Recurse -Force
        $Count = (Get-ChildItem $RelDest -Recurse -File).Count
        OK "$($item.Src)  ($Count Dateien)"
        $CopiedFiles += $Count
    } else {
        $RelDir = Split-Path $item.Src -Parent
        if ($RelDir) {
            New-Item -ItemType Directory -Force -Path (Join-Path $Dest $RelDir) | Out-Null
        }
        Copy-Item -Path $Src -Destination (Join-Path $Dest $item.Src) -Force
        OK $item.Src
        $CopiedFiles++
    }
}

if ($ApkSource) {
    Copy-Item -Path $ApkSource -Destination $ApkDest -Force
    $ApkMB = [math]::Round((Get-Item $ApkDest).Length / 1MB, 1)
    Write-Host "  [APK]   $ApkName  ($ApkMB MB)" -ForegroundColor Yellow
} else {
    ERR "APK nach dem Build nicht gefunden!"
}

@"
OPAPP Backup
============
Projekt   : OPAPP - OPSUCHT.NET Companion App
Version   : $NewVersionString
APK-Name  : $ApkName
Erstellt  : $Timestamp
Dateien   : $CopiedFiles

Vorherige Version: $CurrentString
"@ | Set-Content (Join-Path $Dest "BACKUP_INFO.txt") -Encoding UTF8

# ── SCHRITT 5: ZIP erstellen ─────────────────────────────────
Step "5" "5" "ZIP erstellen (Quellcode ohne APK)"

$ZipTmpDir = Join-Path $BackupBase "_zip_tmp_${Timestamp}"
New-Item -ItemType Directory -Force -Path $ZipTmpDir | Out-Null

Get-ChildItem -Path $Dest | Where-Object { $_.Name -ne $ApkName } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $ZipTmpDir -Recurse -Force
}

$ZipName = "opapp_source_${VersionSafe}.zip"
$ZipPath = Join-Path $BackupBase $ZipName

if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
Compress-Archive -Path "$ZipTmpDir\*" -DestinationPath $ZipPath -CompressionLevel Optimal
Remove-Item -Path $ZipTmpDir -Recurse -Force

$ZipSize = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)
OK "$ZipName  ($ZipSize MB)"

# ── Alte Backups aufraumen (letzte 10 behalten) ───────────────
$AllBackups = Get-ChildItem -Path $BackupBase -Directory | Sort-Object Name -Descending
if ($AllBackups.Count -gt 10) {
    $ToDelete = $AllBackups | Select-Object -Skip 10
    foreach ($old in $ToDelete) {
        Remove-Item -Path $old.FullName -Recurse -Force
        SKIP "Altes Backup entfernt: $($old.Name)"
    }
}

# ════════════════════════════════════════════════════════════
#  FERTIG
# ════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   Build abgeschlossen!" -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Version:  " -NoNewline -ForegroundColor DarkGray
Write-Host $NewVersionString -ForegroundColor Green
Write-Host ""
Write-Host "  APK (Android):" -ForegroundColor White
Write-Host "  $ApkDest" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ZIP (Quellcode):" -ForegroundColor White
Write-Host "  $ZipPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "  -------------------------------------" -ForegroundColor DarkGray
Write-Host "  Naechste Schritte:" -ForegroundColor White
Write-Host ""
Write-Host "  Android Release:" -ForegroundColor DarkGray
Write-Host "    1. GitHub -> Releases -> Draft a new release" -ForegroundColor DarkGray
Write-Host "    2. APK aus dem Backup-Ordner hochladen" -ForegroundColor DarkGray
Write-Host "    3. Release veroeffentlichen" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  iOS IPA (optional):" -ForegroundColor DarkGray
Write-Host "    1. GitHub -> Actions -> 'Build iOS IPA'" -ForegroundColor DarkGray
Write-Host "    2. Run workflow -> IPA als Artifact herunterladen" -ForegroundColor DarkGray
Write-Host "    3. IPA zum Release hinzufuegen" -ForegroundColor DarkGray
Write-Host "  -------------------------------------" -ForegroundColor DarkGray
Write-Host ""

$OpenExplorer = Read-Host "  Backup-Ordner im Explorer oeffnen? (j/n)"
if ($OpenExplorer -eq "j" -or $OpenExplorer -eq "J") {
    Start-Process explorer.exe $BackupBase
}

Write-Host ""
