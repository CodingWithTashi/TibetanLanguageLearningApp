import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

import '../config/app_config.dart';
import 'home_screen.dart';
import 'onboarding_wrapper.dart';
import 'login_wrapper.dart';

/// Main navigation widget that determines which screen to show
class AppNavigation extends ConsumerWidget {
  const AppNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch onboarding completion status
    final onboardingAsync = ref.watch(hasCompletedOnboardingProvider);

    // Watch authentication status
    final userAsync = ref.watch(currentUserProvider);

    return onboardingAsync.when(
      data: (hasCompletedOnboarding) {
        // If onboarding not completed, show onboarding
        if (!hasCompletedOnboarding) {
          return const OnboardingWrapper();
        }

        // Check authentication status
        return userAsync.when(
          data: (user) {
            // If user is authenticated, show home screen
            if (user != null) {
              return const HomeScreen();
            }

            // If not authenticated, show login screen
            return const LoginWrapper();
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(currentUserProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(hasCompletedOnboardingProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
