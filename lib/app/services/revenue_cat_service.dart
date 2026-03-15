import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat service for managing in-app subscriptions.
/// Only works on Android/iOS — gracefully skips on web/desktop.
class RevenueCatService {
  static bool _isSupported = false;

  // TODO: Replace with your RevenueCat API keys
  static const String _androidApiKey = 'test_yrufOUBCfHEyJRehyBMvVSVdVmH';
  static const String _iosApiKey = 'test_yrufOUBCfHEyJRehyBMvVSVdVmH';

  /// Initialize RevenueCat SDK.
  static Future<void> initialize() async {
    // Skip on web/desktop — RevenueCat only supports Android/iOS
    if (kIsWeb) {
      debugPrint('RevenueCat: Web platform detected, skipping initialization');
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint('RevenueCat: Platform not supported, skipping initialization');
      return;
    }

    await Purchases.setLogLevel(LogLevel.debug);

    late PurchasesConfiguration configuration;
    if (defaultTargetPlatform == TargetPlatform.android) {
      configuration = PurchasesConfiguration(_androidApiKey);
    } else {
      configuration = PurchasesConfiguration(_iosApiKey);
    }

    await Purchases.configure(configuration);
    _isSupported = true;
    debugPrint('RevenueCat: Initialized successfully');
  }

  /// Login the user to RevenueCat (sync with Supabase user ID).
  static Future<void> login(String userId) async {
    if (!_isSupported) return;
    try {
      await Purchases.logIn(userId);
      debugPrint('RevenueCat: Logged in user $userId');
    } catch (e) {
      debugPrint('RevenueCat: Login error — $e');
    }
  }

  /// Logout from RevenueCat.
  static Future<void> logout() async {
    if (!_isSupported) return;
    try {
      await Purchases.logOut();
      debugPrint('RevenueCat: Logged out');
    } catch (e) {
      debugPrint('RevenueCat: Logout error — $e');
    }
  }

  /// Get current customer info (subscription status, entitlements).
  static Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isSupported) return null;
    return await Purchases.getCustomerInfo();
  }

  /// Get available subscription offerings.
  static Future<Offerings?> getOfferings() async {
    if (!_isSupported) return null;
    return await Purchases.getOfferings();
  }

  /// Purchase a specific package.
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isSupported) return null;
    return await Purchases.purchasePackage(package);
  }

  /// Restore previous purchases (e.g., after reinstall).
  static Future<CustomerInfo?> restorePurchases() async {
    if (!_isSupported) return null;
    return await Purchases.restorePurchases();
  }

  /// Check if user has an active "pro" entitlement.
  static Future<bool> isProUser() async {
    if (!_isSupported) return false;
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey('pro');
  }
}
