import 'package:flutter/foundation.dart';

class WidgetModelDependencies {
  const WidgetModelDependencies();
}

/// Lightweight MWWM WidgetModel base (per ARCHITECTURE_GUIDE).
abstract class WidgetModel {
  WidgetModel(this._dependencies);

  final WidgetModelDependencies _dependencies;
  WidgetModelDependencies get dependencies => _dependencies;

  bool _disposed = false;
  bool get isDisposed => _disposed;

  @mustCallSuper
  void onLoad() {}

  @mustCallSuper
  void onBind() {}

  void handleError(Object error, [StackTrace? stackTrace]) {
    debugPrint('WM error: $error');
    if (stackTrace != null) debugPrint('$stackTrace');
  }

  @mustCallSuper
  void dispose() {
    _disposed = true;
  }
}
