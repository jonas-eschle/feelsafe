/// Stealth disguise router.
///
/// Reads the active session's effective `StealthConfig` and routes
/// to one of the three disguise screens — Music, Podcast, Calendar
/// — based on `StealthConfig.fakeIcon`. When the preset is
/// [StealthIconPreset.none] OR stealth is disabled, the caller
/// (SessionScreen) is responsible for rendering the real session
/// UI directly; this router never falls back to the real screen so
/// the layering stays explicit (one decision in one place).
///
/// Disarm gesture forwarding: every disguise screen calls back into
/// [_handleDisarm] which gates the request behind the session-end
/// PIN (per spec 04 §SessionScreen — Disarm) and then invokes
/// `SessionController.disarm()`. Wiring lives here, NOT in each
/// disguise screen, so the three screens stay declarative and the
/// PIN gate has a single owner.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/stealth/calendar_screen.dart';
import 'package:guardianangela/features/session/stealth/music_player_screen.dart';
import 'package:guardianangela/features/session/stealth/podcast_player_screen.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Router widget that picks a disguise screen based on
/// [StealthConfig.fakeIcon].
///
/// Returns `null` (i.e. the parent must show the real session
/// screen) when stealth is disabled or the preset is `none`. The
/// caller checks `shouldShow` before mounting this widget.
class StealthSessionScreen extends ConsumerWidget {
  /// Creates the disguise router.
  const StealthSessionScreen({super.key, required this.session});

  /// Snapshot of the active session — passed straight through to
  /// the disguise screens so they can render the timer.
  final WalkSession session;

  /// Returns `true` when [StealthSessionScreen] should be mounted
  /// for [stealth] (i.e. stealth is enabled AND a real disguise
  /// preset is selected). Callers use this to decide between the
  /// real session screen and the disguise router.
  static bool shouldShow(StealthConfig? stealth) {
    if (stealth == null) return false;
    if (!stealth.enabled) return false;
    return stealth.fakeIcon != StealthIconPreset.none;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stealth =
        ref.watch(settingsControllerProvider).value?.defaults.stealth ??
            const StealthConfig();

    Future<void> handleDisarm() async {
      final settings = await ref.read(settingsControllerProvider.future);
      if (!context.mounted) return;
      // Mirror the PIN gate from SessionScreen: when a session-end
      // PIN is configured, require it before disarming. Stealth
      // disguise users are an explicit threat-model match for "an
      // attacker is watching", so skipping the PIN here would
      // negate the disguise.
      final controller = ref.read(sessionControllerProvider.notifier);
      final sessionEndHash = settings.sessionEndPinHash;
      if (sessionEndHash == null) {
        await controller.disarm();
        return;
      }
      if (!context.mounted) return;
      final result = await showPinEntryDialog(
        context: context,
        sessionEndHash: sessionEndHash,
        duressHash: settings.duressPinHash,
        timeout: settings.pinTimeoutSeconds,
        biometric: settings.sessionEndPinBiometricEnabled
            ? ref.read(biometricServiceProvider)
            : null,
      );
      if (controller.handlePinResult(result)) {
        await controller.disarm();
      }
    }

    return switch (stealth.fakeIcon) {
      StealthIconPreset.music => MusicPlayerScreen(
          session: session,
          onDisarm: handleDisarm,
        ),
      StealthIconPreset.podcast => PodcastPlayerScreen(
          session: session,
          onDisarm: handleDisarm,
        ),
      StealthIconPreset.calendar => CalendarScreen(
          session: session,
          onDisarm: handleDisarm,
        ),
      // `none` should never reach this widget — `shouldShow` guards
      // the mount. Render an empty SizedBox as a safety net.
      StealthIconPreset.none => const SizedBox.shrink(),
    };
  }
}
