/// Reference widget test for the Phase 6 cohort.
///
/// Demonstrates the standard pattern every screen test follows
/// (`test/features/&lt;feature&gt;/&lt;feature&gt;_screen_test.dart`):
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

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/home/home_screen.dart';
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

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

SessionMode _mode(String id, String name) => SessionMode(
  id: id,
  name: name,
  chainSteps: <ChainStep>[
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
      await tester.tap(find.text(l10n.homeStartSession));
      await tester.pumpAndSettle();
      check(fake.startSessionCalls).equals(1);
      check(fake.lastStartSimulate).equals(false);
    });

    testWidgets('tapping Simulate calls startSession(simulate: true)', (
      WidgetTester tester,
    ) async {
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
      await tester.tap(find.text(l10n.homeSimulate));
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
        await tester.tap(find.text(l10n.homeStartSession));
        await tester.pumpAndSettle();
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
        await tester.tap(find.text(l10n.homeStartSession));
        await tester.pumpAndSettle();
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
}
