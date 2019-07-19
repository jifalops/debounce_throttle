import 'dart:async';
import 'package:meta/meta.dart';

typedef void _Callback<T>(T value);

/// Holds a value and notifies listeners whenever that value is set.
///
/// Listeners can use the [onChanged] callback, the [nextValue] Future, and/or
/// the [values] Stream.
class Observable<T> {
  Observable({T initialValue, this.onChanged}) : _value = initialValue;

  final _Callback<T> onChanged;

  var _completer = Completer<T>();

  bool _canceled = false;
  bool get canceled => _canceled;

  T _value;

  /// The current value of this observable.
  T get value => _value;
  set value(T val) {
    if (!canceled) {
      _value = val;
      // Delaying notify() allows the Future and Stream to update correctly.
      Future.delayed(Duration(microseconds: 1), () => _notify(val));
    }
  }

  /// Alias for [value] setter. Good for passing to a Future or Stream.
  void setValue(T val) => value = val;

  void _notify(T val) {
    if (onChanged != null) onChanged(val);
    // Completing with a microtask allows a new completer to be constructed
    // before listeners of [nextValue] are called, allowing them to listen to
    // nextValue again if desired.
    _completer.complete(Future.microtask(() => val));
    _completer = Completer<T>();
  }

  Future<T> get nextValue => _completer.future;
  Stream<T> get values async* {
    while (!canceled) {
      yield await nextValue;
    }
  }

  /// Permanently disables this observable. Further changes to [value] will be
  /// ignored, the outputs [onChanged], [nextValue], and [values] will not be
  /// called again.
  @mustCallSuper
  void cancel() => _canceled = true;
}

/// Debounces value changes by updating [onChanged], [nextValue], and [values]
/// only after [duration] has elapsed without additional changes.
class Debouncer<T> extends Observable<T> {
  Debouncer(this.duration, {T initialValue, _Callback<T> onChanged})
      : super(initialValue: initialValue, onChanged: onChanged);
  final Duration duration;
  Timer _timer;

  /// The most recent value, without waiting for the debounce timer to expire.
  @override
  T get value => super.value;

  set value(T val) {
    if (!canceled) {
      _value = val;
      _timer?.cancel();
      _timer = Timer(duration, () {
        if (!canceled) {
          _notify(value);
        }
      });
    }
  }

  @override
  @mustCallSuper
  void cancel() {
    super.cancel();
    _timer?.cancel();
  }
}

/// Throttles value changes by updating [onChanged], [nextValue], and [values]
/// once per [duration] at most.
class Throttle<T> extends Observable<T> {
  Throttle(this.duration, {T initialValue, _Callback<T> onChanged})
      : super(initialValue: initialValue, onChanged: onChanged);
  final Duration duration;
  Timer _timer;

  /// The most recent value, without waiting for the throttle timer to expire.
  @override
  T get value => super.value;

  set value(T val) {
    if (!canceled) {
      _value = val;
      _timer ??= Timer(duration, () {
        if (!canceled) {
          _timer = null;
          _notify(value);
        }
      });
    }
  }

  @override
  @mustCallSuper
  void cancel() {
    super.cancel();
    _timer?.cancel();
  }
}
