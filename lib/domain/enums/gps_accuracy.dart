/// GPS accuracy level for location logging during sessions.
///
/// See spec 03 §GpsLoggingConfig and Q21. Higher accuracy uses more
/// battery; the default is [high] for maximum emergency usefulness.
enum GpsAccuracy {
  /// Coarse location (e.g., cell-tower or Wi-Fi triangulation).
  low,

  /// Balanced accuracy and battery usage.
  medium,

  /// Fine GPS-level accuracy.
  high,
}
