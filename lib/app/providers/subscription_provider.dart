import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenue_cat_service.dart';

/// Provider for the current customer's subscription info.
final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  try {
    return await RevenueCatService.getCustomerInfo();
  } catch (e) {
    debugPrint('ERROR: Failed to get customer info — $e');
    return null;
  }
});

/// Provider for checking if user has pro access.
final isProUserProvider = FutureProvider<bool>((ref) async {
  try {
    return await RevenueCatService.isProUser();
  } catch (e) {
    return false;
  }
});

/// Provider for available subscription offerings.
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  try {
    return await RevenueCatService.getOfferings();
  } catch (e) {
    debugPrint('ERROR: Failed to get offerings — $e');
    return null;
  }
});

/// Provider for the current active entitlements.
final activeEntitlementsProvider =
    FutureProvider<Map<String, EntitlementInfo>>((ref) async {
  final customerInfo = await ref.watch(customerInfoProvider.future);
  return customerInfo?.entitlements.active ?? {};
});
