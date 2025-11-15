import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Represents an authenticated user in the SDK
@freezed
class KharagUser with _$KharagUser {
  const factory KharagUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required AuthProviderType providerType,
    DateTime? createdAt,
  }) = _KharagUser;

  factory KharagUser.fromJson(Map<String, dynamic> json) =>
      _$KharagUserFromJson(json);
}

/// Types of authentication providers supported
enum AuthProviderType {
  google,
  email,
  apple,
  facebook,
  anonymous,
}
