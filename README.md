# debounce_throttle

An observable, debouncer, and throttle that works with `Future`, `Stream`, and callbacks.

Class | Purpose
-|-
`Debouncer` | Wait for changes to stop before notifying.
`Throttle` | Notifies once per `Duration` for a value that keeps changing.
`Observable` | Base class for observing value changes.

## Usage

```dart
  final debouncer = Debouncer<String>(Duration(milliseconds: 200));

  // Run a search whenever the user pauses while typing.
  textEditingController.addListener(() => debouncer.value = textEditingController.text);
  debouncer.values.listen((search) => submitSearch(search));

  final throttle = Throttle<double>(Duration(milliseconds: 100));

  // Limit being notified of continuous sensor data.
  sensor.addListener(throttle.setValue);
  throttle.values.listen((data) => print('$data'));
```


## `example/main.dart` output

```
Tick     : ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Changed  : -----------     -  --   - -  -    --  - -    -   -    -  -   - ---  -  - -  - -    -    -    - - - - --    -    -  -   - - -   --    - --    ---    -   -  - -     -    -     -  -  -
Debounced:              D     D   D     D  D          D    D   D    D  D          D         D    D    D             D    D    D  D       D    D       D      D    D        D     D    D     D
Throttled: T  T  T  T  T   T  T  T  T   T  T  T  T  T   T   T    T  T   T  T  T  T  T  T  T   T    T    T  T  T  T  T  T   T  T   T  T  T  T  T  T  T   T  T   T   T  T  T    T    T     T  T  T
```