import 'package:flutter/material.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

/// Application configuration for the example app
class AppConfig {
  AppConfig._();

  // RevenueCat API Keys
  // NOTE: Replace with your actual keys for production
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY_HERE';

  // Splash Screen Configuration
  static final splashConfig = SplashConfig(
    logo: Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF6750A4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.rocket_launch,
        size: 64,
        color: Colors.white,
      ),
    ),
    loadingIndicator: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
    ),
    animationDuration: 1000,
    minDisplayDuration: 2000,
  );

  // Onboarding Configuration
  static final onboardingConfig = OnboardingConfig(
    pages: [
      OnboardingPage(
        title: 'Welcome to Kharag SDK',
        description:
            'A production-ready SDK with authentication, subscriptions, and analytics built-in.',
        image: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.waving_hand,
            size: 100,
            color: Color(0xFF6750A4),
          ),
        ),
      ),
      OnboardingPage(
        title: 'Seamless Authentication',
        description:
            'Sign in quickly and securely with Google Sign-In integration.',
        image: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.security,
            size: 100,
            color: Color(0xFF6750A4),
          ),
        ),
      ),
      OnboardingPage(
        title: 'Premium Features',
        description:
            'Unlock unlimited access with our flexible subscription plans.',
        image: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            size: 100,
            color: Color(0xFF6750A4),
          ),
        ),
      ),
      OnboardingPage(
        title: 'Ready to Start?',
        description:
            'Let\'s get you set up and explore all the amazing features!',
        image: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF6750A4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 100,
            color: Color(0xFF6750A4),
          ),
        ),
      ),
    ],
    showSkipButton: true,
    skipButtonText: 'Skip',
    nextButtonText: 'Next',
    doneButtonText: 'Get Started',
  );

  // Login Configuration
  static const loginConfig = LoginConfig(
    title: 'Welcome Back',
    subtitle: 'Sign in to access your account',
    googleButtonText: 'Sign in with Google',
  );

  // Paywall Configuration
  static const paywallConfig = PaywallConfig(
    title: 'Unlock Premium Features',
    subtitle: 'Get unlimited access to all features',
    features: [
      'Unlimited access to all content',
      'Ad-free experience',
      'Priority customer support',
      'Exclusive features and updates',
      'Cancel anytime',
    ],
    purchaseButtonText: 'Start Free Trial',
    restorePurchasesText: 'Restore Purchases',
    showCloseButton: true,
  );

  // About Us Configuration
  static const aboutUsConfig = AboutUsConfig(
    appName: 'Kharag SDK Example',
    version: '1.0.0',
    description:
        'This is a demonstration app showcasing the features of Kharag SDK - '
        'a production-ready Flutter package for splash screens, onboarding, '
        'authentication, subscriptions, and analytics.',
    privacyPolicyUrl: 'https://example.com/privacy',
    termsOfServiceUrl: 'https://example.com/terms',
    supportEmail: 'support@example.com',
    websiteUrl: 'https://example.com',
    additionalContent: '''
## About Kharag SDK

Kharag SDK is a comprehensive Flutter package that provides:

- **Splash Screen**: Configurable animated splash screens
- **Onboarding**: Beautiful onboarding flows with skip functionality
- **Authentication**: Firebase Google Sign-In with extensible architecture
- **Subscriptions**: RevenueCat integration for in-app purchases
- **Analytics**: Firebase Analytics and Crashlytics integration

### Open Source

This SDK is open source and available on GitHub. Contributions are welcome!

### Support

For support, please email us at support@example.com or visit our website.
    ''',
    socialLinks: {
      'GitHub': 'https://github.com/CodingWithTashi/TibetanLanguageLearningApp',
      'Twitter': 'https://twitter.com/example',
      'LinkedIn': 'https://linkedin.com/company/example',
    },
  );
}
