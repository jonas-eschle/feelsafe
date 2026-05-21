/// Built-in icon presets for stealth mode.
///
/// See spec 03 §StealthConfig. The helper `iconFromStealth(preset)`
/// resolves each value to a Material [IconData] in the UI layer.
/// [none] means "no icon override — fall back to the standard app icon".
enum StealthIconPreset {
  /// Generic music player icon.
  music,

  /// Generic calendar icon.
  calendar,

  /// Generic fitness / activity icon.
  fitness,

  /// Generic weather icon.
  weather,

  /// Generic news / reading icon.
  news,

  /// Generic photo gallery icon.
  photos,

  /// Generic notes / memo icon.
  notes,

  /// Generic clock / alarm icon.
  clock,

  /// Generic podcast icon.
  podcast,

  /// No icon override — uses the standard Guardian Angela app icon.
  none,
}
