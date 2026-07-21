// ═══════════════════════════════════════════════════════════════
//  service_status_screen.dart – "Dienstverfügbarkeit"-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign; Endpunkte selbst liegen in
//                  service_status_repository.dart
//  ❌ NICHT ÄNDERN: serviceStatusControllerProvider-Aufruf
//
//  Zeigt für jede von der App genutzte API (OPSUCHT, mc-api.io, das
//  eigene opapp-shards-api Backend) den Live-Status: Online (mit
//  Ping in ms) oder Offline. Rein informativ – hat keinen Einfluss
//  auf die restliche App, falls einzelne Dienste gerade down sind.
//
//  ÄNDERUNGEN (Sequenziell-Update):
//    - Bewusst KEIN Pull-to-Refresh mehr (RefreshIndicator entfernt).
//    - ListView.builder statt ListView: Karten werden erst gebaut
//      (und melden sich erst dann beim Controller an), wenn sie
//      tatsächlich in oder nahe am sichtbaren Bereich sind. Beim
//      Scrollen kommen neue Karten dazu, bereits geprüfte bleiben im
//      Cache (siehe service_status_repository.dart) und werden NICHT
//      erneut angefragt, auch wenn die Karte durch Scrollen weg und
//      wieder zurück neu gebaut wird.
//    - Die Reihenfolge der Requests ist strikt sequenziell (siehe
//      ServiceStatusController._processQueue) – erst wenn eine
//      Antwort da ist, startet der nächste Request.
//    - Refresh-Button im AppBar bleibt erhalten (kompletter Neu-Check
//      aller Endpunkte, auch aktuell nicht sichtbarer).
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/service_status_repository.dart';
import '../widgets/app_background.dart';

class ServiceStatusScreen extends ConsumerWidget {
  const ServiceStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gruppen + Endpunkte zu einer flachen Liste zusammenfassen –
    // ListView.builder kennt keine Gruppen, nur Einträge. Ein String-
    // Eintrag steht für ein Gruppen-Label, ein ServiceEndpoint für
    // eine Karte.
    final flatItems = <Object>[];
    for (final group in endpointGroups) {
      flatItems.add(group.key);
      flatItems.addAll(group.value);
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Dienstverfügbarkeit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(serviceStatusControllerProvider.notifier).refreshAll(),
            ),
          ],
        ),
        // Bewusst KEIN RefreshIndicator – kein Pull-to-Refresh gewünscht.
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flatItems.length,
          itemBuilder: (context, index) {
            final item = flatItems[index];
            if (item is String) {
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 14, bottom: 10),
                child: _GroupLabel(item),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ServiceCard(endpoint: item as ServiceEndpoint),
            );
          },
        ),
      ),
    );
  }
}

// ─── Gruppen-Label (z.B. "Markt-API") ─────────────────────────

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color:      AppColors.info,
          fontSize:   15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Einzelne Dienst-Karte ─────────────────────────────────────
// ConsumerStatefulWidget: meldet sich beim ersten Build (initState)
// beim ServiceStatusController an – der kümmert sich um Reihenfolge
// + Cache. Wird die Karte durch Scrollen zerstört und später neu
// gebaut, ist requestCheck() dann ein No-Op (Ergebnis bleibt im
// Provider gecacht, unabhängig vom Lebenszyklus dieser Karte).

class _ServiceCard extends ConsumerStatefulWidget {
  final ServiceEndpoint endpoint;
  const _ServiceCard({required this.endpoint});

  @override
  ConsumerState<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<_ServiceCard> {
  @override
  void initState() {
    super.initState();
    // Nach dem aktuellen Frame anfragen, nicht synchron während des
    // Builds (sonst wirft Riverpod einen "modify provider while
    // widget tree is building"-Fehler).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(serviceStatusControllerProvider.notifier).requestCheck(widget.endpoint);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = ref.watch(serviceStatusControllerProvider)[widget.endpoint];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:        AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.endpoint.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _shortenUrl(widget.endpoint.url),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          result == null
              ? const _CheckingChip()
              : _StatusChip(
                  online: result.isOnline,
                  label: result.isOnline ? 'Online (${result.pingMs}ms)' : 'Offline',
                ),
        ],
      ),
    );
  }

  /// Kürzt lange URLs (v.a. bei parametrisierten Routen mit UUIDs)
  /// für die Anzeige.
  String _shortenUrl(String url) {
    if (url.length <= 42) return url;
    return '${url.substring(0, 39)}...';
  }
}

// ─── Status-Chip (Online/Offline) ─────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool online;
  final String label;
  const _StatusChip({required this.online, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.success : AppColors.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          online ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── "Wird überprüft…"-Anzeige (solange der Check noch läuft) ──

class _CheckingChip extends StatelessWidget {
  const _CheckingChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.darkTextSecondary,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Wird überprüft…',
          style: TextStyle(
            color:      AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize:   13,
          ),
        ),
      ],
    );
  }
}
