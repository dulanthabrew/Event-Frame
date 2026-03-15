import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../app/providers/subscription_provider.dart';
import '../../../app/services/revenue_cat_service.dart';
import '../../../app/theme/app_theme.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfoAsync = ref.watch(customerInfoProvider);
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Current Plan Section ──────────────────────────────────────
            Text(
              'Current Plan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            customerInfoAsync.when(
              data: (info) {
                if (info == null || info.entitlements.active.isEmpty) {
                  return _CurrentPlanCard(
                    name: 'Free',
                    renewalDate: 'N/A',
                    price: '\$0',
                    status: 'No Active Plan',
                  );
                }
                final activeEntitlement = info.entitlements.active.values.first;
                return _CurrentPlanCard(
                  name: activeEntitlement.productIdentifier,
                  renewalDate: activeEntitlement.expirationDate ?? 'Lifetime',
                  price: 'Active',
                  status: activeEntitlement.isActive ? 'Active' : 'Expired',
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _CurrentPlanCard(
                name: 'Free',
                renewalDate: 'N/A',
                price: '\$0',
                status: 'Error loading',
              ),
            ),

            const SizedBox(height: 32),

            // ── Available Plans ───────────────────────────────────────────
            Text(
              'Available Plans',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            offeringsAsync.when(
              data: (offerings) {
                if (offerings == null ||
                    offerings.current == null ||
                    offerings.current!.availablePackages.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No subscription plans available.\nPlease configure offerings in RevenueCat.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: offerings.current!.availablePackages
                      .map((package) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PackageTile(package: package),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading plans: $e'),
            ),

            const SizedBox(height: 24),

            // ── Restore Purchases ────────────────────────────────────────
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    await RevenueCatService.restorePurchases();
                    ref.invalidate(customerInfoProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Purchases restored successfully!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore Purchases'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Current Plan Card ──────────────────────────────────────────────────────
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
                Expanded(
                  child: Column(
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
                        'Renewal: $renewalDate',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
            const SizedBox(height: 16),
            Text(
              price,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Package / Plan Tile ────────────────────────────────────────────────────
class _PackageTile extends ConsumerWidget {
  final Package package;

  const _PackageTile({required this.package});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = package.storeProduct;

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
                    product.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () => _purchase(context, ref),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    try {
      await RevenueCatService.purchasePackage(package);
      ref.invalidate(customerInfoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }
}
