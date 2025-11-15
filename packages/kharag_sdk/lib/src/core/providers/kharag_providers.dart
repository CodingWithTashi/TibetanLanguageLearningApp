import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../analytics/firebase_analytics_service.dart';
import '../../analytics/firebase_crashlytics_service.dart';
import '../../auth/providers/google_auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../subscription/providers/revenuecat_subscription_provider.dart';
import '../interfaces/analytics_service.dart';
import '../interfaces/analytics_service.dart' as analytics;
import '../models/sdk_config.dart';
import '../models/user.dart';

/// Provider for SDK configuration
final sdkConfigProvider = StateProvider<KharagSdkConfig?>((ref) => null);

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

/// Provider for Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

/// Provider for Crashlytics Service
final crashlyticsServiceProvider = Provider<analytics.CrashlyticsService>((ref) {
  return FirebaseCrashlyticsService();
});

/// Provider for Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService();

  // Register Google Auth Provider
  final googleAuthProvider = KharagGoogleAuthProvider();
  service.registerProvider(googleAuthProvider);

  return service;
});

/// Provider for current authenticated user
final currentUserProvider = StreamProvider<KharagUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for authentication state (boolean)
final isAuthenticatedProvider = FutureProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated();
});

/// Provider for RevenueCat Subscription Service
final subscriptionServiceProvider =
    Provider<RevenueCatSubscriptionProvider>((ref) {
  return RevenueCatSubscriptionProvider();
});

/// Provider for onboarding completion status
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool('kharag_onboarding_completed') ?? false;
});

/// Provider to save onboarding status
final saveOnboardingStatusProvider =
    FutureProvider.family<void, bool>((ref, completed) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  await prefs.setBool('kharag_onboarding_completed', completed);
  // Invalidate the hasCompletedOnboardingProvider to refresh
  ref.invalidate(hasCompletedOnboardingProvider);
});
