import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kharag_sdk/kharag_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Wrapper for the onboarding screen
class OnboardingWrapper extends ConsumerWidget {
  const OnboardingWrapper({super.key});

  Future<void> _handleOnboardingComplete(WidgetRef ref) async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kharag_onboarding_completed', true);

    // Log analytics event
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(name: AnalyticsEvents.onboardingCompleted);

    // Invalidate the provider to trigger rebuild
    ref.invalidate(hasCompletedOnboardingProvider);
  }

  Future<void> _handleOnboardingSkipped(WidgetRef ref) async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kharag_onboarding_completed', true);

    // Log analytics event
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent(name: AnalyticsEvents.onboardingSkipped);

    // Invalidate the provider to trigger rebuild
    ref.invalidate(hasCompletedOnboardingProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KharagOnboardingScreen(
      config: AppConfig.onboardingConfig,
      onComplete: () => _handleOnboardingComplete(ref),
      onSkip: () => _handleOnboardingSkipped(ref),
    );
  }
}
