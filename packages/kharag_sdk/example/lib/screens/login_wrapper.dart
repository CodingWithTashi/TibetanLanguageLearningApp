import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import '../config/app_config.dart';

/// Wrapper for the login screen
class LoginWrapper extends ConsumerWidget {
  const LoginWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KharagLoginScreen(
      config: AppConfig.loginConfig,
      onLoginSuccess: (user) {
        // Navigation handled automatically by watching auth state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${user.displayName ?? user.email}!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onLoginError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
