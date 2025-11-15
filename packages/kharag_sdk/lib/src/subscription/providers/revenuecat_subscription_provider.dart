import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/interfaces/subscription_provider.dart';
import '../../core/models/result.dart';
import '../../core/models/subscription.dart';

/// RevenueCat implementation of subscription provider
class RevenueCatSubscriptionProvider implements SubscriptionProvider {
  final StreamController<SubscriptionStatus> _statusController =
      StreamController<SubscriptionStatus>.broadcast();

  bool _isInitialized = false;

  @override
  Future<Result<void>> initialize({
    required String apiKey,
    bool enableDebugLogs = false,
  }) async {
    if (_isInitialized) {
      return const Result.success(null);
    }

    try {
      final configuration = PurchasesConfiguration(apiKey);

      if (enableDebugLogs) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(configuration);

      // Listen to customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final status = _mapCustomerInfoToStatus(customerInfo);
        _statusController.add(status);
      });

      _isInitialized = true;
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: 'Failed to initialize RevenueCat: ${e.toString()}',
          code: 'initialization_failed',
        ),
      );
    }
  }

  @override
  Future<Result<SubscriptionOffering?>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null) {
        return const Result.success(null);
      }

      final packages = current.availablePackages
          .map((pkg) => _mapPackageToSubscriptionPackage(pkg))
          .toList();

      final offering = SubscriptionOffering(
        identifier: current.identifier,
        serverDescription: current.serverDescription,
        packages: packages,
        monthly: packages.firstWhere(
          (p) => p.period == SubscriptionPeriod.monthly,
          orElse: () => packages.first,
        ),
        yearly: packages.firstWhere(
          (p) => p.period == SubscriptionPeriod.yearly,
          orElse: () => packages.first,
        ),
      );

      return Result.success(offering);
    } on PlatformException catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.message ?? 'Failed to get offerings',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.toString(),
          code: ErrorCodes.subscriptionFailed,
        ),
      );
    }
  }

  @override
  Future<Result<SubscriptionStatus>> purchasePackage(
    SubscriptionPackage package,
  ) async {
    try {
      // Get the RevenueCat package by identifier
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null) {
        return const Result.failure(
          Failure.subscription(
            message: 'No offerings available',
            code: ErrorCodes.subscriptionNotAvailable,
          ),
        );
      }

      final rcPackage = current.availablePackages.firstWhere(
        (p) => p.identifier == package.identifier,
        orElse: () => throw Exception('Package not found'),
      );

      final customerInfo = await Purchases.purchasePackage(rcPackage);
      final status = _mapCustomerInfoToStatus(customerInfo);

      return Result.success(status);
    } on PlatformException catch (e) {
      if (e.code == 'purchaseCancelledError') {
        return Result.failure(
          Failure.cancelled(
            message: 'Purchase was cancelled',
          ),
        );
      }

      return Result.failure(
        Failure.subscription(
          message: e.message ?? 'Purchase failed',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.toString(),
          code: ErrorCodes.subscriptionFailed,
        ),
      );
    }
  }

  @override
  Future<Result<SubscriptionStatus>> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final status = _mapCustomerInfoToStatus(customerInfo);
      return Result.success(status);
    } on PlatformException catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.message ?? 'Failed to restore purchases',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.toString(),
          code: ErrorCodes.subscriptionFailed,
        ),
      );
    }
  }

  @override
  Future<Result<SubscriptionStatus>> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final status = _mapCustomerInfoToStatus(customerInfo);
      return Result.success(status);
    } on PlatformException catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.message ?? 'Failed to get subscription status',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.toString(),
          code: ErrorCodes.subscriptionFailed,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasActiveSubscription() async {
    final result = await getSubscriptionStatus();
    if (result is Success<SubscriptionStatus>) {
      return Result.success(result.data.isActive);
    }
    return const Result.success(false);
  }

  @override
  Stream<SubscriptionStatus> subscriptionStatusChanges() {
    return _statusController.stream;
  }

  @override
  Future<Result<String?>> getManagementUrl() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return Result.success(customerInfo.managementURL);
    } catch (e) {
      return Result.failure(
        Failure.subscription(
          message: e.toString(),
          code: ErrorCodes.subscriptionFailed,
        ),
      );
    }
  }

  /// Map RevenueCat Package to SubscriptionPackage
  SubscriptionPackage _mapPackageToSubscriptionPackage(Package package) {
    final product = package.storeProduct;
    final period = _mapPackageTypeToPeriod(package.packageType);

    return SubscriptionPackage(
      identifier: package.identifier,
      productId: product.identifier,
      title: product.title,
      description: product.description,
      priceString: product.priceString,
      price: product.price,
      currencyCode: product.currencyCode,
      introPrice: product.introductoryPrice?.price,
      introPriceString: product.introductoryPrice?.priceString,
      introDuration: product.introductoryPrice?.periodNumberOfUnits,
      introPeriod: product.introductoryPrice?.periodUnit.toString(),
      period: period,
      isFeatured: package.packageType == PackageType.monthly ||
          package.packageType == PackageType.annual,
    );
  }

  /// Map PackageType to SubscriptionPeriod
  SubscriptionPeriod _mapPackageTypeToPeriod(PackageType type) {
    switch (type) {
      case PackageType.monthly:
      case PackageType.threeMonth:
      case PackageType.sixMonth:
        return SubscriptionPeriod.monthly;
      case PackageType.annual:
        return SubscriptionPeriod.yearly;
      case PackageType.weekly:
        return SubscriptionPeriod.weekly;
      case PackageType.lifetime:
        return SubscriptionPeriod.lifetime;
      default:
        return SubscriptionPeriod.monthly;
    }
  }

  /// Map CustomerInfo to SubscriptionStatus
  SubscriptionStatus _mapCustomerInfoToStatus(CustomerInfo customerInfo) {
    final entitlements = customerInfo.entitlements.active;
    final isActive = entitlements.isNotEmpty;

    String? activeProductId;
    DateTime? expirationDate;
    DateTime? purchaseDate;
    bool isInTrial = false;

    if (isActive) {
      final activeEntitlement = entitlements.values.first;
      activeProductId = activeEntitlement.productIdentifier;
      expirationDate = activeEntitlement.expirationDate;
      purchaseDate = activeEntitlement.latestPurchaseDate;
      isInTrial = activeEntitlement.periodType == PeriodType.trial;
    }

    return SubscriptionStatus(
      isActive: isActive,
      isInTrialPeriod: isInTrial,
      activeProductId: activeProductId,
      expirationDate: expirationDate,
      purchaseDate: purchaseDate,
      managementUrl: customerInfo.managementURL,
    );
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
  }
}
