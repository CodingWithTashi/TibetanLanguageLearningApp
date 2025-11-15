import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../core/constants/storage_keys.dart';
import '../../core/interfaces/auth_provider.dart';
import '../../core/models/result.dart';
import '../../core/models/user.dart';

/// Google Sign-In authentication provider implementation
class KharagGoogleAuthProvider implements AuthProvider {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  KharagGoogleAuthProvider({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  AuthProviderType get providerType => AuthProviderType.google;

  @override
  Future<bool> isAvailable() async {
    try {
      // Google Sign-In is available on Android and iOS
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<KharagUser>> signIn() async {
    try {
      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return const Result.failure(
          Failure.cancelled(
            message: 'Google Sign-In was cancelled',
          ),
        );
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        return const Result.failure(
          Failure.auth(
            message: 'Failed to sign in with Google',
            code: ErrorCodes.authFailed,
          ),
        );
      }

      final kharagUser = _mapFirebaseUserToKharagUser(user);
      return Result.success(kharagUser);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        Failure.auth(
          message: e.message ?? 'Firebase authentication failed',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        Failure.auth(
          message: e.toString(),
          code: ErrorCodes.authFailed,
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.auth(
          message: 'Failed to sign out: ${e.toString()}',
          code: ErrorCodes.authFailed,
        ),
      );
    }
  }

  @override
  Future<Result<KharagUser?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.success(null);
      }

      final kharagUser = _mapFirebaseUserToKharagUser(user);
      return Result.success(kharagUser);
    } catch (e) {
      return Result.failure(
        Failure.auth(
          message: 'Failed to get current user: ${e.toString()}',
          code: ErrorCodes.authFailed,
        ),
      );
    }
  }

  @override
  Stream<KharagUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUserToKharagUser(user);
    });
  }

  /// Maps Firebase User to KharagUser
  KharagUser _mapFirebaseUserToKharagUser(User user) {
    return KharagUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      providerType: AuthProviderType.google,
      createdAt: user.metadata.creationTime,
    );
  }
}
