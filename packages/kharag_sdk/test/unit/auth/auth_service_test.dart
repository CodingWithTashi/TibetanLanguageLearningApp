import 'package:flutter_test/flutter_test.dart';
import 'package:kharag_sdk/kharag_sdk.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockKharagUser extends Mock implements KharagUser {}

void main() {
  late AuthService authService;
  late MockAuthProvider mockGoogleProvider;

  setUp(() {
    authService = AuthService();
    mockGoogleProvider = MockAuthProvider();

    // Setup default behavior
    when(() => mockGoogleProvider.providerType)
        .thenReturn(AuthProviderType.google);
    when(() => mockGoogleProvider.isAvailable())
        .thenAnswer((_) async => true);
    when(() => mockGoogleProvider.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
  });

  tearDown(() {
    authService.dispose();
  });

  group('AuthService - Provider Registration', () {
    test('should register an auth provider', () {
      // Act
      authService.registerProvider(mockGoogleProvider);

      // Assert
      expect(
        authService.availableProviders,
        contains(AuthProviderType.google),
      );
    });

    test('should register multiple auth providers', () {
      // Arrange
      final mockAppleProvider = MockAuthProvider();
      when(() => mockAppleProvider.providerType)
          .thenReturn(AuthProviderType.apple);
      when(() => mockAppleProvider.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      // Act
      authService.registerProvider(mockGoogleProvider);
      authService.registerProvider(mockAppleProvider);

      // Assert
      expect(authService.availableProviders, hasLength(2));
      expect(
        authService.availableProviders,
        containsAll([AuthProviderType.google, AuthProviderType.apple]),
      );
    });
  });

  group('AuthService - Sign In', () {
    test('should sign in successfully with registered provider', () async {
      // Arrange
      final mockUser = MockKharagUser();
      when(() => mockGoogleProvider.signIn())
          .thenAnswer((_) async => Result.success(mockUser));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.signIn(AuthProviderType.google);

      // Assert
      expect(result, isA<Success<KharagUser>>());
      verify(() => mockGoogleProvider.signIn()).called(1);
    });

    test('should return failure when provider is not registered', () async {
      // Act
      final result = await authService.signIn(AuthProviderType.google);

      // Assert
      expect(result, isA<_Failure<KharagUser>>());
      final failure = (result as _Failure<KharagUser>).failure;
      expect(failure, isA<AuthFailure>());
    });

    test('should return failure when provider is not available', () async {
      // Arrange
      when(() => mockGoogleProvider.isAvailable())
          .thenAnswer((_) async => false);

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.signIn(AuthProviderType.google);

      // Assert
      expect(result, isA<_Failure<KharagUser>>());
      final failure = (result as _Failure<KharagUser>).failure;
      expect(failure, isA<AuthFailure>());
    });

    test('should propagate auth failure from provider', () async {
      // Arrange
      when(() => mockGoogleProvider.signIn()).thenAnswer(
        (_) async => const Result.failure(
          Failure.auth(
            message: 'Sign in failed',
            code: 'auth_failed',
          ),
        ),
      );

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.signIn(AuthProviderType.google);

      // Assert
      expect(result, isA<_Failure<KharagUser>>());
      final failure = (result as _Failure<KharagUser>).failure;
      expect(failure, isA<AuthFailure>());
    });
  });

  group('AuthService - Sign Out', () {
    test('should sign out successfully from all providers', () async {
      // Arrange
      when(() => mockGoogleProvider.signOut())
          .thenAnswer((_) async => const Result.success(null));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.signOut();

      // Assert
      expect(result, isA<Success<void>>());
      verify(() => mockGoogleProvider.signOut()).called(1);
    });

    test('should sign out from multiple providers', () async {
      // Arrange
      final mockAppleProvider = MockAuthProvider();
      when(() => mockAppleProvider.providerType)
          .thenReturn(AuthProviderType.apple);
      when(() => mockAppleProvider.authStateChanges())
          .thenAnswer((_) => Stream.value(null));
      when(() => mockAppleProvider.signOut())
          .thenAnswer((_) async => const Result.success(null));
      when(() => mockGoogleProvider.signOut())
          .thenAnswer((_) async => const Result.success(null));

      authService.registerProvider(mockGoogleProvider);
      authService.registerProvider(mockAppleProvider);

      // Act
      final result = await authService.signOut();

      // Assert
      expect(result, isA<Success<void>>());
      verify(() => mockGoogleProvider.signOut()).called(1);
      verify(() => mockAppleProvider.signOut()).called(1);
    });
  });

  group('AuthService - Get Current User', () {
    test('should return null when no user is authenticated', () async {
      // Arrange
      when(() => mockGoogleProvider.getCurrentUser())
          .thenAnswer((_) async => const Result.success(null));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isA<Success<KharagUser?>>());
      expect((result as Success<KharagUser?>).data, isNull);
    });

    test('should return user when authenticated', () async {
      // Arrange
      final mockUser = MockKharagUser();
      when(() => mockGoogleProvider.getCurrentUser())
          .thenAnswer((_) async => Result.success(mockUser));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isA<Success<KharagUser?>>());
      expect((result as Success<KharagUser?>).data, equals(mockUser));
    });
  });

  group('AuthService - Authentication Status', () {
    test('should return false when not authenticated', () async {
      // Arrange
      when(() => mockGoogleProvider.getCurrentUser())
          .thenAnswer((_) async => const Result.success(null));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, isFalse);
    });

    test('should return true when authenticated', () async {
      // Arrange
      final mockUser = MockKharagUser();
      when(() => mockGoogleProvider.getCurrentUser())
          .thenAnswer((_) async => Result.success(mockUser));

      authService.registerProvider(mockGoogleProvider);

      // Act
      final isAuth = await authService.isAuthenticated();

      // Assert
      expect(isAuth, isTrue);
    });
  });
}
