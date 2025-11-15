# Kharag SDK Setup Guide

This guide will walk you through setting up Kharag SDK in your Flutter application in 30 minutes or less.

## Prerequisites

- Flutter SDK 3.16.0 or higher
- Dart 3.0.0 or higher
- A Firebase project
- A RevenueCat account (for subscriptions)
- Android Studio / Xcode for platform-specific setup

## Step 1: Add Dependency (2 minutes)

Add `kharag_sdk` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  kharag_sdk: ^1.0.0
```

Run:
```bash
flutter pub get
```

## Step 2: Firebase Setup (10 minutes)

### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will:
- Create a Firebase project (or use existing)
- Register your Android/iOS apps
- Generate `firebase_options.dart`
- Download configuration files

### Option B: Manual Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project"
   - Follow the wizard

2. **Add Android App**:
   - Click "Add app" → Android
   - Package name: `com.yourcompany.yourapp`
   - Download `google-services.json`
   - Place in `android/app/`

3. **Add iOS App**:
   - Click "Add app" → iOS
   - Bundle ID: `com.yourcompany.yourapp`
   - Download `GoogleService-Info.plist`
   - Add to Xcode project

4. **Enable Services**:
   - Authentication → Sign-in method → Google (Enable)
   - Analytics → Enable
   - Crashlytics → Enable

## Step 3: Android Configuration (5 minutes)

### 3.1 Update build.gradle

**android/build.gradle**:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle**:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### 3.2 SHA-1 Certificate

Get your SHA-1 fingerprint:

```bash
cd android
./gradlew signingReport
```

Add it to Firebase Console:
- Project Settings → Your Android App → Add fingerprint

### 3.3 Verify Files

Ensure `google-services.json` is in `android/app/`.

## Step 4: iOS Configuration (5 minutes)

### 4.1 Update Info.plist

Open `ios/Runner/Info.plist` and add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Get this from GoogleService-Info.plist -->
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

To get `REVERSED_CLIENT_ID`:
1. Open `GoogleService-Info.plist`
2. Find `REVERSED_CLIENT_ID` value
3. Copy and paste into `Info.plist`

### 4.2 Update Podfile

Ensure minimum iOS version:

```ruby
platform :ios, '12.0'
```

### 4.3 Install Pods

```bash
cd ios
pod install
```

### 4.4 Verify Files

Ensure `GoogleService-Info.plist` is added to your Xcode project.

## Step 5: RevenueCat Setup (5 minutes)

### 5.1 Create Account

1. Go to [RevenueCat](https://www.revenuecat.com/)
2. Sign up / Log in
3. Create a new project

### 5.2 Configure App

1. Add your app:
   - **iOS**: Bundle ID from Xcode
   - **Android**: Package name from `build.gradle`

2. Link to app stores (for testing, skip this step)

### 5.3 Create Products

1. Go to Products tab
2. Create a subscription product (e.g., "Monthly Premium")
3. Link to App Store / Play Store product IDs

### 5.4 Get API Keys

1. Go to Project Settings → API Keys
2. Copy iOS and Android API keys
3. Save them securely

## Step 6: Initialize SDK in Your App (3 minutes)

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kharag_sdk/kharag_sdk.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  final crashlytics = FirebaseCrashlyticsService();
  await crashlytics.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    // Initialize RevenueCat
    final subscriptionService = ref.read(subscriptionServiceProvider);
    await subscriptionService.initialize(
      apiKey: 'YOUR_REVENUECAT_API_KEY', // TODO: Move to .env
      enableDebugLogs: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomeScreen(),
    );
  }
}
```

## Step 7: Use SDK Components (Quick Test)

### Test Splash Screen

```dart
KharagSplashScreen(
  config: SplashConfig(
    logo: Icon(Icons.star, size: 100, color: Colors.blue),
    minDisplayDuration: 2000,
  ),
  onComplete: () {
    print('Splash completed!');
  },
)
```

### Test Onboarding

```dart
KharagOnboardingScreen(
  config: OnboardingConfig(
    pages: [
      OnboardingPage(
        title: 'Welcome',
        description: 'This is my app',
        image: Icon(Icons.waving_hand, size: 100),
      ),
    ],
  ),
  onComplete: () {
    print('Onboarding completed!');
  },
)
```

### Test Login

```dart
KharagLoginScreen(
  config: LoginConfig(
    title: 'Sign In',
    googleButtonText: 'Sign in with Google',
  ),
  onLoginSuccess: (user) {
    print('Logged in: ${user.email}');
  },
  onLoginError: (error) {
    print('Error: $error');
  },
)
```

## Step 8: Environment Variables (Optional)

### 8.1 Create .env file

```bash
cp .env.example .env
```

### 8.2 Add to .gitignore

```
.env
```

### 8.3 Use flutter_dotenv

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();

  final apiKey = dotenv.env['REVENUECAT_API_KEY']!;
  // ...
}
```

## Step 9: Test Everything (5 minutes)

### Run on Android

```bash
flutter run
```

### Run on iOS

```bash
flutter run
```

### Test Flows

1. ✅ Splash screen appears
2. ✅ Onboarding shows (first time)
3. ✅ Login with Google works
4. ✅ Subscription screen loads
5. ✅ Analytics events logged (check Firebase)

## Troubleshooting

### Google Sign-In Fails

**Problem**: "Sign in failed" error

**Solutions**:
1. Verify SHA-1 certificate in Firebase Console
2. Check `google-services.json` / `GoogleService-Info.plist` is correct
3. Ensure `REVERSED_CLIENT_ID` in `Info.plist` (iOS)
4. Re-download config files from Firebase

### RevenueCat Errors

**Problem**: "No offerings available"

**Solutions**:
1. Verify API key is correct
2. Check products are configured in RevenueCat dashboard
3. Ensure app is linked in RevenueCat
4. Wait a few minutes for sync

### Build Errors

**Problem**: "Dependency resolution failed"

**Solutions**:
```bash
flutter clean
flutter pub get
cd ios && pod install
flutter run
```

### Firebase Not Initialized

**Problem**: "Firebase not initialized" error

**Solutions**:
1. Ensure `await Firebase.initializeApp()` is called
2. Import `firebase_options.dart`
3. Run `flutterfire configure` again

## Next Steps

1. **Customize Theme**: Define your app's theme in `MaterialApp`
2. **Add More Auth**: Implement Apple Sign-In, Email/Password
3. **Configure Products**: Set up subscription tiers in RevenueCat
4. **Add Content**: Create your onboarding pages and content
5. **Test Purchases**: Use sandbox environment for testing
6. **Analytics**: Track custom events
7. **Error Handling**: Add custom error handling logic

## Support

- 📖 [Full Documentation](../README.md)
- 🏗️ [Architecture Guide](ARCHITECTURE.md)
- 🐛 [Report Issues](https://github.com/CodingWithTashi/TibetanLanguageLearningApp/issues)
- 💬 [Discussions](https://github.com/CodingWithTashi/TibetanLanguageLearningApp/discussions)

## Estimated Time: 30 Minutes

- Firebase: 10 min
- Android: 5 min
- iOS: 5 min
- RevenueCat: 5 min
- Code: 3 min
- Testing: 2 min

---

**Congratulations! 🎉** You've successfully integrated Kharag SDK into your Flutter app!
