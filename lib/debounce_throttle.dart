import 'dart:async';
import 'package:meta/meta.dart';
import 'package:simple_observable/simple_observable.dart';

/// Debounces value changes by updating [onChanged], [nextValue], and [values]
/// only after [duration] has elapsed without additional changes.
class Debouncer<T> extends Observable<T> {
  Debouncer(this.duration, {required T initialValue, void Function(T value)? onChanged, bool checkEquality = true})
      : super(initialValue: initialValue, onChanged: onChanged, checkEquality: checkEquality);
  final Duration duration;
  Timer? _timer;

  /// The most recent value, without waiting for the debounce timer to expire.
  @override
  T get value => super.value;

  @override
  void notify(T val) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (!canceled) {
        super.notify(val);
      }
    });
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
  Throttle(this.duration, {required T initialValue, void Function(T value)? onChanged, bool checkEquality = true})
      : super(initialValue: initialValue, onChanged: onChanged, checkEquality: checkEquality);
  final Duration duration;
  Timer? _timer;
  bool _dirty = false;

  /// The most recent value, without waiting for the throttle timer to expire.
  @override
  T get value => super.value;

  Timer _makeTimer() => Timer(duration, () {
        if (!canceled) {
          if (_dirty) {
            _dirty = false;
            _timer = _makeTimer();
            super.notify(value);
          } else {
            _timer = null;
          }
        }
      });

  @override
  void notify(T val) {
    if (_timer == null) {
      _dirty = false;
      super.notify(val);
      _timer = _makeTimer();
    } else {
      _dirty = true;
    }
  }

  @override
  @mustCallSuper
  void cancel() {
    super.cancel();
    _timer?.cancel();
  }
}
