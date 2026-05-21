/// Format used when serialising GPS coordinates in session logs and SMS.
///
/// See spec 03 §GpsLoggingConfig and Q21.
enum GpsFormat {
  /// Degrees, minutes, seconds (e.g., 37°46′30″N 122°25′10″W).
  dms,

  /// Decimal degrees (e.g., 37.7749, -122.4194). Default per Q21.
  decimal,

  /// Google Open Location Code / Plus Code
  /// (e.g., 849VCWC8+R9).
  openLocationCode,
}
