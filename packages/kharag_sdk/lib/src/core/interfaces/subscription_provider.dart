import '../models/result.dart';
import '../models/subscription.dart';

/// Abstract interface for subscription providers
/// This allows for easy switching between RevenueCat, Stripe, or custom implementations
abstract class SubscriptionProvider {
  /// Initialize the subscription provider
  Future<Result<void>> initialize({
    required String apiKey,
    bool enableDebugLogs = false,
  });

  /// Get available subscription offerings
  Future<Result<SubscriptionOffering?>> getOfferings();

  /// Purchase a subscription package
  Future<Result<SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  );

  /// Restore previous purchases
  Future<Result<SubscriptionStatus>> restorePurchases();

  /// Get current subscription status
  Future<Result<SubscriptionStatus>> getSubscriptionStatus();

  /// Check if user has active subscription
  Future<Result<bool>> hasActiveSubscription();

  /// Stream of subscription status changes
  Stream<SubscriptionStatus> subscriptionStatusChanges();

  /// Get customer info/management URL
  Future<Result<String?>> getManagementUrl();
}
