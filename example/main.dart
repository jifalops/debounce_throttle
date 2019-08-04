// Example output:
// Tick     : ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// Changed  : -----------     -  --   - -  -    --  - -    -   -    -  -   - ---  -  - -  - -    -    -    - - - - --    -    -  -   - - -   --    - --    ---    -   -  - -     -    -     -  -  -
// Debounced:              D     D   D     D  D          D    D   D    D  D          D         D    D    D             D    D    D  D       D    D       D      D    D        D     D    D     D
// Throttled: T  T  T  T  T   T  T  T  T   T  T  T  T  T   T   T    T  T   T  T  T  T  T  T  T   T    T    T  T  T  T  T  T   T  T   T  T  T  T  T  T  T   T  T   T   T  T  T    T    T     T  T  T

import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:debounce_throttle/debounce_throttle.dart';

void main() async {
  final debouncer = Debouncer<String>(Duration(milliseconds: 300),
      onChanged: debounceTick, initialValue: '');
  final throttle = Throttle<String>(Duration(milliseconds: 300),
      onChanged: throttleTick, initialValue: '');

  final random = Random();

  void doChange() {
    changeTick();
    debouncer.value += '.';
    throttle.value += '.';
  }

  startTicking();

  // Change frequently at first to show difference between debounce/throttle.
  for (int i = 0; i < 20; i++) {
    await Future.delayed(Duration(milliseconds: 50));
    doChange();
  }

  while (true) {
    // Wait 50 to 550 milliseconds.
    await Future.delayed(Duration(milliseconds: 50 + random.nextInt(500)));
    doChange();
  }
}

Timer startTicking() => Timer.periodic(Duration(milliseconds: 100), (timer) {
      String changed = '', debounced = '', throttled = '';
      ticks.forEach((tick) {
        changed += tick.changed ? '-' : ' ';
        debounced += tick.debounced ? tick.debounceError ? 'E' : 'D' : ' ';
        throttled += tick.throttled ? tick.throttleError ? 'E' : 'T' : ' ';
      });
      if (Platform.isWindows) {
        print(Process.runSync("cls", [], runInShell: true).stdout);
      } else {
        print(Process.runSync("clear", [], runInShell: true).stdout);
      }
      print('Tick     : ${'|' * ticks.length}');
      print('Changed  : $changed');
      print('Debounced: $debounced');
      print('Throttled: $throttled');
      if (ticks.length >= stdout.terminalColumns - 11) {
        exit(0);
      }
      ticks.add(Tick());
    });

/// For visual representation in the terminal.
class Tick {
  bool changed = false;
  bool debounced = false;
  bool throttled = false;
  bool debounceError = false;
  bool throttleError = false;
}

final ticks = [Tick()];

void changeTick() => ticks.last.changed = true;
void debounceTick(String value) {
  ticks.last.debounced = true;
  if (!debounceStopwatch.isRunning)
    debounceStopwatch.start();
  else {
    if (debounceStopwatch.elapsedMilliseconds < 300)
      ticks.last.debounceError = true;
    debounceStopwatch.reset();
  }
}

void throttleTick(String value) {
  ticks.last.throttled = true;
  if (!throttleStopwatch.isRunning)
    throttleStopwatch.start();
  else {
    if (throttleStopwatch.elapsedMilliseconds < 300)
      ticks.last.throttleError = true;
    throttleStopwatch.reset();
  }
}

final debounceStopwatch = Stopwatch();
final throttleStopwatch = Stopwatch();
