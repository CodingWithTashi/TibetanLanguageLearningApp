# Kharag SDK

A production-ready Flutter SDK providing splash screen, onboarding, authentication, subscriptions, and analytics features with clean architecture and complete customization.

[![pub package](https://img.shields.io/pub/v/kharag_sdk.svg)](https://pub.dev/packages/kharag_sdk)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Features

✨ **Splash Screen** - Configurable animated splash screens with custom logos and animations
🚀 **Onboarding Flow** - Beautiful onboarding flows with skip functionality and custom content
🔐 **Authentication** - Firebase Google Sign-In with extensible architecture for adding more providers
💳 **Subscriptions** - RevenueCat integration for in-app purchases and subscriptions
📊 **Analytics** - Firebase Analytics and Crashlytics integration
🎨 **Theme Support** - Fully customizable UI that inherits your app's theme
🏗️ **Clean Architecture** - Separation of UI, domain, and data layers
🧪 **Well Tested** - Comprehensive unit, widget, and integration tests

## Installation

Add `kharag_sdk` to your `pubspec.yaml`:

```yaml
dependencies:
  kharag_sdk: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize Firebase

First, set up Firebase for your project. Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview#installation) or use the FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 2. Wrap Your App with ProviderScope

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kharag_sdk/kharag_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Crashlytics (optional)
  final crashlytics = FirebaseCrashlyticsService();
  await crashlytics.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Initialize RevenueCat (for subscriptions)

```dart
final subscriptionService = ref.read(subscriptionServiceProvider);
await subscriptionService.initialize(
  apiKey: 'YOUR_REVENUECAT_API_KEY',
  enableDebugLogs: true, // Set to false in production
);
```

### 4. Use SDK Components

#### Splash Screen

```dart
import 'package:kharag_sdk/kharag_sdk.dart';

KharagSplashScreen(
  config: SplashConfig(
    logo: Image.asset('assets/logo.png'),
    loadingIndicator: CircularProgressIndicator(),
    minDisplayDuration: 2000,
  ),
  onComplete: () {
    // Navigate to next screen
  },
)
```

#### Onboarding

```dart
KharagOnboardingScreen(
  config: OnboardingConfig(
    pages: [
      OnboardingPage(
        title: 'Welcome',
        description: 'Get started with our app',
        image: Image.asset('assets/onboarding_1.png'),
      ),
      // Add more pages...
    ],
    showSkipButton: true,
  ),
  onComplete: () {
    // Navigate to login or home
  },
)
```

#### Login with Google

```dart
KharagLoginScreen(
  config: LoginConfig(
    title: 'Welcome Back',
    subtitle: 'Sign in to continue',
    googleButtonText: 'Sign in with Google',
  ),
  onLoginSuccess: (user) {
    // Handle successful login
  },
  onLoginError: (error) {
    // Handle error
  },
)
```

#### Subscription Paywall

```dart
KharagPaywallScreen(
  config: PaywallConfig(
    title: 'Unlock Premium',
    subtitle: 'Get unlimited access',
    features: [
      'Unlimited access to all content',
      'Ad-free experience',
      'Priority support',
    ],
  ),
  onPurchaseSuccess: (status) {
    // Handle successful purchase
  },
)
```

#### About Us Screen

```dart
KharagAboutUsScreen(
  config: AboutUsConfig(
    appName: 'My App',
    version: '1.0.0',
    description: 'App description here',
    privacyPolicyUrl: 'https://example.com/privacy',
    termsOfServiceUrl: 'https://example.com/terms',
    supportEmail: 'support@example.com',
  ),
)
```

## Platform Setup

### Android Setup

#### 1. Google Sign-In

Add the following to `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Or higher
    }
}
```

#### 2. RevenueCat

No additional setup required for Android.

#### 3. Firebase

Download `google-services.json` from Firebase Console and place it in `android/app/`.

### iOS Setup

#### 1. Google Sign-In

Add the following to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### 2. RevenueCat

Set minimum iOS version in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

#### 3. Firebase

Download `GoogleService-Info.plist` from Firebase Console and add it to your Xcode project.

## Configuration

### Environment Variables

Create a `.env` file (add to `.gitignore`):

```env
REVENUECAT_IOS_API_KEY=your_ios_key_here
REVENUECAT_ANDROID_API_KEY=your_android_key_here
```

### Theme Customization

The SDK automatically inherits your app's theme. Just define your theme:

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
    ),
  ),
  home: YourApp(),
)
```

## State Management with Riverpod

The SDK uses Riverpod for state management. Access SDK providers:

```dart
// Get current user
final user = ref.watch(currentUserProvider);

// Check if authenticated
final isAuth = ref.watch(isAuthenticatedProvider);

// Check onboarding status
final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

// Get auth service
final authService = ref.read(authServiceProvider);

// Get subscription service
final subscriptionService = ref.read(subscriptionServiceProvider);

// Get analytics service
final analytics = ref.read(analyticsServiceProvider);
```

## Authentication

### Current Providers

- Google Sign-In

### Adding Custom Auth Providers

Implement the `AuthProvider` interface:

```dart
class AppleAuthProvider implements AuthProvider {
  @override
  AuthProviderType get providerType => AuthProviderType.apple;

  @override
  Future<Result<KharagUser>> signIn() async {
    // Implement Apple Sign-In
  }

  // Implement other methods...
}

// Register with AuthService
final authService = ref.read(authServiceProvider);
authService.registerProvider(AppleAuthProvider());
```

## Subscriptions

### RevenueCat Setup

1. Create a RevenueCat account at [revenuecat.com](https://www.revenuecat.com)
2. Set up your products in App Store Connect / Google Play Console
3. Configure products in RevenueCat dashboard
4. Get your API keys from RevenueCat

### Testing Subscriptions

Use RevenueCat sandbox mode for testing:

- **iOS**: Use sandbox Apple ID
- **Android**: Use test account in Google Play Console

## Analytics

### Logging Events

```dart
final analytics = ref.read(analyticsServiceProvider);

await analytics.logEvent(
  name: 'custom_event',
  parameters: {'key': 'value'},
);
```

### Crashlytics

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);

await crashlytics.recordError(
  exception,
  stackTrace,
  reason: 'Error description',
);
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tests

```bash
flutter test integration_test/
```

## Example App

Check out the [example](example/) directory for a complete implementation demonstrating all features.

```bash
cd example
flutter run
```

## Architecture

The SDK follows clean architecture principles:

```
lib/
├── src/
│   ├── core/          # Models, interfaces, constants
│   ├── auth/          # Authentication logic
│   ├── subscription/  # Subscription logic
│   ├── analytics/     # Analytics services
│   └── ui/            # UI components
└── kharag_sdk.dart    # Main export file
```

### Key Design Patterns

- **Interface-based providers**: Easy to swap implementations
- **Result type**: Type-safe error handling
- **Riverpod providers**: Reactive state management
- **Theme inheritance**: No hardcoded colors or text styles

## API Documentation

Full API documentation is available at [pub.dev/documentation/kharag_sdk](https://pub.dev/documentation/kharag_sdk)

## Troubleshooting

### Google Sign-In Issues

- Ensure SHA-1 certificate fingerprint is added in Firebase Console
- Verify `google-services.json` / `GoogleService-Info.plist` is correctly placed
- Check that `REVERSED_CLIENT_ID` is added to `Info.plist` (iOS)

### RevenueCat Issues

- Verify API keys are correct
- Ensure products are configured in RevenueCat dashboard
- Check that product IDs match exactly

### Firebase Issues

- Run `flutterfire configure` to ensure correct setup
- Verify Firebase services are enabled in console

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: support@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/CodingWithTashi/TibetanLanguageLearningApp/issues)
- 📖 Documentation: [pub.dev](https://pub.dev/packages/kharag_sdk)

## Credits

Built with ❤️ by the Kharag team.

Special thanks to:
- [Firebase](https://firebase.google.com/)
- [RevenueCat](https://www.revenuecat.com/)
- [Riverpod](https://riverpod.dev/)
