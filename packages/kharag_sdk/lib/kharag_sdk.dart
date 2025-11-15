/// Kharag SDK - Production-ready Flutter SDK for splash, onboarding,
/// authentication, subscriptions, and analytics.
library kharag_sdk;

// Core Models
export 'src/core/models/onboarding.dart';
export 'src/core/models/result.dart';
export 'src/core/models/sdk_config.dart';
export 'src/core/models/subscription.dart';
export 'src/core/models/user.dart';

// Core Interfaces
export 'src/core/interfaces/analytics_service.dart';
export 'src/core/interfaces/auth_provider.dart';
export 'src/core/interfaces/subscription_provider.dart';

// Core Constants
export 'src/core/constants/storage_keys.dart';

// Auth
export 'src/auth/providers/google_auth_provider.dart';
export 'src/auth/services/auth_service.dart';

// Subscription
export 'src/subscription/providers/revenuecat_subscription_provider.dart';

// Analytics
export 'src/analytics/firebase_analytics_service.dart';
export 'src/analytics/firebase_crashlytics_service.dart';

// Providers (Riverpod)
export 'src/core/providers/kharag_providers.dart';

// UI Components
export 'src/ui/splash/splash_screen.dart';
export 'src/ui/onboarding/onboarding_screen.dart';
export 'src/ui/login/login_screen.dart';
export 'src/ui/paywall/paywall_screen.dart';
export 'src/ui/about_us/about_us_screen.dart';

// External dependencies that users need
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:firebase_core/firebase_core.dart';
