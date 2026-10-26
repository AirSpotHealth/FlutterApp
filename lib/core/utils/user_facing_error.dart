import 'dart:async';
import 'dart:io';

/// Separates actionable customer wording from details retained for diagnostics.
class UserFacingError implements Exception {
  const UserFacingError(this.title, this.message,
      {this.cause, this.retryable = true});
  final String title;
  final String message;
  final Object? cause;
  final bool retryable;
  @override
  String toString() => message;
}

String userErrorMessage(Object? error, {required String fallback}) {
  if (error is UserFacingError) return error.message;
  if (error is TimeoutException) {
    return 'This took longer than expected. Check your connection and try again.';
  }
  if (error is SocketException) {
    return 'Could not connect. Check your internet connection and try again.';
  }
  return fallback;
}
