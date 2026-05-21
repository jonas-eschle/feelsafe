/// App-level theme preference.
///
/// See spec 03 §AppSettings. Maps to Flutter's [ThemeMode] at the
/// presentation layer.
enum AppThemeMode {
  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,

  /// Follow the OS system preference.
  system,
}
