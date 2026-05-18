/// Visual loud-alarm overlay: alternates between two colours each
/// time the [ScreenFlashServiceProtocol] emits a tick.
///
/// Subscribes to the service stream rather than driving the timer
/// itself — keeps the timer logic in one place (the service) and
/// makes the overlay a pure subscriber that can be removed/added at
/// will without losing ticks. Audit Q2.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/services/service_providers.dart';

/// Full-screen ignore-pointer overlay that paints between two
/// colours driven by a [ScreenFlashServiceProtocol].
class ScreenFlashOverlay extends ConsumerWidget {
  /// Creates the overlay.
  ///
  /// [primary] is shown on `true` ticks; [alternate] on `false`
  /// ticks. Defaults match the spec 05 §ScreenFlashService
  /// "white/red alternating" recommendation.
  const ScreenFlashOverlay({
    super.key,
    this.primary = Colors.white,
    this.alternate = const Color(0xFFE53935),
    this.providerOverride,
  });

  /// Colour painted on `true` ticks. Defaults to white.
  final Color primary;

  /// Colour painted on `false` ticks. Defaults to a strong red.
  final Color alternate;

  /// Optional override for the screen-flash provider — used by
  /// widget tests to inject a `FakeScreenFlashService` without
  /// going through `ProviderScope.overrideWith`.
  final Provider<ScreenFlashServiceProtocol>? providerOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(providerOverride ?? screenFlashServiceProvider);
    return StreamBuilder<bool>(
      stream: service.ticks,
      initialData: false,
      builder: (context, snap) {
        final on = snap.data ?? false;
        return IgnorePointer(
          ignoring: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: on ? primary : alternate,
          ),
        );
      },
    );
  }
}
