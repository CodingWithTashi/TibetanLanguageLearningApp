import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import '../config/app_config.dart';

/// Wrapper for the paywall screen
class PaywallWrapper extends ConsumerWidget {
  const PaywallWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KharagPaywallScreen(
      config: AppConfig.paywallConfig,
      onPurchaseSuccess: (status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful! Thank you for subscribing.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      },
      onPurchaseError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
      onRestoreSuccess: (status) {
        final message = status.isActive
            ? 'Purchases restored successfully!'
            : 'No active purchases found.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: status.isActive ? Colors.green : Colors.orange,
          ),
        );

        if (status.isActive) {
          Navigator.pop(context);
        }
      },
      onClose: () {
        Navigator.pop(context);
      },
    );
  }
}
