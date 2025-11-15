# Kharag SDK Architecture

This document explains the architectural decisions, design patterns, and extensibility points of the Kharag SDK.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Layers](#architecture-layers)
3. [Design Patterns](#design-patterns)
4. [State Management](#state-management)
5. [Error Handling](#error-handling)
6. [Extensibility](#extensibility)
7. [Testing Strategy](#testing-strategy)

---

## Overview

Kharag SDK follows **Clean Architecture** principles with clear separation between UI, domain logic, and data access. This architecture ensures:

- **Testability**: Each layer can be tested independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features without breaking existing code
- **Flexibility**: Swap implementations without changing interfaces

### Core Principles

1. **Interface-based design**: All providers use interfaces for extensibility
2. **Dependency inversion**: High-level modules don't depend on low-level modules
3. **Single responsibility**: Each class has one clear purpose
4. **Open/closed principle**: Open for extension, closed for modification
5. **Immutability**: Models are immutable using Freezed

---

## Architecture Layers

```
┌─────────────────────────────────────────┐
│          Presentation Layer (UI)        │
│  ┌────────────────────────────────┐    │
│  │  Splash, Onboarding, Login,   │    │
│  │  Paywall, About Us Screens    │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│       State Management (Riverpod)       │
│  ┌────────────────────────────────┐    │
│  │  Providers, State Notifiers    │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│          Domain Layer (Business)        │
│  ┌────────────────────────────────┐    │
│  │  Interfaces, Models, Result    │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│         Data Layer (Implementation)     │
│  ┌────────────────────────────────┐    │
│  │  Auth, Subscription, Analytics │    │
│  │  Service Implementations       │    │
│  └────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### 1. Presentation Layer

**Location**: `lib/src/ui/`

**Responsibility**: Display data and handle user interactions

**Components**:
- `KharagSplashScreen`: Animated splash screen
- `KharagOnboardingScreen`: Multi-page onboarding
- `KharagLoginScreen`: Authentication UI
- `KharagPaywallScreen`: Subscription purchase UI
- `KharagAboutUsScreen`: App information

**Design Decisions**:
- **Theme inheritance**: All UI components use `Theme.of(context)` to inherit colors and styles
- **No hardcoded text**: All text is configurable via config objects
- **Composable widgets**: Small, reusable widget components
- **Callbacks**: UI communicates via callbacks, not direct dependencies

### 2. State Management Layer

**Location**: `lib/src/core/providers/`

**Responsibility**: Manage application state and business logic

**Components**:
- `authServiceProvider`: Authentication state
- `currentUserProvider`: Current authenticated user stream
- `subscriptionServiceProvider`: Subscription state
- `analyticsServiceProvider`: Analytics tracking
- `crashlyticsServiceProvider`: Error reporting

**Design Decisions**:
- **Riverpod**: Chosen for compile-time safety and provider composition
- **Stream providers**: For reactive auth and subscription states
- **Future providers**: For async operations
- **State providers**: For simple state management

### 3. Domain Layer

**Location**: `lib/src/core/`

**Responsibility**: Define business rules and contracts

**Components**:
- **Interfaces**:
  - `AuthProvider`: Contract for authentication providers
  - `SubscriptionProvider`: Contract for subscription providers
  - `AnalyticsService`: Contract for analytics services
  - `CrashlyticsService`: Contract for crashlytics services

- **Models**:
  - `KharagUser`: User entity
  - `SubscriptionPackage`: Subscription product
  - `SubscriptionStatus`: Subscription state
  - `OnboardingPage`: Onboarding content

- **Result Type**:
  - `Result<T>`: Success or failure wrapper
  - `Failure`: Typed errors (Network, Auth, Subscription, etc.)

**Design Decisions**:
- **Interface segregation**: Small, focused interfaces
- **Result type**: Type-safe error handling instead of exceptions
- **Freezed models**: Immutable, copyable data structures
- **No external dependencies**: Domain layer is pure Dart

### 4. Data Layer

**Location**: `lib/src/auth/`, `lib/src/subscription/`, `lib/src/analytics/`

**Responsibility**: Implement domain interfaces with external services

**Components**:
- **Authentication**:
  - `KharagGoogleAuthProvider`: Google Sign-In implementation
  - `AuthService`: Manages multiple auth providers

- **Subscriptions**:
  - `RevenueCatSubscriptionProvider`: RevenueCat implementation

- **Analytics**:
  - `FirebaseAnalyticsService`: Firebase Analytics implementation
  - `FirebaseCrashlyticsService`: Firebase Crashlytics implementation

**Design Decisions**:
- **Single implementation per interface**: Easy to swap or mock
- **Error mapping**: External errors converted to domain `Failure` types
- **Null safety**: All external data validated and typed

---

## Design Patterns

### 1. Strategy Pattern (Auth Providers)

Different authentication methods are implemented as strategies:

```dart
abstract class AuthProvider {
  Future<Result<KharagUser>> signIn();
  // Other methods...
}

class KharagGoogleAuthProvider implements AuthProvider {
  // Google-specific implementation
}

class AppleAuthProvider implements AuthProvider {
  // Apple-specific implementation
}
```

**Benefits**:
- Easy to add new auth methods
- Testable with mocks
- Swap providers at runtime

### 2. Repository Pattern (Auth Service)

`AuthService` acts as a repository managing multiple auth providers:

```dart
class AuthService {
  final Map<AuthProviderType, AuthProvider> _providers = {};

  void registerProvider(AuthProvider provider) {
    _providers[provider.providerType] = provider;
  }

  Future<Result<KharagUser>> signIn(AuthProviderType type) {
    return _providers[type]!.signIn();
  }
}
```

**Benefits**:
- Centralized auth management
- Support multiple auth methods
- Clean API for consumers

### 3. Result Pattern (Error Handling)

Operations return `Result<T>` instead of throwing exceptions:

```dart
sealed class Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = _Failure<T>;
}

// Usage
final result = await authService.signIn(AuthProviderType.google);
result.when(
  success: (user) => print('Logged in: ${user.email}'),
  failure: (error) => print('Error: ${error.message}'),
);
```

**Benefits**:
- Type-safe error handling
- Forces error handling at compile time
- No try-catch boilerplate
- Self-documenting code

### 4. Provider Pattern (Riverpod)

Dependency injection and state management:

```dart
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final currentUserProvider = StreamProvider<KharagUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
```

**Benefits**:
- Compile-time safety
- Auto-dispose resources
- Easy testing with overrides
- Reactive updates

### 5. Observer Pattern (Streams)

Auth and subscription states use streams:

```dart
Stream<KharagUser?> authStateChanges();
Stream<SubscriptionStatus> subscriptionStatusChanges();
```

**Benefits**:
- Reactive UI updates
- Multiple listeners
- Automatic cleanup

---

## State Management

### Riverpod Architecture

```
┌─────────────────────┐
│   Widget (UI)       │
│                     │
│  ref.watch(...)    │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Provider          │
│                     │
│  Data + Logic      │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Service           │
│                     │
│  Business Logic    │
└─────────────────────┘
```

### Provider Types Used

1. **Provider**: For services and dependencies
   ```dart
   final authServiceProvider = Provider<AuthService>(...);
   ```

2. **StreamProvider**: For reactive data streams
   ```dart
   final currentUserProvider = StreamProvider<KharagUser?>(...);
   ```

3. **FutureProvider**: For async operations
   ```dart
   final hasCompletedOnboardingProvider = FutureProvider<bool>(...);
   ```

4. **StateProvider**: For simple state
   ```dart
   final sdkConfigProvider = StateProvider<KharagSdkConfig?>(...);
   ```

### State Flow Example: Authentication

```
User taps "Sign in with Google"
          ↓
LoginScreen calls authService.signIn()
          ↓
Google Auth flow executes
          ↓
AuthProvider updates auth state
          ↓
currentUserProvider emits new user
          ↓
UI rebuilds automatically (ref.watch)
          ↓
User sees home screen
```

---

## Error Handling

### Failure Types

```dart
sealed class Failure {
  const factory Failure.network({...}) = NetworkFailure;
  const factory Failure.auth({...}) = AuthFailure;
  const factory Failure.subscription({...}) = SubscriptionFailure;
  const factory Failure.cancelled({...}) = CancelledFailure;
  const factory Failure.unknown({...}) = UnknownFailure;
}
```

### Error Handling Flow

```
External Service Error
          ↓
Convert to domain Failure
          ↓
Return Result.failure(...)
          ↓
UI handles with result.when()
          ↓
Display user-friendly message
```

### Example

```dart
// Service layer
Future<Result<KharagUser>> signIn() async {
  try {
    final user = await _googleSignIn.signIn();
    if (user == null) {
      return const Result.failure(
        Failure.cancelled(message: 'Sign-in cancelled'),
      );
    }
    // ... continue
  } on FirebaseAuthException catch (e) {
    return Result.failure(
      Failure.auth(message: e.message, code: e.code),
    );
  } catch (e) {
    return Result.failure(
      Failure.unknown(message: e.toString()),
    );
  }
}

// UI layer
final result = await authService.signIn();
result.when(
  success: (user) => navigateToHome(),
  failure: (error) => showError(error.message),
);
```

---

## Extensibility

### Adding a New Auth Provider

1. **Create provider class**:
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
```

2. **Register with AuthService**:
```dart
final authService = ref.read(authServiceProvider);
authService.registerProvider(AppleAuthProvider());
```

3. **Use in UI**:
```dart
await authService.signIn(AuthProviderType.apple);
```

### Adding a New Subscription Provider

1. **Implement interface**:
```dart
class StripeSubscriptionProvider implements SubscriptionProvider {
  @override
  Future<Result<void>> initialize({...}) async {
    // Stripe initialization
  }

  @override
  Future<Result<SubscriptionOffering?>> getOfferings() async {
    // Fetch Stripe products
  }

  // Implement other methods...
}
```

2. **Replace in provider**:
```dart
final subscriptionServiceProvider = Provider<SubscriptionProvider>((ref) {
  return StripeSubscriptionProvider();
});
```

### Adding a New Screen

1. **Create screen widget**:
```dart
class KharagSettingsScreen extends StatelessWidget {
  final SettingsConfig config;

  const KharagSettingsScreen({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Build UI using theme
  }
}
```

2. **Create config model**:
```dart
class SettingsConfig {
  final String title;
  final List<SettingItem> items;
  // Other configuration
}
```

3. **Export in main file**:
```dart
// lib/kharag_sdk.dart
export 'src/ui/settings/settings_screen.dart';
```

### Custom Analytics Provider

```dart
class CustomAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent({...}) async {
    // Custom implementation
  }
  // Other methods...
}

// Replace provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return CustomAnalyticsService();
});
```

---

## Testing Strategy

### Unit Tests

**Coverage**: Core logic, services, providers

```dart
test('AuthService should register provider', () {
  final authService = AuthService();
  final provider = MockGoogleAuthProvider();

  authService.registerProvider(provider);

  expect(
    authService.availableProviders,
    contains(AuthProviderType.google),
  );
});
```

### Widget Tests

**Coverage**: UI components

```dart
testWidgets('LoginScreen displays Google button', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: KharagLoginScreen(
        config: LoginConfig(),
        onLoginSuccess: (_) {},
      ),
    ),
  );

  expect(
    find.text('Sign in with Google'),
    findsOneWidget,
  );
});
```

### Integration Tests

**Coverage**: Complete flows

```dart
testWidgets('Complete login flow', (tester) async {
  // Set up mocks
  final mockAuth = MockAuthService();
  when(mockAuth.signIn(any)).thenAnswer(
    (_) async => Result.success(mockUser),
  );

  // Pump app
  await tester.pumpWidget(MyApp());

  // Interact
  await tester.tap(find.text('Sign in with Google'));
  await tester.pumpAndSettle();

  // Verify
  expect(find.text('Welcome'), findsOneWidget);
});
```

### Mocking Strategy

All interfaces can be mocked for testing:

```dart
class MockAuthProvider extends Mock implements AuthProvider {}
class MockSubscriptionProvider extends Mock implements SubscriptionProvider {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
```

---

## Best Practices

### DO ✅

- Use interfaces for all external dependencies
- Return `Result<T>` for operations that can fail
- Use Freezed for immutable models
- Document public APIs with dartdoc
- Write tests for new features
- Follow existing patterns
- Use theme inheritance for UI

### DON'T ❌

- Hardcode colors or text in UI
- Throw exceptions for business logic errors
- Mix UI and business logic
- Create tight coupling between layers
- Access providers directly in UI (use ref.watch/read)
- Skip error handling
- Modify core interfaces without discussion

---

## Performance Considerations

1. **Lazy initialization**: Providers are created only when needed
2. **Auto-dispose**: Riverpod automatically disposes unused providers
3. **Caching**: SharedPreferences for onboarding status
4. **Streams**: Efficient reactive updates
5. **Widget rebuilds**: Only affected widgets rebuild (ref.watch)

---

## Security Considerations

1. **No secrets in code**: API keys via environment variables
2. **Secure storage**: Use FlutterSecureStorage for tokens (if needed)
3. **HTTPS only**: All network calls use HTTPS
4. **Token refresh**: Handled by Firebase Auth automatically
5. **Input validation**: All user input validated

---

## Future Improvements

1. **Localization**: i18n support for multiple languages
2. **Offline support**: Cache data for offline access
3. **Custom themes**: Theme tokens for advanced customization
4. **More auth providers**: Apple, Facebook, Twitter, etc.
5. **Analytics abstraction**: Support multiple analytics providers
6. **Performance monitoring**: Track screen load times
7. **A/B testing**: Built-in experimentation support

---

## Conclusion

The Kharag SDK architecture prioritizes:
- **Clean code**: Easy to read and understand
- **Testability**: Every layer can be tested
- **Extensibility**: Easy to add new features
- **Maintainability**: Changes are isolated
- **Type safety**: Compile-time error detection

For questions or suggestions, please open an issue on GitHub.
