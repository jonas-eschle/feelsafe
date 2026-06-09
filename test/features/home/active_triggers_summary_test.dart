/// Widget tests for [ActiveTriggersSummaryDialog] (spec 04:456-468).
///
/// Verifies the on-tap summary renders the configured distress + disarm
/// triggers with brief config details, the "none configured" fallbacks,
/// the GPS prompt-at-start note (which proves the prompt stays in-session
/// per decision D4 — the dialog only mentions it, never collects coords),
/// and that the action buttons resolve proceed / cancel.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/features/home/widgets/active_triggers_summary.dart';
import '../../helpers/widget_test_helpers.dart';

ChainStep _holdStep() => ChainStep(
  id: 's0',
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

SessionMode _mode({
  List<DistressTrigger>? distress,
  List<DisarmTrigger>? disarm,
}) => SessionMode(
  id: 'm1',
  name: 'Walk',
  chainSteps: <ChainStep>[_holdStep()],
  distressTriggers: distress ?? const <DistressTrigger>[],
  disarmTriggers: disarm ?? const <DisarmTrigger>[],
);

/// Host that opens the dialog on first build and records the result.
class _Host extends StatefulWidget {
  const _Host({required this.mode});
  final SessionMode mode;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final r = await ActiveTriggersSummaryDialog.show(
              context,
              widget.mode,
            );
            setState(() => result = r);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}

Future<void> _open(WidgetTester tester, SessionMode mode) async {
  await pumpScreen(tester, _Host(mode: mode));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

bool? _hostResult(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host)).result;

void main() {
  testWidgets('renders both section headings', (WidgetTester tester) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(tester, _mode());
    expect(find.text(l10n.homeStartTriggersSummaryTitle), findsOneWidget);
    expect(find.text(l10n.homeStartTriggersDistressHeading), findsOneWidget);
    expect(find.text(l10n.homeStartTriggersDisarmHeading), findsOneWidget);
  });

  testWidgets('no triggers → "none configured" under each heading', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(tester, _mode());
    expect(find.text(l10n.homeStartTriggersNone), findsNWidgets(2));
  });

  testWidgets('repeat-press hardware distress trigger detail', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(
      tester,
      _mode(
        distress: const <DistressTrigger>[
          HardwareButtonDistressTrigger(
            buttonType: ButtonType.volumeDown,
            pressCount: 3,
          ),
        ],
      ),
    );
    expect(
      find.text(
        l10n.homeStartTriggerButtonRepeat(
          l10n.homeStartTriggerButtonVolumeDown,
          '3',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('long-press hardware distress trigger detail (trims .0)', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(
      tester,
      _mode(
        distress: const <DistressTrigger>[
          HardwareButtonDistressTrigger(
            pattern: PressPattern.longPress,
            pressCount: 0,
            durationSeconds: 2.0,
          ),
        ],
      ),
    );
    expect(
      find.text(
        l10n.homeStartTriggerButtonLong(
          l10n.homeStartTriggerButtonVolumeUp,
          '2',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'GPS prompt-at-start disarm trigger shows the arrival detail AND the '
    'in-session prompt note (decision D4)',
    (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _open(
        tester,
        _mode(
          disarm: const <DisarmTrigger>[
            // destinationSource defaults to promptAtStart (the case under
            // test) — left implicit to satisfy avoid_redundant_argument_values.
            GpsArrivalDisarmTrigger(radiusMeters: 150),
          ],
        ),
      );
      expect(
        find.textContaining(l10n.homeStartTriggerGpsArrival('150')),
        findsOneWidget,
      );
      // The note proves the dialog only *mentions* the prompt — it does not
      // collect coordinates here (the prompt stays in-session).
      expect(
        find.textContaining(l10n.homeStartTriggerGpsPrompt),
        findsOneWidget,
      );
    },
  );

  testWidgets('fixed-destination GPS trigger omits the prompt note', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(
      tester,
      _mode(
        disarm: const <DisarmTrigger>[
          GpsArrivalDisarmTrigger(
            radiusMeters: 300,
            destinationSource: GpsDestinationSource.fixed,
            lat: 1,
            lng: 2,
          ),
        ],
      ),
    );
    expect(find.textContaining(l10n.homeStartTriggerGpsPrompt), findsNothing);
  });

  testWidgets('timer disarm trigger detail in minutes', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(
      tester,
      _mode(
        disarm: const <DisarmTrigger>[
          TimerDisarmTrigger(durationSeconds: 1800),
        ],
      ),
    );
    expect(find.text(l10n.homeStartTriggerTimer('30')), findsOneWidget);
  });

  testWidgets('Start now returns true', (WidgetTester tester) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(tester, _mode());
    await tester.tap(find.text(l10n.homeStartTriggersContinue));
    await tester.pumpAndSettle();
    check(_hostResult(tester)).equals(true);
  });

  testWidgets('Cancel returns false', (WidgetTester tester) async {
    final l10n = await loadL10n(const Locale('en'));
    await _open(tester, _mode());
    await tester.tap(find.text(l10n.homeStartTriggersCancel));
    await tester.pumpAndSettle();
    check(_hostResult(tester)).equals(false);
  });
}
