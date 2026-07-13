import 'dart:async';

Future<T> runWithTimeout<T>(
  Future<T> future, {
  Duration timeout = const Duration(seconds: 10),
}) {
  return future.timeout(timeout, onTimeout: () {
    throw TimeoutException('Operation timed out after ${timeout.inSeconds}s');
  });
}
