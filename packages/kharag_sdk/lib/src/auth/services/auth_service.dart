import 'dart:async';

import '../../core/interfaces/auth_provider.dart';
import '../../core/models/result.dart';
import '../../core/models/user.dart';

/// Service that manages authentication across different providers
class AuthService {
  final Map<AuthProviderType, AuthProvider> _providers = {};
  final StreamController<KharagUser?> _authStateController =
      StreamController<KharagUser?>.broadcast();

  AuthService();

  /// Register an authentication provider
  void registerProvider(AuthProvider provider) {
    _providers[provider.providerType] = provider;

    // Listen to auth state changes from this provider
    provider.authStateChanges().listen((user) {
      _authStateController.add(user);
    });
  }

  /// Sign in with a specific provider type
  Future<Result<KharagUser>> signIn(AuthProviderType providerType) async {
    final provider = _providers[providerType];
    if (provider == null) {
      return Result.failure(
        Failure.auth(
          message: 'Provider $providerType is not registered',
          code: 'provider_not_registered',
        ),
      );
    }

    final isAvailable = await provider.isAvailable();
    if (!isAvailable) {
      return Result.failure(
        Failure.auth(
          message: 'Provider $providerType is not available',
          code: 'provider_not_available',
        ),
      );
    }

    return provider.signIn();
  }

  /// Sign out from all providers
  Future<Result<void>> signOut() async {
    try {
      // Sign out from all registered providers
      await Future.wait(
        _providers.values.map((provider) => provider.signOut()),
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.auth(
          message: 'Failed to sign out: ${e.toString()}',
          code: 'sign_out_failed',
        ),
      );
    }
  }

  /// Get current authenticated user from any provider
  Future<Result<KharagUser?>> getCurrentUser() async {
    for (final provider in _providers.values) {
      final result = await provider.getCurrentUser();
      if (result is Success<KharagUser?>) {
        final user = result.data;
        if (user != null) {
          return Result.success(user);
        }
      }
    }
    return const Result.success(null);
  }

  /// Stream of authentication state changes
  Stream<KharagUser?> get authStateChanges => _authStateController.stream;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final result = await getCurrentUser();
    if (result is Success<KharagUser?>) {
      return result.data != null;
    }
    return false;
  }

  /// Get available providers
  List<AuthProviderType> get availableProviders => _providers.keys.toList();

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
