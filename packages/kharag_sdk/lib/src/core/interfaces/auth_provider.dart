import '../models/result.dart';
import '../models/user.dart';

/// Abstract interface for authentication providers
/// This allows for easy extension to add new auth methods (Apple, Facebook, etc.)
abstract class AuthProvider {
  /// Sign in with this provider
  Future<Result<KharagUser>> signIn();

  /// Sign out
  Future<Result<void>> signOut();

  /// Get current authenticated user
  Future<Result<KharagUser?>> getCurrentUser();

  /// Stream of authentication state changes
  Stream<KharagUser?> authStateChanges();

  /// Get the provider type
  AuthProviderType get providerType;

  /// Check if this provider is available on the current platform
  Future<bool> isAvailable();
}
