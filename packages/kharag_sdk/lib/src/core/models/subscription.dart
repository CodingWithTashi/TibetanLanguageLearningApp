import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Represents a subscription package/product
@freezed
class SubscriptionPackage with _$SubscriptionPackage {
  const factory SubscriptionPackage({
    required String identifier,
    required String productId,
    required String title,
    required String description,
    required String priceString,
    required double price,
    required String currencyCode,
    String? introPrice,
    String? introPriceString,
    int? introDuration,
    String? introPeriod,
    required SubscriptionPeriod period,
    required bool isFeatured,
  }) = _SubscriptionPackage;

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPackageFromJson(json);
}

/// Subscription period types
enum SubscriptionPeriod {
  monthly,
  yearly,
  weekly,
  lifetime,
}

/// Current subscription status
@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required bool isActive,
    required bool isInTrialPeriod,
    String? activeProductId,
    DateTime? expirationDate,
    DateTime? purchaseDate,
    String? managementUrl,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);
}

/// Subscription offering (collection of packages)
@freezed
class SubscriptionOffering with _$SubscriptionOffering {
  const factory SubscriptionOffering({
    required String identifier,
    required String serverDescription,
    required List<SubscriptionPackage> packages,
    SubscriptionPackage? monthly,
    SubscriptionPackage? yearly,
  }) = _SubscriptionOffering;

  factory SubscriptionOffering.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionOfferingFromJson(json);
}
