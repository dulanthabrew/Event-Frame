import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

class MembershipMgmtPage extends ConsumerWidget {
  const MembershipMgmtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: Add new plan
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Define Subscription Tiers',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize features, limitations, and pricing for photographers.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          _PlanEditCard(
            name: 'Free',
            price: '\$0/mo',
            features: [
              '5 Active Events',
              '100 Photos/Event',
              'Basic Watermarking',
              '1.5 GB Storage (App-side)',
            ],
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          _PlanEditCard(
            name: 'Basic',
            price: '\$19/mo',
            features: [
              '25 Active Events',
              '500 Photos/Event',
              'Custom Watermarking',
              'QR Code Gallery Access',
              '5 GB Storage (App-side)',
            ],
            color: AppTheme.success,
          ),
          const SizedBox(height: 20),
          _PlanEditCard(
            name: 'Pro',
            price: '\$49/mo',
            features: [
              'Unlimited Events',
              'Unlimited Photos',
              'High-Res Photo Delivery',
              'Google Drive Auto-sync',
              'Priority Support',
            ],
            color: AppTheme.primary,
            isPro: true,
          ),
        ],
      ),
    );
  }
}

class _PlanEditCard extends StatelessWidget {
  final String name;
  final String price;
  final List<String> features;
  final Color color;
  final bool isPro;

  const _PlanEditCard({
    required this.name,
    required this.price,
    required this.features,
    required this.color,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppTheme.success),
                    const SizedBox(width: 10),
                    Text(f, style: GoogleFonts.inter(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Edit plan details
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Plan Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
