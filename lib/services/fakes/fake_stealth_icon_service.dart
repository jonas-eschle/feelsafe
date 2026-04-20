/// Deterministic fake implementation of
/// [StealthIconServiceProtocol] for tests. Every call is recorded to
/// [calls].
library;

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';

/// Test double for [StealthIconServiceProtocol].
final class FakeStealthIconService implements StealthIconServiceProtocol {
  /// Creates a fake stealth-icon service.
  FakeStealthIconService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  StealthIconPreset _current = StealthIconPreset.calendar;

  @override
  Future<void> setPreset(StealthIconPreset preset) async {
    calls.add('setPreset:${preset.name}');
    _current = preset;
  }

  @override
  Future<StealthIconPreset> getCurrentPreset() async {
    calls.add('getCurrentPreset');
    return _current;
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
