import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../data/event_repository.dart';

class PhotographerDashboardPage extends ConsumerWidget {
  const PhotographerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(photographerEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photographer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.go('/photographer/subscription'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Welcome Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hey, Photographer! 👋',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Lumina Studio • Pro Plan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/photographer/events/new'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Event'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stat Cards
          eventsAsync.when(
            data: (events) => Row(
              children: [
                Expanded(
                  child: _SmallStatCard(
                    title: 'Events',
                    value: events.length.toString(),
                    icon: Icons.event_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SmallStatCard(
                    title: 'Photos',
                    value: events
                        .fold<int>(0, (sum, e) => sum + e.photoCount)
                        .toString(),
                    icon: Icons.cloud_done_rounded,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),

          // Recent Events Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Events',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/photographer/events'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Event List
          eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_rounded,
                            size: 48, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('No events created yet.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: events.take(5).map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventDashboardCard(
                      name: event.name,
                      code: event.code,
                      date:
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                      clientCount: event.clientCount,
                      photoCount: event.photoCount,
                      onTap: () =>
                          context.go('/photographer/events/${event.id}/upload'),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDashboardCard extends StatelessWidget {
  final String name;
  final String code;
  final String date;
  final int clientCount;
  final int photoCount;
  final VoidCallback onTap;

  const _EventDashboardCard({
    required this.name,
    required this.code,
    required this.date,
    required this.clientCount,
    required this.photoCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.photo_album_rounded, color: Colors.white),
        ),
        title: Text(
          name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('$clientCount clients • $photoCount photos'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: GoogleFonts.inter(fontSize: 10),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
