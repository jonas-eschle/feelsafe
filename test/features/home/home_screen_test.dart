/// Reference widget test for the Phase 6 cohort.
///
/// Demonstrates the standard pattern every screen test follows
/// (`test/features/<feature>/<feature>_screen_test.dart`):
/// 1. Build a `_FakeHomeController` subclassing the real controller and
///    overriding `build()` to return a canned `HomeState`.
/// 2. In each `testWidgets` body, call `pumpScreen(tester, const
///    HomeScreen(), overrides: [homeControllerProvider.overrideWith(
///    () => _FakeHomeController(state))])`.
/// 3. Assert against the rendered widget tree using `find.byType`,
///    `find.text(l10n.homeStartSession)`, etc.
///
/// Why subclass instead of `overrideWithValue`: `AsyncNotifierProvider`
/// constructs a notifier via its factory; you cannot replace the value
/// directly. The subclass lets each test inject the AsyncValue it
/// needs (`AsyncData(state)`, `AsyncLoading()`, `AsyncError(e, st)`).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/home/widgets/active_triggers_summary.dart';
import 'package:guardianangela/features/home/widgets/chain_summary.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeHomeController extends HomeController {
  _FakeHomeController(this._initial, {this.startSessionResult = true});

  final HomeState _initial;

  /// Value returned by `startSession()`.
  final bool startSessionResult;

  int selectModeCalls = 0;
  String? lastSelectedMode;
  int startSessionCalls = 0;
  bool? lastStartSimulate;
  int clearErrorsCalls = 0;

  @override
  Future<HomeState> build() async => _initial;

  @override
  Future<void> selectMode(String modeId) async {
    selectModeCalls++;
    lastSelectedMode = modeId;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedModeId: modeId));
  }

  @override
  Future<bool> startSession({required bool simulate}) async {
    startSessionCalls++;
    lastStartSimulate = simulate;
    return startSessionResult;
  }

  @override
  void clearValidationErrors() {
    clearErrorsCalls++;
  }
}

/// Permission platform fake for the on-tap notification re-ask flow.
/// Reports a fixed status; counts requests.
class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  _FakePermissionHandlerPlatform({required this.status});

  final PermissionStatus status;
  int requestPermissionsCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      status;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requestPermissionsCalls++;
    return {for (final p in permissions) p: status};
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async => false;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

SessionMode _mode(
  String id,
  String name, {
  List<ChainStep>? chainSteps,
  String? iconName,
}) => SessionMode(
  id: id,
  name: name,
  iconName: iconName,
  chainSteps:
      chainSteps ??
      <ChainStep>[
        ChainStep(
          id: '$id-step-0',
          type: ChainStepType.holdButton,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      ],
);

ChainStep _step(
  String id,
  ChainStepType type, {
  int waitSeconds = 0,
  int durationSeconds = 30,
  int gracePeriodSeconds = 5,
  int retryCount = 0,
  int order = 0,
}) => ChainStep(
  id: id,
  type: type,
  order: order,
  waitSeconds: waitSeconds,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  retryCount: retryCount,
  randomize: false,
);

EmergencyContact _contact(String id, String name) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15550100',
  sortOrder: 0,
);

HomeState _state({
  List<SessionMode>? modes,
  List<EmergencyContact>? contacts,
  String? selectedModeId,
  List<ValidationIssue> errors = const <ValidationIssue>[],
}) => HomeState(
  modes: modes ?? <SessionMode>[],
  contacts: contacts ?? <EmergencyContact>[],
  selectedModeId: selectedModeId,
  lastValidationErrors: errors,
);

/// Installs a granted permission platform for the test so the on-tap
/// `ensureNotificationPermission` short-circuits to `true` without dialogs.
/// Restored on teardown.
void _installGrantedPerm(WidgetTester tester) {
  final original = PermissionHandlerPlatform.instance;
  PermissionHandlerPlatform.instance = _FakePermissionHandlerPlatform(
    status: PermissionStatus.granted,
  );
  addTearDown(() => PermissionHandlerPlatform.instance = original);
}

/// Taps Start, then proceeds past the Active Triggers Summary dialog.
Future<void> _tapStartAndProceed(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.text(l10n.homeStartSession));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.homeStartTriggersContinue));
  await tester.pumpAndSettle();
}

/// Fake [SessionController] for the cold-launch interrupted-prompt tests:
/// returns a canned [SessionState] (with or without the prior-interrupted
/// flags) without touching the database.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  @override
  Future<SessionState> build() async => _initial;

  // The HomeScreen calls this in didChangeDependencies; no-op for the test.
  @override
  void configureWidgetLabels({
    required String statusIdle,
    required String statusSession,
    required String statusSim,
    required String quickExit,
    required String fakeCall,
    String? foregroundServiceTitle,
    String? foregroundServiceBody,
    String? foregroundServiceStealthBody,
  }) {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen — AppBar', () {
    testWidgets('renders the Guardian Angela title in the app bar', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.text('Guardian Angela'), findsWidgets);
    });

    testWidgets('renders contacts, history, settings icon buttons', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });
  });

  group('HomeScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
        settle: false,
      );
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the body once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('HomeScreen — empty modes', () {
    testWidgets('shows the "no modes" banner when modes is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.text(l10n.homeNoModes), findsOneWidget);
    });
  });

  group('HomeScreen — mode chips', () {
    testWidgets('renders one ChoiceChip per mode', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk'), _mode('m2', 'Date')],
              ),
            ),
          ),
        ],
      );
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.text('Walk'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    });

    testWidgets('each chip carries its mode\'s persisted icon '
        '(spec 04:1479-1487)', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[
                  _mode('m1', 'Walk', iconName: 'directions_walk'),
                  _mode('m2', 'Date', iconName: 'restaurant'),
                ],
              ),
            ),
          ),
        ],
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Walk'),
            matching: find.byType(ChoiceChip),
          ),
          matching: find.byIcon(Icons.directions_walk),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Date'),
            matching: find.byType(ChoiceChip),
          ),
          matching: find.byIcon(Icons.restaurant),
        ),
        findsOneWidget,
      );
    });

    testWidgets('marks the selected mode chip as selected', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk'), _mode('m2', 'Date')],
                selectedModeId: 'm2',
              ),
            ),
          ),
        ],
      );
      final dateChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('Date'), matching: find.byType(ChoiceChip)),
      );
      check(dateChip.selected).isTrue();
      final walkChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('Walk'), matching: find.byType(ChoiceChip)),
      );
      check(walkChip.selected).isFalse();
    });

    testWidgets('tapping an unselected chip calls selectMode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeHomeController(
        _state(
          modes: <SessionMode>[_mode('m1', 'Walk'), _mode('m2', 'Date')],
          selectedModeId: 'm1',
        ),
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      check(fake.selectModeCalls).equals(1);
      check(fake.lastSelectedMode).equals('m2');
    });
  });

  group('HomeScreen — contact chips', () {
    testWidgets('shows the no-contacts banner when contacts is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.text(l10n.homeContactsBannerNone), findsOneWidget);
    });

    testWidgets('renders one ActionChip per contact up to 5', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
        _contact('c3', 'Carol'),
      ];
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state(contacts: contacts)),
          ),
        ],
      );
      expect(find.byType(ActionChip), findsNWidgets(3));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('shows +N overflow chip when >5 contacts', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        for (int i = 0; i < 7; i++) _contact('c$i', 'Person $i'),
      ];
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state(contacts: contacts)),
          ),
        ],
      );
      // 5 named chips + 1 "+2" overflow chip.
      expect(find.byType(ActionChip), findsNWidgets(6));
      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('HomeScreen — start / simulate buttons', () {
    testWidgets('Start Session button is disabled when no mode selected', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[_mode('m1', 'Walk')]),
            ),
          ),
        ],
      );
      final startBtn = tester.widget<FilledButton>(
        find.byType(FilledButton).first,
      );
      check(startBtn.onPressed).isNull();
    });

    testWidgets('Start Session button is enabled when a mode is selected', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk')],
                selectedModeId: 'm1',
              ),
            ),
          ),
        ],
      );
      final startBtn = tester.widget<FilledButton>(
        find.byType(FilledButton).first,
      );
      check(startBtn.onPressed).isNotNull();
    });

    testWidgets('Simulate button is disabled when no mode selected', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[_mode('m1', 'Walk')]),
            ),
          ),
        ],
      );
      final simBtn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      check(simBtn.onPressed).isNull();
    });

    testWidgets('tapping Start Session calls startSession(simulate: false)', (
      WidgetTester tester,
    ) async {
      _installGrantedPerm(tester);
      final fake = _FakeHomeController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk')], selectedModeId: 'm1'),
        startSessionResult: false,
      );
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      // Start now goes through the Active Triggers Summary (spec 04:456).
      await _tapStartAndProceed(tester, l10n);
      check(fake.startSessionCalls).equals(1);
      check(fake.lastStartSimulate).equals(false);
    });

    testWidgets('tapping Simulate calls startSession(simulate: true)', (
      WidgetTester tester,
    ) async {
      _installGrantedPerm(tester);
      final fake = _FakeHomeController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk')], selectedModeId: 'm1'),
        startSessionResult: false,
      );
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      // Simulate also goes through the summary + notif re-ask (spec 04:472).
      await tester.tap(find.text(l10n.homeSimulate));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.homeStartTriggersContinue));
      await tester.pumpAndSettle();
      check(fake.startSessionCalls).equals(1);
      check(fake.lastStartSimulate).equals(true);
    });
  });

  group('HomeScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
        locale: const Locale('ar'),
      );
      // Smoke: AppBar with at least one icon, no exceptions during pump.
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HomeScreen — accessibility', () {
    testWidgets('app bar icon buttons expose tooltips', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );
      expect(find.byTooltip(l10n.homeMenuContacts), findsOneWidget);
      expect(find.byTooltip(l10n.homeMenuHistory), findsOneWidget);
      expect(find.byTooltip(l10n.homeMenuSettings), findsOneWidget);
    });
  });

  group('HomeScreen — validation errors', () {
    testWidgets(
      'Start with failing validation surfaces error dialog with each issue '
      'title',
      (WidgetTester tester) async {
        _installGrantedPerm(tester);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeHomeController(
          _state(
            modes: <SessionMode>[_mode('walk', 'Walk Mode')],
            selectedModeId: 'walk',
            errors: <ValidationIssue>[
              const ValidationIssue(
                title: 'No contacts configured',
                description: 'Add at least one emergency contact.',
              ),
              const ValidationIssue(
                title: 'Location permission missing',
                description: 'Grant location permission for GPS tracking.',
              ),
            ],
          ),
          startSessionResult: false,
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await _tapStartAndProceed(tester, l10n);
        expect(find.text(l10n.sessionStartFailedTitle), findsOneWidget);
        expect(find.textContaining('No contacts configured'), findsOneWidget);
        expect(
          find.textContaining('Location permission missing'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Dismissing the start-failed dialog calls clearValidationErrors',
      (WidgetTester tester) async {
        _installGrantedPerm(tester);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeHomeController(
          _state(
            modes: <SessionMode>[_mode('walk', 'Walk Mode')],
            selectedModeId: 'walk',
            errors: <ValidationIssue>[
              const ValidationIssue(
                title: 'No contacts configured',
                description: 'Add at least one emergency contact.',
              ),
            ],
          ),
          startSessionResult: false,
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await _tapStartAndProceed(tester, l10n);
        await tester.tap(find.text(l10n.commonOk));
        await tester.pumpAndSettle();
        check(fake.clearErrorsCalls).equals(1);
      },
    );
  });

  group('HomeScreen — empty contacts banner content', () {
    testWidgets(
      'no-contacts banner is rendered while contact chips section is empty',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(
              () => _FakeHomeController(_state()),
            ),
          ],
        );
        expect(find.text(l10n.homeContactsBannerNone), findsOneWidget);
      },
    );
  });

  group('HomeScreen — contact overflow chip', () {
    testWidgets(
      'overflow chip shows the exact remaining count for 8 contacts',
      (WidgetTester tester) async {
        final contacts = <EmergencyContact>[
          for (int i = 1; i <= 8; i++) _contact('c$i', 'Contact $i'),
        ];
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(
              () => _FakeHomeController(_state(contacts: contacts)),
            ),
          ],
        );
        // 8 total contacts → first 5 visible, overflow chip shows "+3".
        expect(find.textContaining('+3'), findsOneWidget);
        expect(find.text('Contact 6'), findsNothing);
      },
    );
  });

  group('HomeScreen — start / simulate buttons selection sticky', () {
    testWidgets(
      'tapping a different mode chip changes the selection on the screen',
      (WidgetTester tester) async {
        final fake = _FakeHomeController(
          _state(
            modes: <SessionMode>[
              _mode('walk', 'Walk Mode'),
              _mode('date', 'Date Mode'),
            ],
            selectedModeId: 'walk',
          ),
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await tester.tap(find.text('Date Mode'));
        await tester.pumpAndSettle();
        check(fake.selectModeCalls).equals(1);
        check(fake.lastSelectedMode).equals('date');
      },
    );
  });

  group('HomeScreen — simulate button enabled state', () {
    testWidgets('Simulate button is enabled when a mode is selected', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('walk', 'Walk Mode')],
                selectedModeId: 'walk',
              ),
            ),
          ),
        ],
      );
      final simulate = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text(l10n.homeSimulate),
          matching: find.byType(OutlinedButton),
        ),
      );
      check(simulate.onPressed).isNotNull();
    });
  });

  // ── Chain Summary (spec 04:429-439) ─────────────────────────────────────
  group('HomeScreen — chain summary', () {
    testWidgets('renders a ChainSummary card when a mode is selected', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final mode = _mode(
        'walk',
        'Walk Mode',
        chainSteps: <ChainStep>[
          _step('walk-0', ChainStepType.holdButton),
          _step('walk-1', ChainStepType.fakeCall, order: 1),
          _step('walk-2', ChainStepType.smsContact, order: 2),
        ],
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[mode], selectedModeId: 'walk'),
            ),
          ),
        ],
      );
      expect(find.byType(ChainSummary), findsOneWidget);
      expect(find.text(l10n.homeChainSummaryTitle), findsOneWidget);
      // Every step name appears in the pill row.
      expect(find.text(l10n.chainStepNameHoldButton), findsOneWidget);
      expect(find.text(l10n.chainStepNameFakeCall), findsOneWidget);
      expect(find.text(l10n.chainStepNameSmsContact), findsOneWidget);
    });

    testWidgets('does NOT render the Chain Summary when no modes exist', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state(modes: <SessionMode>[])),
          ),
        ],
      );
      expect(find.byType(ChainSummary), findsNothing);
    });

    testWidgets('tapping a pill opens the timing-details bottom sheet', (
      WidgetTester tester,
    ) async {
      // Verifies: pill is interactive, sheet shows the step name,
      // wait/active/grace/retry rows, AND the "next step" row resolves
      // to the next step in the chain (not "end of chain").
      final l10n = await loadL10n(const Locale('en'));
      final mode = _mode(
        'walk',
        'Walk Mode',
        chainSteps: <ChainStep>[
          _step(
            'walk-0',
            ChainStepType.fakeCall,
            waitSeconds: 2,
            retryCount: 1,
          ),
          _step('walk-1', ChainStepType.smsContact, order: 1),
        ],
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[mode], selectedModeId: 'walk'),
            ),
          ),
        ],
      );
      // Tap the fakeCall pill.
      await tester.tap(find.text(l10n.chainStepNameFakeCall));
      await tester.pumpAndSettle();
      expect(find.byType(ChainStepTimingSheet), findsOneWidget);
      expect(
        find.text(l10n.homeChainSummaryTimingTitle(l10n.chainStepNameFakeCall)),
        findsOneWidget,
      );
      expect(find.text(l10n.homeChainSummaryWait('2')), findsOneWidget);
      expect(find.text(l10n.homeChainSummaryDuration('30')), findsOneWidget);
      expect(find.text(l10n.homeChainSummaryGrace('5')), findsOneWidget);
      expect(find.text(l10n.homeChainSummaryRetry('1')), findsOneWidget);
      // The next step is smsContact.
      expect(
        find.text(l10n.homeChainSummaryNextStep(l10n.chainStepNameSmsContact)),
        findsOneWidget,
      );
    });

    testWidgets(
      'timing-details on the LAST step shows "end of chain" not a next step',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final mode = _mode(
          'walk',
          'Walk Mode',
          chainSteps: <ChainStep>[
            _step('walk-0', ChainStepType.holdButton),
            _step('walk-1', ChainStepType.smsContact, order: 1),
          ],
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(
              () => _FakeHomeController(
                _state(modes: <SessionMode>[mode], selectedModeId: 'walk'),
              ),
            ),
          ],
        );
        await tester.tap(find.text(l10n.chainStepNameSmsContact));
        await tester.pumpAndSettle();
        expect(find.text(l10n.homeChainSummaryNextStepNone), findsOneWidget);
      },
    );

    testWidgets('Close button dismisses the timing-details sheet', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final mode = _mode('walk', 'Walk Mode');
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[mode], selectedModeId: 'walk'),
            ),
          ),
        ],
      );
      await tester.tap(find.text(l10n.chainStepNameHoldButton));
      await tester.pumpAndSettle();
      expect(find.byType(ChainStepTimingSheet), findsOneWidget);
      await tester.tap(find.text(l10n.homeChainSummaryClose));
      await tester.pumpAndSettle();
      expect(find.byType(ChainStepTimingSheet), findsNothing);
    });
  });

  // ── On-tap flow: Active Triggers Summary + notif re-ask (spec 04:456-468) ─
  group('HomeScreen — on-tap start flow', () {
    /// Swaps the permission platform for the duration of the test so the
    /// real `ensureNotificationPermission` (invoked by `_onStart`) sees a
    /// pinned status. The home screen renders on Android by default in the
    /// test VM, so the helper's Android branch runs.
    _FakePermissionHandlerPlatform installPerm(PermissionStatus status) {
      final perm = _FakePermissionHandlerPlatform(status: status);
      final original = PermissionHandlerPlatform.instance;
      PermissionHandlerPlatform.instance = perm;
      addTearDown(() => PermissionHandlerPlatform.instance = original);
      return perm;
    }

    SessionMode notifMode() => _mode(
      'm1',
      'Walk',
      chainSteps: <ChainStep>[_step('s0', ChainStepType.disguisedReminder)],
    );

    testWidgets('tapping Start shows the Active Triggers Summary first', (
      WidgetTester tester,
    ) async {
      installPerm(PermissionStatus.granted);
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeHomeController(
        _state(modes: <SessionMode>[notifMode()], selectedModeId: 'm1'),
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      await tester.tap(find.text(l10n.homeStartSession));
      await tester.pumpAndSettle();
      expect(find.byType(ActiveTriggersSummaryDialog), findsOneWidget);
      // The summary appears BEFORE the session starts.
      check(fake.startSessionCalls).equals(0);
    });

    testWidgets('cancelling the summary aborts the start', (
      WidgetTester tester,
    ) async {
      final perm = installPerm(PermissionStatus.granted);
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeHomeController(
        _state(modes: <SessionMode>[notifMode()], selectedModeId: 'm1'),
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      await tester.tap(find.text(l10n.homeStartSession));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.homeStartTriggersCancel));
      await tester.pumpAndSettle();
      check(fake.startSessionCalls).equals(0);
      check(perm.requestPermissionsCalls).equals(0);
    });

    testWidgets(
      'granted permission → summary Start now → startSession is called',
      (WidgetTester tester) async {
        installPerm(PermissionStatus.granted);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeHomeController(
          _state(modes: <SessionMode>[notifMode()], selectedModeId: 'm1'),
          startSessionResult: false,
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await tester.tap(find.text(l10n.homeStartSession));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.homeStartTriggersContinue));
        await tester.pumpAndSettle();
        check(fake.startSessionCalls).equals(1);
        // No block dialog when permission is granted.
        expect(find.text(l10n.homeStartBlockedNotifTitle), findsNothing);
      },
    );

    testWidgets(
      'denied permission + notification-dependent chain → BLOCKED (no start)',
      (WidgetTester tester) async {
        installPerm(PermissionStatus.permanentlyDenied);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeHomeController(
          _state(modes: <SessionMode>[notifMode()], selectedModeId: 'm1'),
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await tester.tap(find.text(l10n.homeStartSession));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.homeStartTriggersContinue));
        await tester.pumpAndSettle();
        // The permanently-denied dialog shows; declining it leaves perm off.
        await tester.tap(find.text(l10n.permissionNotifNotNow));
        await tester.pumpAndSettle();
        // Start is blocked with the inline warning; session never starts.
        expect(find.text(l10n.homeStartBlockedNotifTitle), findsOneWidget);
        check(fake.startSessionCalls).equals(0);
      },
    );

    testWidgets(
      'denied permission + notification-free chain → ALLOWED (starts anyway)',
      (WidgetTester tester) async {
        installPerm(PermissionStatus.permanentlyDenied);
        final l10n = await loadL10n(const Locale('en'));
        // Default _mode() chain is holdButton only — needs no notifications.
        final fake = _FakeHomeController(
          _state(
            modes: <SessionMode>[_mode('m1', 'Walk')],
            selectedModeId: 'm1',
          ),
          startSessionResult: false,
        );
        await pumpScreen(
          tester,
          const HomeScreen(),
          overrides: <Override>[
            homeControllerProvider.overrideWith(() => fake),
          ],
        );
        await tester.tap(find.text(l10n.homeStartSession));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.homeStartTriggersContinue));
        await tester.pumpAndSettle();
        // Permanently-denied dialog still shows (the helper always re-asks),
        // but a holdButton-only chain is NOT blocked by a denial.
        await tester.tap(find.text(l10n.permissionNotifNotNow));
        await tester.pumpAndSettle();
        expect(find.text(l10n.homeStartBlockedNotifTitle), findsNothing);
        check(fake.startSessionCalls).equals(1);
      },
    );
  });

  group('HomeScreen — interrupted prompt at cold launch (Extra 13)', () {
    testWidgets('surfaces the interrupted modal instead of the dashboard', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final session = _FakeSessionController(
        const SessionState.initial().copyWith(
          priorInterrupted: true,
          priorModeId: 'mode-1',
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk Mode')],
                selectedModeId: 'm1',
              ),
            ),
          ),
          sessionControllerProvider.overrideWith(() => session),
        ],
      );
      // The modal is shown; the normal home Start button is NOT.
      expect(find.text(l10n.sessionInterruptedTitle), findsOneWidget);
      expect(
        find.text(l10n.sessionInterruptedMode('Walk Mode')),
        findsOneWidget,
      );
      expect(find.text(l10n.sessionInterruptedStartSameMode), findsOneWidget);
      expect(find.text(l10n.homeStartSession), findsNothing);
    });

    testWidgets('no prior interruption → the dashboard renders normally', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final session = _FakeSessionController(const SessionState.initial());
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk Mode')],
                selectedModeId: 'm1',
              ),
            ),
          ),
          sessionControllerProvider.overrideWith(() => session),
        ],
      );
      expect(find.text(l10n.sessionInterruptedTitle), findsNothing);
      expect(find.text(l10n.homeStartSession), findsOneWidget);
    });
  });

  group('HomeScreen — async branches', () {
    testWidgets('shows the loading spinner while the controller builds', (
      WidgetTester tester,
    ) async {
      // Non-const construction on purpose: pins the DA row for the const
      // constructor (const instantiations are canonicalized away by the
      // compiler and report 0 hits — known lcov jitter).
      await pumpScreen(
        tester,
        HomeScreen(key: UniqueKey()),
        overrides: <Override>[
          homeControllerProvider.overrideWith(_NeverController.new),
        ],
        settle: false,
      );
      await tester.pump();
      final l10n = await loadL10n(const Locale('en'));
      // The body spinner from `stateAsync.when(loading: ...)` — the home
      // dashboard must never flash while modes are loading.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.homeStartSession), findsNothing);
    });

    testWidgets('surfaces a controller build failure as an error body', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(_ThrowingController.new),
        ],
        settle: false,
      );
      await tester.pump();
      await tester.pump();
      final l10n = await loadL10n(const Locale('en'));
      expect(
        find.text(l10n.commonErrorWithDetail('Bad state: home db unavailable')),
        findsOneWidget,
      );
    });
  });

  group('HomeScreen — chain summary fallback selection', () {
    testWidgets('a stale selectedModeId falls back to the first mode chain', (
      WidgetTester tester,
    ) async {
      final m1 = _mode('m1', 'Walk');
      final m2 = _mode(
        'm2',
        'Date',
        chainSteps: <ChainStep>[_step('m2-s0', ChainStepType.loudAlarm)],
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(modes: <SessionMode>[m1, m2], selectedModeId: 'ghost'),
            ),
          ),
        ],
      );
      final ChainSummary summary = tester.widget<ChainSummary>(
        find.byType(ChainSummary),
      );
      // orElse fallback: ghost id → first mode's steps, never m2's.
      check(summary.steps.map((s) => s.id)).deepEquals(<String>['m1-step-0']);
    });
  });

  group('HomeScreen — contact chips are inert pop targets', () {
    testWidgets('tapping a contact chip or the overflow chip stays on home', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final contacts = <EmergencyContact>[
        for (int i = 1; i <= 6; i++) _contact('c$i', 'Contact $i'),
      ];
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(
              _state(
                modes: <SessionMode>[_mode('m1', 'Walk')],
                selectedModeId: 'm1',
                contacts: contacts,
              ),
            ),
          ),
        ],
      );
      await tester.tap(find.text('Contact 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();
      // maybePop on the root route is a no-op — home keeps rendering.
      expect(find.text(l10n.homeStartSession), findsOneWidget);
      expect(find.text('Contact 1'), findsOneWidget);
    });
  });

  group('HomeScreen — notification-blocked dialog dismissal', () {
    testWidgets('OK dismisses the blocked warning; still no start', (
      WidgetTester tester,
    ) async {
      final original = PermissionHandlerPlatform.instance;
      PermissionHandlerPlatform.instance = _FakePermissionHandlerPlatform(
        status: PermissionStatus.permanentlyDenied,
      );
      addTearDown(() => PermissionHandlerPlatform.instance = original);
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeHomeController(
        _state(
          modes: <SessionMode>[
            _mode(
              'm1',
              'Walk',
              chainSteps: <ChainStep>[
                _step('m1-s0', ChainStepType.disguisedReminder),
              ],
            ),
          ],
          selectedModeId: 'm1',
        ),
      );
      await pumpScreen(
        tester,
        const HomeScreen(),
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );
      await _tapStartAndProceed(tester, l10n);
      await tester.tap(find.text(l10n.permissionNotifNotNow));
      await tester.pumpAndSettle();
      expect(find.text(l10n.homeStartBlockedNotifTitle), findsOneWidget);

      await tester.tap(find.text(l10n.commonOk));
      await tester.pumpAndSettle();

      expect(find.text(l10n.homeStartBlockedNotifTitle), findsNothing);
      check(fake.startSessionCalls).equals(0);
    });
  });

  group('HomeScreen — router navigation', () {
    testWidgets('app bar actions push contacts / history / settings', (
      WidgetTester tester,
    ) async {
      final nav = await _pumpHomeWithRouter(
        tester,
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      check(nav.pushed).deepEquals(<String>[RouteNames.contacts]);
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      check(nav.pushed.last).equals(RouteNames.pastEvents);
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      check(nav.pushed.last).equals(RouteNames.settings);
    });

    testWidgets('a successful start navigates to /session', (
      WidgetTester tester,
    ) async {
      _installGrantedPerm(tester);
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeHomeController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk')], selectedModeId: 'm1'),
      );
      final nav = await _pumpHomeWithRouter(
        tester,
        overrides: <Override>[homeControllerProvider.overrideWith(() => fake)],
      );

      await _tapStartAndProceed(tester, l10n);

      check(fake.startSessionCalls).equals(1);
      check(nav.pushed).deepEquals(<String>[RouteNames.session]);
    });
  });

  group('HomeScreen — widget deep-link routing', () {
    testWidgets('cold-start widget URI routes to the fake call screen', (
      WidgetTester tester,
    ) async {
      _mockHomeWidgetChannel(
        tester,
        coldStartUri: 'guardianangela://fake-call',
      );
      final nav = await _pumpHomeWithRouter(
        tester,
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );

      check(nav.pushed).deepEquals(<String>[RouteNames.fakeCall]);
    });

    testWidgets(
      'quick-exit tap with an active session pushes /session?quickExit=true',
      (WidgetTester tester) async {
        _mockHomeWidgetChannel(tester);
        final clicks = _mockWidgetClickStream(tester);
        final nav = await _pumpHomeWithRouter(
          tester,
          overrides: <Override>[
            homeControllerProvider.overrideWith(
              () => _FakeHomeController(_state()),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(
                const SessionState.initial().copyWith(phase: SessionPhase.wait),
              ),
            ),
          ],
        );

        clicks.emit('guardianangela://quick-exit');
        await tester.pumpAndSettle();

        check(nav.pushed).deepEquals(<String>[RouteNames.session]);
        check(nav.lastQuery).deepEquals(<String, String>{'quickExit': 'true'});
      },
    );

    testWidgets('quick-exit tap with no active session is a no-op', (
      WidgetTester tester,
    ) async {
      _mockHomeWidgetChannel(tester);
      final clicks = _mockWidgetClickStream(tester);
      final nav = await _pumpHomeWithRouter(
        tester,
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(const SessionState.initial()),
          ),
        ],
      );

      clicks.emit('guardianangela://quick-exit');
      await tester.pumpAndSettle();

      check(nav.pushed).isEmpty();
    });

    testWidgets('foreign schemes and unknown hosts are ignored', (
      WidgetTester tester,
    ) async {
      _mockHomeWidgetChannel(tester);
      final clicks = _mockWidgetClickStream(tester);
      final nav = await _pumpHomeWithRouter(
        tester,
        overrides: <Override>[
          homeControllerProvider.overrideWith(
            () => _FakeHomeController(_state()),
          ),
        ],
      );

      clicks.emit('https://example.com/fake-call');
      await tester.pumpAndSettle();
      clicks.emit('guardianangela://unknown-action');
      await tester.pumpAndSettle();

      check(nav.pushed).isEmpty();
    });
  });
}

// ---------------------------------------------------------------------------
// Router pump + home_widget channel mocks (deep-link routing tests)
// ---------------------------------------------------------------------------

/// Controller whose build never completes — pins the loading branch.
class _NeverController extends HomeController {
  @override
  Future<HomeState> build() => Completer<HomeState>().future;
}

/// Controller whose build throws — pins the error branch.
class _ThrowingController extends HomeController {
  @override
  Future<HomeState> build() async => throw StateError('home db unavailable');
}

/// Records every named push reaching a non-home route.
class _RecordedNav {
  final List<String> pushed = <String>[];
  Map<String, String> lastQuery = const <String, String>{};
}

/// Pumps [HomeScreen] under a GoRouter shell whose child routes record
/// their own activation, so tests can assert `context.pushNamed` calls.
Future<_RecordedNav> _pumpHomeWithRouter(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  final nav = _RecordedNav();
  final router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
        routes: <RouteBase>[
          for (final name in <String>[
            RouteNames.contacts,
            RouteNames.pastEvents,
            RouteNames.settings,
            RouteNames.session,
            RouteNames.fakeCall,
          ])
            GoRoute(
              path: name,
              name: name,
              builder: (_, GoRouterState s) {
                nav.pushed.add(name);
                nav.lastQuery = Map<String, String>.of(s.uri.queryParameters);
                return Scaffold(body: Text('route:$name'));
              },
            ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return nav;
}

/// Mocks the `home_widget` MethodChannel. [coldStartUri] is returned from
/// `initiallyLaunchedFromHomeWidget` (null = not launched via widget).
void _mockHomeWidgetChannel(WidgetTester tester, {String? coldStartUri}) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('home_widget'),
    (MethodCall call) async {
      if (call.method == 'initiallyLaunchedFromHomeWidget') {
        return coldStartUri;
      }
      return true;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      null,
    ),
  );
}

/// Captured sink of the mocked `home_widget/updates` EventChannel.
///
/// Lets a test emit a widget-tap URI AFTER the screen has settled, so the
/// session-controller state the handler reads is already resolved.
class _WidgetClickStream {
  MockStreamHandlerEventSink? _sink;

  /// Emits one foreground widget-tap [uri] to the subscribed screen.
  void emit(String uri) {
    final sink = _sink;
    if (sink == null) {
      throw StateError('emit() before the screen subscribed to the stream.');
    }
    sink.success(uri);
  }
}

/// Mocks the `home_widget/updates` EventChannel (the foreground
/// widget-tap stream) and returns a handle for emitting URIs.
_WidgetClickStream _mockWidgetClickStream(WidgetTester tester) {
  final stream = _WidgetClickStream();
  tester.binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('home_widget/updates'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink sink) {
        stream._sink = sink;
      },
    ),
  );
  return stream;
}
