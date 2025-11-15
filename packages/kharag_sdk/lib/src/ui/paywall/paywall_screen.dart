import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/models/result.dart';
import '../../core/models/subscription.dart';
import '../../core/providers/kharag_providers.dart';

/// Paywall configuration
class PaywallConfig {
  /// Title text
  final String title;

  /// Subtitle text
  final String subtitle;

  /// List of features to display
  final List<String> features;

  /// Purchase button text
  final String purchaseButtonText;

  /// Restore purchases button text
  final String restorePurchasesText;

  /// Terms of service URL
  final String? termsUrl;

  /// Privacy policy URL
  final String? privacyUrl;

  /// Close button visibility
  final bool showCloseButton;

  const PaywallConfig({
    this.title = 'Unlock Premium',
    this.subtitle = 'Get unlimited access to all features',
    this.features = const [],
    this.purchaseButtonText = 'Continue',
    this.restorePurchasesText = 'Restore Purchases',
    this.termsUrl,
    this.privacyUrl,
    this.showCloseButton = true,
  });
}

/// Paywall screen for subscription purchases
class KharagPaywallScreen extends ConsumerStatefulWidget {
  /// Paywall configuration
  final PaywallConfig config;

  /// Callback when purchase is successful
  final void Function(SubscriptionStatus status)? onPurchaseSuccess;

  /// Callback when purchase fails
  final void Function(String error)? onPurchaseError;

  /// Callback when restore is successful
  final void Function(SubscriptionStatus status)? onRestoreSuccess;

  /// Callback when close button is pressed
  final VoidCallback? onClose;

  const KharagPaywallScreen({
    required this.config,
    this.onPurchaseSuccess,
    this.onPurchaseError,
    this.onRestoreSuccess,
    this.onClose,
    super.key,
  });

  @override
  ConsumerState<KharagPaywallScreen> createState() =>
      _KharagPaywallScreenState();
}

class _KharagPaywallScreenState extends ConsumerState<KharagPaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  bool _isRestoring = false;
  SubscriptionOffering? _offering;
  SubscriptionPackage? _selectedPackage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final subscriptionService = ref.read(subscriptionServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    await analyticsService.logEvent(
      name: AnalyticsEvents.paywallViewed,
    );

    final result = await subscriptionService.getOfferings();

    if (!mounted) return;

    result.when(
      success: (offering) {
        setState(() {
          _offering = offering;
          _selectedPackage = offering?.monthly ?? offering?.packages.first;
          _isLoading = false;
        });
      },
      failure: (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isPurchasing = true;
    });

    final subscriptionService = ref.read(subscriptionServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    await analyticsService.logEvent(
      name: AnalyticsEvents.purchaseStarted,
      parameters: {
        'product_id': _selectedPackage!.productId,
        'price': _selectedPackage!.price,
      },
    );

    final result = await subscriptionService.purchasePackage(_selectedPackage!);

    if (!mounted) return;

    setState(() {
      _isPurchasing = false;
    });

    result.when(
      success: (status) async {
        await analyticsService.logPurchase(
          productId: _selectedPackage!.productId,
          value: _selectedPackage!.price,
          currency: _selectedPackage!.currencyCode,
        );

        await analyticsService.logEvent(
          name: AnalyticsEvents.purchaseSuccess,
          parameters: {
            'product_id': _selectedPackage!.productId,
          },
        );

        if (widget.onPurchaseSuccess != null) {
          widget.onPurchaseSuccess!(status);
        }
      },
      failure: (failure) async {
        final eventName = failure is CancelledFailure
            ? AnalyticsEvents.purchaseCancelled
            : AnalyticsEvents.purchaseFailed;

        await analyticsService.logEvent(
          name: eventName,
          parameters: {
            'error': failure.message,
          },
        );

        if (failure is! CancelledFailure) {
          if (widget.onPurchaseError != null) {
            widget.onPurchaseError!(failure.message);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
      },
    );
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isRestoring = true;
    });

    final subscriptionService = ref.read(subscriptionServiceProvider);
    final analyticsService = ref.read(analyticsServiceProvider);

    await analyticsService.logEvent(
      name: AnalyticsEvents.restorePurchasesStarted,
    );

    final result = await subscriptionService.restorePurchases();

    if (!mounted) return;

    setState(() {
      _isRestoring = false;
    });

    result.when(
      success: (status) async {
        await analyticsService.logEvent(
          name: AnalyticsEvents.restorePurchasesSuccess,
        );

        if (widget.onRestoreSuccess != null) {
          widget.onRestoreSuccess!(status);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  status.isActive
                      ? 'Purchases restored successfully!'
                      : 'No purchases found to restore',
                ),
              ),
            );
          }
        }
      },
      failure: (failure) async {
        await analyticsService.logEvent(
          name: AnalyticsEvents.restorePurchasesFailed,
          parameters: {'error': failure.message},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.config.showCloseButton
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose ?? () => Navigator.pop(context),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _ErrorView(
                  message: _errorMessage!,
                  onRetry: _loadOfferings,
                )
              : _PaywallContent(
                  config: widget.config,
                  offering: _offering,
                  selectedPackage: _selectedPackage,
                  onPackageSelected: (package) {
                    setState(() {
                      _selectedPackage = package;
                    });
                  },
                  isPurchasing: _isPurchasing,
                  isRestoring: _isRestoring,
                  onPurchase: _handlePurchase,
                  onRestore: _handleRestore,
                ),
    );
  }
}

/// Paywall content widget
class _PaywallContent extends StatelessWidget {
  final PaywallConfig config;
  final SubscriptionOffering? offering;
  final SubscriptionPackage? selectedPackage;
  final void Function(SubscriptionPackage) onPackageSelected;
  final bool isPurchasing;
  final bool isRestoring;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;

  const _PaywallContent({
    required this.config,
    required this.offering,
    required this.selectedPackage,
    required this.onPackageSelected,
    required this.isPurchasing,
    required this.isRestoring,
    required this.onPurchase,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    config.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    config.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features
                  if (config.features.isNotEmpty) ...[
                    ...config.features.map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Package options
                  if (offering != null && offering!.packages.isNotEmpty) ...[
                    ...offering!.packages.map((package) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _PackageCard(
                            package: package,
                            isSelected: selectedPackage == package,
                            onTap: () => onPackageSelected(package),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Purchase button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isPurchasing || isRestoring ? null : onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isPurchasing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            config.purchaseButtonText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Restore purchases button
                TextButton(
                  onPressed: isPurchasing || isRestoring ? null : onRestore,
                  child: isRestoring
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(config.restorePurchasesText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Package selection card
class _PackageCard extends StatelessWidget {
  final SubscriptionPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio button
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),

            const SizedBox(width: 12),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (package.introPriceString != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Free trial: ${package.introPriceString}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price
            Text(
              package.priceString,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
