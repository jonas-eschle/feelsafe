/// `ScreenFlashServiceProtocol` — abstract contract for the
/// full-screen alternating-color overlay used as a visual loud-alarm
/// signal (spec 02 §loudAlarm `flashScreen=true`).
///
/// Pure Dart. The real implementation owns a broadcast stream of
/// on/off ticks; the `ScreenFlashOverlay` widget subscribes and
/// repaints between two colours each tick. Decoupling the timer from
/// the widget makes the overlay a pure subscriber and lets non-UI
/// callers (e.g. simulation logging, future home-widget mirrors)
/// observe the same stream.
library;

/// Default cycle length (full on + full off) when [start] is called
/// with no argument. 1 second matches the spec 05 "slow" preset that
/// is recommended-by-default for photosensitivity.
const Duration kDefaultScreenFlashInterval = Duration(seconds: 1);

/// Abstract contract for the screen-flash service.
///
/// Single-slot — calling [start] while a flash is already running
/// rebases the schedule. [stop] is idempotent.
abstract class ScreenFlashServiceProtocol {
  /// Begins emitting alternating on/off ticks at half-cycle
  /// intervals derived from [interval]. Subscribers paint one colour
  /// on `true` ticks and the alternate colour on `false` ticks.
  ///
  /// [interval] defaults to [kDefaultScreenFlashInterval] (1 s full
  /// cycle = 500 ms half).
  Future<void> start({Duration interval = kDefaultScreenFlashInterval});

  /// Stops the flash. No-op when not flashing. Idempotent.
  Future<void> stop();

  /// True iff the service is currently emitting ticks.
  bool get isFlashing;

  /// Stream of on/off ticks the overlay subscribes to. Each event
  /// is a boolean: `true` = primary colour, `false` = alternate.
  Stream<bool> get ticks;
}
