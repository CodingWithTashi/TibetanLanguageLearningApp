import 'package:firebase_analytics/firebase_analytics.dart';

import '../core/interfaces/analytics_service.dart';

/// Firebase Analytics implementation
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService({
    FirebaseAnalytics? analytics,
  }) : _analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail - analytics should never break the app
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  @override
  Future<void> logPurchase({
    required String productId,
    required double value,
    required String currency,
  }) async {
    try {
      await _analytics.logPurchase(
        value: value,
        currency: currency,
        parameters: {
          'product_id': productId,
        },
      );
    } catch (e) {
      print('Analytics error: $e');
    }
  }

  /// Get Firebase Analytics observer for navigation tracking
  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
