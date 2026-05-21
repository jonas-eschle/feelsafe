/// Visual style of the fake-call incoming-call screen.
///
/// See spec 03 §FakeCallConfig. Controls which platform call-sheet
/// appearance the fake-call screen imitates.
enum CallStyle {
  /// Mimic the Android native full-screen incoming-call UI.
  androidNative,

  /// Mimic the iOS native full-screen incoming-call UI.
  iosNative,

  /// A platform-agnostic minimal call overlay.
  minimal,
}
