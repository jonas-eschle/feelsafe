import AVFoundation
import Foundation

/// Configures `AVAudioSession` so that Guardian Angela's loud-alarm and
/// fake-call audio plays correctly on iOS regardless of the hardware
/// silent-switch position and continues playing in the background.
///
/// This is not a Flutter MethodChannel plugin — it has no custom channel.
/// It supports the `audio_session` and `audio_service` pub.dev plugins by
/// ensuring the native audio session category is set before those plugins
/// initialise their own session handling.
///
/// Call `AlarmAudioPlugin.configure()` once during app startup (from
/// `AppDelegate.didInitializeImplicitFlutterEngine`).
final class AlarmAudioPlugin {

  // MARK: - API

  /// Configures the shared `AVAudioSession` for alarm and fake-call audio.
  ///
  /// Category `.playback` allows audio to play while the device is locked and
  /// when the hardware silent-switch is on. The `.duckOthers` option lowers
  /// competing audio (music, podcasts) so the alarm is clearly audible.
  /// `.allowBluetooth` / `.allowBluetoothA2DP` ensure Bluetooth output works.
  ///
  /// This call is idempotent; calling it more than once is safe.
  static func configure() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(
        .playback,
        mode: .default,
        options: [.duckOthers, .allowBluetooth, .allowBluetoothA2DP]
      )
      try session.setActive(true)
    } catch {
      // Log but do not crash — audio session failures are non-fatal at startup;
      // the alarm may still play if the session was already configured by a
      // pub.dev plugin.
      NSLog("[AlarmAudioPlugin] AVAudioSession configuration failed: %@", error.localizedDescription)
    }
  }

  // MARK: - Private init (static-only utility)

  private init() {}
}
