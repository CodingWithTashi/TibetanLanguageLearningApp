import 'package:flutter/widgets.dart';

/// Configuration for initializing the Kharag SDK
class KharagSdkConfig {
  /// RevenueCat API key for iOS
  final String? revenueCatIosApiKey;

  /// RevenueCat API key for Android
  final String? revenueCatAndroidApiKey;

  /// Enable debug logging
  final bool enableDebugLogs;

  /// Enable Firebase Analytics
  final bool enableAnalytics;

  /// Enable Firebase Crashlytics
  final bool enableCrashlytics;

  /// Custom splash screen duration in milliseconds
  final int splashDuration;

  /// Whether onboarding has been completed (read from storage)
  /// This will be managed internally by the SDK
  final bool Function()? hasCompletedOnboarding;

  /// Save onboarding completion status
  final Future<void> Function(bool completed)? saveOnboardingStatus;

  const KharagSdkConfig({
    this.revenueCatIosApiKey,
    this.revenueCatAndroidApiKey,
    this.enableDebugLogs = false,
    this.enableAnalytics = true,
    this.enableCrashlytics = true,
    this.splashDuration = 2000,
    this.hasCompletedOnboarding,
    this.saveOnboardingStatus,
  });
}

/// Splash screen configuration
class SplashConfig {
  /// Logo widget to display
  final Widget logo;

  /// Optional loading indicator
  final Widget? loadingIndicator;

  /// Background color (if not using theme)
  final Color? backgroundColor;

  /// Animation duration in milliseconds
  final int animationDuration;

  /// Minimum display duration in milliseconds
  final int minDisplayDuration;

  const SplashConfig({
    required this.logo,
    this.loadingIndicator,
    this.backgroundColor,
    this.animationDuration = 1000,
    this.minDisplayDuration = 2000,
  });
}

/// About Us page configuration
class AboutUsConfig {
  /// App name
  final String appName;

  /// App description
  final String description;

  /// App version
  final String version;

  /// App logo
  final Widget? logo;

  /// Privacy policy URL
  final String? privacyPolicyUrl;

  /// Terms of service URL
  final String? termsOfServiceUrl;

  /// Support email
  final String? supportEmail;

  /// Website URL
  final String? websiteUrl;

  /// Additional markdown content
  final String? additionalContent;

  /// Social media links
  final Map<String, String>? socialLinks;

  const AboutUsConfig({
    required this.appName,
    required this.description,
    required this.version,
    this.logo,
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
    this.supportEmail,
    this.websiteUrl,
    this.additionalContent,
    this.socialLinks,
  });
}
