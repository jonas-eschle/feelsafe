/// Visual style of the fake-call incoming-call screen.
///
/// See spec 03 §FakeCallConfig. Controls which platform call-sheet
/// appearance the fake-call screen imitates.
enum CallStyle {
  /// Auto-resolve to the host platform's native style at render time
  /// (`androidNative` on Android, `iosNative` on iOS). This is the
  /// spec-default value referenced by `FakeCallConfig.callStyle` (spec
  /// 03:344, "default: platform-native").
  platformNative,

  /// Mimic the Android native full-screen incoming-call UI.
  androidNative,

  /// Mimic the iOS native full-screen incoming-call UI.
  iosNative,

  /// A platform-agnostic minimal call overlay.
  minimal,
}
