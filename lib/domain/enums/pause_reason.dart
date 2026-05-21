/// Why the session engine is currently paused.
///
/// See spec 03 §WalkSession and lessons §5.2/5.3. There is NO
/// `bootRestart` value (no session restore from disk) and NO fake-call
/// answered value — fake call is an event, not a pause (lessons §5.3).
enum PauseReason {
  /// The user tapped the explicit Pause button.
  userRequested,

  /// An OS-level incoming call was detected; session auto-paused.
  incomingCall,
}
