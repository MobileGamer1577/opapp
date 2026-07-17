// ═══════════════════════════════════════════════════════════════
//  service_status_screen.dart – "Dienstverfügbarkeit"-Screen
//
//  ✅ HIER ÄNDERN: Kartendesign; Endpunkte selbst liegen in
//                  service_status_repository.dart
//  ❌ NICHT ÄNDERN: serviceStatusProvider-Aufruf
//
//  Zeigt für jede von der App genutzte API (OPSUCHT, mc-api.io, das
//  eigene opapp-shards-api Backend) den Live-Status: Online (mit
//  Ping in ms) oder Offline. Rein informativ – hat keinen Einfluss
//  auf die restliche App, falls einzelne Dienste gerade down sind.
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../data/repositories/service_status_repository.dart';
import '../data/models/service_status.dart';
import '../widgets/app_background.dart';

class ServiceStatusScreen extends ConsumerWidget {
  const ServiceStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(serviceStatusProvider);
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Dienstverfügbarkeit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(serviceStatusProvider),
            ),
          ],
        ),
        body: statusAsync.when(
          data: (groups) => RefreshIndicator(
            onRefresh: () => ref.refresh(serviceStatusProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final group in groups) ...[
                  _GroupLabel(group.label),
                  const SizedBox(height: 10),
                  for (final service in group.services) ...[
                    _ServiceCard(result: service),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(e.toString(), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(serviceStatusProvider),
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
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

class _ServiceCard extends StatelessWidget {
  final ServiceCheckResult result;
  const _ServiceCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.isOnline ? AppColors.success : AppColors.error;

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
                Text(result.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _shortenUrl(result.url),
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.isOnline ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                result.isOnline ? 'Online (${result.pingMs}ms)' : 'Offline',
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
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
