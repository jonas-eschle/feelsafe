/// Widget tests for [DisguisedReminderScreen] — the full-screen presentation
/// of a `fullScreen` disguised reminder (spec 02 §disguisedReminder Display
/// Styles). Covers rendering, the confirmation → disarm + pop path, and the
/// auto-pop when the engine moves on.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/disguised_reminder_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Minimal [SessionController] returning a fixed state and recording disarms.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;
  int disarmCalls = 0;

  @override
  Future<SessionState> build() async => _initial;

  @override
  void disarm() => disarmCalls++;
}

final ReminderTemplate _fullScreenTemplate = ReminderTemplate(
  id: 'fs',
  name: 'Calendar Event',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  confirmationType: ConfirmationType.tapButton,
  buttonLabel: 'Acknowledge',
  isCustom: false,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

SessionState _state({
  required SessionPhase phase,
  ReminderTemplate? template,
}) => SessionState(
  isSimulation: false,
  elapsedSeconds: 1,
  phase: phase,
  activeChain: <ChainStep>[
    ChainStep(
      id: 's0',
      type: ChainStepType.disguisedReminder,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
      config: const DisguisedReminderConfig(),
    ),
  ],
  currentStepIndex: 0,
  missCount: 0,
  isHolding: false,
  isPaused: false,
  isDistressChain: false,
  activeReminderTemplate: template,
);

Future<GoRouter> _pumpRoute(
  WidgetTester tester,
  _FakeSessionController fake,
) async {
  final router = GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/reminder',
        builder: (_, _) => const DisguisedReminderScreen(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionControllerProvider.overrideWith(() => fake)],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  unawaited(router.push('/reminder'));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the fullScreen disguise and its confirmation', (
    tester,
  ) async {
    final fake = _FakeSessionController(
      _state(phase: SessionPhase.duration, template: _fullScreenTemplate),
    );
    await _pumpRoute(tester, fake);
    expect(find.text('You have an appointment'), findsOneWidget);
    expect(find.text('Meeting with Alex at 3 PM'), findsOneWidget);
    expect(find.text('Acknowledge'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('confirming disarms and pops back', (tester) async {
    final fake = _FakeSessionController(
      _state(phase: SessionPhase.duration, template: _fullScreenTemplate),
    );
    await _pumpRoute(tester, fake);
    await tester.tap(find.text('Acknowledge'));
    await tester.pumpAndSettle();
    expect(fake.disarmCalls, 1);
    // Popped back to the host route.
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('auto-pops when the reminder is no longer active', (
    tester,
  ) async {
    // phase != duration → the route should close itself after the first frame.
    final fake = _FakeSessionController(
      _state(phase: SessionPhase.wait, template: _fullScreenTemplate),
    );
    await _pumpRoute(tester, fake);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('You have an appointment'), findsNothing);
  });
}
