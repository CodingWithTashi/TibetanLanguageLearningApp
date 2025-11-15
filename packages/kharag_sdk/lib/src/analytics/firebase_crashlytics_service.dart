import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../core/interfaces/analytics_service.dart';

/// Firebase Crashlytics implementation
class FirebaseCrashlyticsService implements CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashlyticsService({
    FirebaseCrashlytics? crashlytics,
  }) : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  /// Initialize Crashlytics with Flutter error handling
  Future<void> initialize() async {
    // Pass all uncaught errors from the framework to Crashlytics
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      _crashlytics.log(message);
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }

  @override
  void crash() {
    _crashlytics.crash();
  }

  @override
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      print('Crashlytics error: $e');
    }
  }
}
