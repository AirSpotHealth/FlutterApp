abstract class AsyncProgressValue {}

class AsyncNone implements AsyncProgressValue {
  const AsyncNone();
}

class AsyncInProgress implements AsyncProgressValue {
  const AsyncInProgress(this.progress, {this.message});

  final double progress;

  final String? message;

  AsyncInProgress copyWithMessage(String message) {
    return AsyncInProgress(progress, message: message);
  }
}

class AsyncSuccess implements AsyncProgressValue {
  const AsyncSuccess(this.data);

  final Object? data;
}

class AsyncFailure implements AsyncProgressValue {
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
