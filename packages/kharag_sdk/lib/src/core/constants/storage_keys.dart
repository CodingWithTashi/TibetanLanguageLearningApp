/// Storage keys used by the SDK
class StorageKeys {
  StorageKeys._();

  /// Key for storing onboarding completion status
  static const String onboardingCompleted = 'kharag_onboarding_completed';

  /// Key for storing user preferences
  static const String userPreferences = 'kharag_user_preferences';

  /// Key for storing auth provider type
  static const String authProviderType = 'kharag_auth_provider_type';

  /// Key for storing last login timestamp
  static const String lastLoginTimestamp = 'kharag_last_login_timestamp';
}

/// Analytics event names
class AnalyticsEvents {
  AnalyticsEvents._();

  // Onboarding events
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  // Auth events
  static const String loginStarted = 'login_started';
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';
  static const String logoutSuccess = 'logout_success';

  // Subscription events
  static const String paywallViewed = 'paywall_viewed';
  static const String purchaseStarted = 'purchase_started';
  static const String purchaseSuccess = 'purchase_success';
  static const String purchaseFailed = 'purchase_failed';
  static const String purchaseCancelled = 'purchase_cancelled';
  static const String restorePurchasesStarted = 'restore_purchases_started';
  static const String restorePurchasesSuccess = 'restore_purchases_success';
  static const String restorePurchasesFailed = 'restore_purchases_failed';

  // Screen views
  static const String splashScreenViewed = 'splash_screen_viewed';
  static const String onboardingScreenViewed = 'onboarding_screen_viewed';
  static const String loginScreenViewed = 'login_screen_viewed';
  static const String paywallScreenViewed = 'paywall_screen_viewed';
  static const String aboutUsScreenViewed = 'about_us_screen_viewed';
}

/// Error codes
class ErrorCodes {
  ErrorCodes._();

  // Auth errors
  static const String authCancelled = 'auth_cancelled';
  static const String authFailed = 'auth_failed';
  static const String authNetworkError = 'auth_network_error';
  static const String authInvalidCredentials = 'auth_invalid_credentials';
  static const String authUserNotFound = 'auth_user_not_found';
  static const String authProviderNotAvailable = 'auth_provider_not_available';

  // Subscription errors
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String subscriptionFailed = 'subscription_failed';
  static const String subscriptionNetworkError = 'subscription_network_error';
  static const String subscriptionNotAvailable = 'subscription_not_available';
  static const String subscriptionAlreadyOwned = 'subscription_already_owned';

  // General errors
  static const String networkError = 'network_error';
  static const String unknownError = 'unknown_error';
}
