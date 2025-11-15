import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// A result type that encapsulates success or failure
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = _Failure<T>;
}

/// Base failure class for all errors in the SDK
@freezed
class Failure with _$Failure {
  const factory Failure.network({
    required String message,
    String? code,
  }) = NetworkFailure;

  const factory Failure.auth({
    required String message,
    String? code,
  }) = AuthFailure;

  const factory Failure.subscription({
    required String message,
    String? code,
  }) = SubscriptionFailure;

  const factory Failure.unknown({
    required String message,
    String? code,
  }) = UnknownFailure;

  const factory Failure.cancelled({
    required String message,
  }) = CancelledFailure;
}
