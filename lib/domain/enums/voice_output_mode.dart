/// Where the voice recording plays during a fake-call step.
///
/// See spec 03 §FakeCallConfig.
enum VoiceOutputMode {
  /// Audio plays through the earpiece (quiet, private).
  earpiece,

  /// Audio plays through the loudspeaker.
  speaker,
}
