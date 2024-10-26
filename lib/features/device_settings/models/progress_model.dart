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
