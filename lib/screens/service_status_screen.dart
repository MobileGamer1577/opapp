// ═══════════════════════════════════════════════════════════════
//  service_status_screen.dart – "Dienstverfügbarkeit"-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign; Endpunkte selbst liegen in
//                  service_status_repository.dart
//  ❌ NICHT ÄNDERN: serviceCheckProvider-Aufruf
//
//  Zeigt für jede von der App genutzte API (OPSUCHT, mc-api.io, das
//  eigene opapp-shards-api Backend) den Live-Status: Online (mit
//  Ping in ms) oder Offline. Rein informativ – hat keinen Einfluss
//  auf die restliche App, falls einzelne Dienste gerade down sind.
//
//  ÄNDERUNGEN (Progressiv-Update):
//    - Die Liste aller Karten steht SOFORT (endpointGroups ist
//      synchron bekannt) – kein Warten auf einen einzigen großen
//      Request mehr. Jede Karte (_ServiceCard) beobachtet ihren
//      EIGENEN serviceCheckProvider(endpoint) und zeigt individuell
//      "Wird überprüft…" → Online/Offline, sobald ihr Request fertig
//      ist, unabhängig von den anderen Karten.
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
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Dienstverfügbarkeit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              // Ohne Argument → invalidiert ALLE aktuell beobachteten
              // Endpunkt-Provider auf einmal.
              onPressed: () => ref.invalidate(serviceCheckProvider),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => ref.invalidate(serviceCheckProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final group in endpointGroups) ...[
                _GroupLabel(group.key),
                const SizedBox(height: 10),
                for (final endpoint in group.value) ...[
                  _ServiceCard(endpoint: endpoint),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 14),
              ],
            ],
          ),
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
// ConsumerWidget – beobachtet ihren EIGENEN Endpunkt-Provider, damit
// jede Karte unabhängig von den anderen lädt/aktualisiert.

class _ServiceCard extends ConsumerWidget {
  final ServiceEndpoint endpoint;
  const _ServiceCard({required this.endpoint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final checkAsync = ref.watch(serviceCheckProvider(endpoint));

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
                Text(endpoint.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _shortenUrl(endpoint.url),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          checkAsync.when(
            data: (result) => _StatusChip(
              online: result.isOnline,
              label: result.isOnline ? 'Online (${result.pingMs}ms)' : 'Offline',
            ),
            loading: () => const _CheckingChip(),
            // Ein Fehler im Provider selbst (sollte durch das try/catch
            // im Repository eigentlich nie passieren) wird sicherheits-
            // halber wie "Offline" behandelt statt eines Krachs im UI.
            error: (_, __) => const _StatusChip(online: false, label: 'Offline'),
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
