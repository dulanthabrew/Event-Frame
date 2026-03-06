import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Section
            Text(
              'Current Plan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _CurrentPlanCard(
              name: 'Pro Tier',
              renewalDate: 'April 20, 2026',
              price: '\$49/mo',
              status: 'Active',
            ),
            const SizedBox(height: 32),

            // Upgrade Options
            Text(
              'Change Plan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _PlanSelectionTile(
              name: 'Basic',
              price: '\$19/mo',
              features: '25 events, 500 photos/event',
              isSelected: false,
            ),
            const SizedBox(height: 12),
            _PlanSelectionTile(
              name: 'Enterprise',
              price: 'Custom',
              features: 'White-labeling, Custom Domain, Multi-user',
              isSelected: false,
            ),

            const SizedBox(height: 48),

            // Billing History (Mock)
            Text(
              'Billing History',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _BillingHistoryItem(
                date: 'Mar 20, 2026', amount: '\$49.00', status: 'Paid'),
            _BillingHistoryItem(
                date: 'Feb 20, 2026', amount: '\$49.00', status: 'Paid'),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final String name;
  final String renewalDate;
  final String price;
  final String status;

  const _CurrentPlanCard({
    required this.name,
    required this.renewalDate,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Next renewal: $renewalDate',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                  ),
                  child: const Text('Manage Billing'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSelectionTile extends StatelessWidget {
  final String name;
  final String price;
  final String features;
  final bool isSelected;

  const _PlanSelectionTile({
    required this.name,
    required this.price,
    required this.features,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_outline_rounded,
                  color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    features,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingHistoryItem extends StatelessWidget {
  final String date;
  final String amount;
  final String status;

  const _BillingHistoryItem({
    required this.date,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: GoogleFonts.inter(fontSize: 14)),
          Row(
            children: [
              Text(amount,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: AppTheme.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
