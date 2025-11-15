/// Abstract interface for analytics services
abstract class AnalyticsService {
  /// Log an event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Set user ID
  Future<void> setUserId(String? userId);

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  /// Log login event
  Future<void> logLogin(String method);

  /// Log sign up event
  Future<void> logSignUp(String method);

  /// Log purchase event
  Future<void> logPurchase({
    required String productId,
    required double value,
    required String currency,
  });
}

/// Abstract interface for crashlytics services
abstract class CrashlyticsService {
  /// Record an error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  });

  /// Log a message
  Future<void> log(String message);

  /// Set user identifier
  Future<void> setUserIdentifier(String identifier);

  /// Set custom key
  Future<void> setCustomKey(String key, dynamic value);

  /// Force a crash (for testing)
  void crash();

  /// Check if crashlytics is enabled
  Future<bool> isCrashlyticsCollectionEnabled();

  /// Enable/disable crashlytics
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}
