import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

class ClientManagementPage extends ConsumerWidget {
  final String eventId;
  const ClientManagementPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () {
              // TODO: Add new client to event
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Event Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event: Smith Wedding 2026',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '24 Clients linked to this event',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Client List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final names = [
                  'Amara Silva',
                  'Roshan Perera',
                  'Nadeeka Fernando',
                  'Kasun Rajapaksa',
                  'Dilini Jayawardena',
                ];
                return _ClientListItem(
                  name: names[index],
                  email:
                      '${names[index].toLowerCase().replaceAll(' ', '.')}@gmail.com',
                  isDelivered: index % 2 == 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientListItem extends StatelessWidget {
  final String name;
  final String email;
  final bool isDelivered;

  const _ClientListItem({
    required this.name,
    required this.email,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(
            name[0],
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(email),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isDelivered ? AppTheme.success : AppTheme.warning)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isDelivered ? 'DELIVERED' : 'PENDING',
            style: GoogleFonts.inter(
              color: isDelivered ? AppTheme.success : AppTheme.warning,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
