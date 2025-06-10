abstract class AsyncProgressValue<T> {
  const AsyncProgressValue();
}

class AsyncNone<T> implements AsyncProgressValue<T> {
  const AsyncNone();
}

class AsyncInProgress<T> implements AsyncProgressValue<T> {
  const AsyncInProgress(this.progress, {this.message});

  final double progress;

  final String? message;

  AsyncInProgress copyWithMessage(String message) {
    return AsyncInProgress(progress, message: message);
  }
}

class AsyncSuccess<T> implements AsyncProgressValue<T> {
  const AsyncSuccess(this.data);

  final Object? data;
}

class AsyncFailure<T> implements AsyncProgressValue<T> {
  const AsyncFailure(this.error);

  final Object error;
}

extension AsyncProgressValueX on AsyncProgressValue {
  bool get isNone => this is AsyncNone;

  bool get isInProgress => this is AsyncInProgress;

  bool get isSuccess => this is AsyncSuccess;

  bool get isFailure => this is AsyncFailure;

  AsyncNone get asNone => this as AsyncNone;

  AsyncInProgress get asInProgress => this as AsyncInProgress;

  AsyncSuccess get asSuccess => this as AsyncSuccess;

  AsyncFailure get asFailure => this as AsyncFailure;

  // when pattern matching is available in Dart, this can be replaced with a switch
  T when<T>({
    required T Function() none,
    required T Function(double progress, String? message) inProgress,
    required T Function(dynamic data) success,
    required T Function(Object error) failure,
  }) {
    if (this is AsyncNone) {
      return none();
    } else if (this is AsyncInProgress) {
      return inProgress((this as AsyncInProgress).progress,
          (this as AsyncInProgress).message);
    } else if (this is AsyncSuccess) {
      return success((this as AsyncSuccess).data);
    } else if (this is AsyncFailure) {
      return failure((this as AsyncFailure).error);
    } else {
      throw AssertionError('Unknown state: $this');
    }
  }
}
