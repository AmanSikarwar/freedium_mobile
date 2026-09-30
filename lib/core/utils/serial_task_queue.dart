/// Runs read-modify-write operations in order, including after a failed task.
class SerialTaskQueue() {
  Future<void> _pending = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final result = _pending.then((_) => task());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
