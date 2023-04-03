
import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/widgets.dart';

typedef FutureFunction<T> = Future<T> Function();

class ErrorListenerTemplate with Closeable {
  ValueNotifier<Exception?> listener;
  ErrorListenerTemplate() : listener = ValueNotifier(null);
  ErrorListenerTemplate.withNotifier(this.listener);

  Future<T> exec<T>(FutureFunction<T> fn) async {
    try {
      final result = await fn();
      listener.value = null;
      return result;
    } on Exception catch (e) {
      listener.value = e;
      rethrow;
    }
  }

  void dispose() {
    listener.dispose();
  }
  @override
  Future close() async {
    dispose();
    return;
  }

  void clearError() {
    listener.value = null;
  }
}

class RetryTemplate<T> {
  final int maxRetries;
  RetryTemplate(this.maxRetries);

  Future<T> exec(FutureFunction<T> fn) async {
    Object? error;
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await fn();
      } catch (e) {
        error = e;
      }
    }
    throw error!;
  }
}
