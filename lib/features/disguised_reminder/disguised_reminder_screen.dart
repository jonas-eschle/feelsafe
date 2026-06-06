import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_confirmation.dart';
import 'package:guardianangela/features/session/session_controller.dart';

/// Full-screen presentation of a `fullScreen` disguised reminder.
///
/// Pushed by [SessionScreen] when a `disguisedReminder` fires with a template
/// whose [ReminderDisplayStyle] is [ReminderDisplayStyle.fullScreen] — it takes
/// over the screen "like a calendar event full-screen notification" (spec 02
/// §disguisedReminder Display Styles), hiding the session chrome so a glance
/// reveals only the disguise.
///
/// It mirrors [FakeCallScreen]: orientation is locked to portrait and back
/// navigation is disabled ([PopScope]). The user checks in through the
/// template's confirmation interaction; the screen also auto-pops if the
/// engine moves on (the reminder was missed and the chain advanced, or the
/// user disarmed elsewhere) so it never lingers past its reminder.
class DisguisedReminderScreen extends ConsumerStatefulWidget {
  /// Creates a [DisguisedReminderScreen].
  const DisguisedReminderScreen({super.key});

  @override
  ConsumerState<DisguisedReminderScreen> createState() =>
      _DisguisedReminderScreenState();
}

class _DisguisedReminderScreenState
    extends ConsumerState<DisguisedReminderScreen> {
  /// Guards [_close] so the route is popped exactly once whether the user
  /// confirms or the engine moves on first.
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  /// Returns the template to render, or null when this route should close —
  /// the reminder is no longer the active full-screen disguise.
  ReminderTemplate? _activeTemplate(SessionState? state) {
    if (state == null) return null;
    if (state.phase != SessionPhase.duration) return null;
    if (state.currentStep?.type != ChainStepType.disguisedReminder) return null;
    final template = state.activeReminderTemplate;
    if (template == null) return null;
    if (template.displayStyle != ReminderDisplayStyle.fullScreen) return null;
    return template;
  }

  void _close() {
    if (_popped || !mounted) return;
    _popped = true;
    if (context.canPop()) {
      context.pop();
    }
  }

  void _confirm() {
    // The in-character check-in. Disarm resets the chain to step 0; the engine
    // then leaves the duration phase, but we pop immediately for responsiveness
    // (the auto-pop path is the fallback for the missed/external case).
    ref.read(sessionControllerProvider.notifier).disarm();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sessionControllerProvider);
    final template = _activeTemplate(async.value);
    if (template == null) {
      // The reminder ended (missed → advanced, or disarmed elsewhere). Close
      // after this frame — but only once the controller has resolved, so the
      // brief loading frame on mount does not pop the route prematurely.
      if (!async.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _close());
      }
      return const Scaffold(body: SizedBox.expand());
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: ReminderDisguiseContent(
                  template: template,
                  onConfirm: _confirm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
