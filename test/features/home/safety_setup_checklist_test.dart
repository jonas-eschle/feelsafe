/// Widget tests for [SafetySetupChecklist].
///
/// Mounts the widget directly inside a minimal ProviderScope so tests
/// can assert against item completion / dismissal / collapse / tap
/// navigation without depending on a real HomeScreen or GoRouter beyond
/// the routes the widget actually pushes.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/home/home_checklist_repository.dart';
import 'package:guardianangela/features/home/widgets/safety_setup_checklist.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

/// In-memory [HomeChecklistRepository] subclass. Bypasses
/// SharedPreferences entirely so tests run in any environment.
class _FakeChecklistRepository extends HomeChecklistRepository {
  _FakeChecklistRepository({
    bool dismissed = false,
    bool simulationDone = false,
    bool firstVisitDone = false,
    bool allDoneCelebrated = false,
  }) : _dismissed = dismissed,
       _simulationDone = simulationDone,
       _firstVisitDone = firstVisitDone,
       _allDoneCelebrated = allDoneCelebrated;

  bool _dismissed;
  bool _simulationDone;
  bool _firstVisitDone;
  bool _allDoneCelebrated;
  int dismissCalls = 0;
  int markSimulationDoneCalls = 0;
  int markFirstVisitDoneCalls = 0;
  int markAllDoneCelebratedCalls = 0;

  @override
  Future<bool> dismissed() async => _dismissed;

  @override
  Future<void> setDismissed() async {
    dismissCalls++;
    _dismissed = true;
  }

  @override
  Future<bool> simulationDone() async => _simulationDone;

  @override
  Future<void> markSimulationDone() async {
    markSimulationDoneCalls++;
    _simulationDone = true;
  }

  @override
  Future<bool> firstVisitDone() async => _firstVisitDone;

  @override
  Future<void> markFirstVisitDone() async {
    markFirstVisitDoneCalls++;
    _firstVisitDone = true;
  }

  @override
  Future<bool> allDoneCelebrated() async => _allDoneCelebrated;

  @override
  Future<void> markAllDoneCelebrated() async {
    markAllDoneCelebratedCalls++;
    _allDoneCelebrated = true;
  }
}

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository({AppSettings? initial})
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('safety_checklist_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

/// Permission platform fake used to prove item 6 delegates to the shared
/// `ensureNotificationPermission` helper (its rationale dialog appears).
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

EmergencyContact _contact(String id, String name) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15550100',
  sortOrder: 0,
);

SessionMode _mode(String id, String name, {List<ChainStep>? chainSteps}) =>
    SessionMode(
      id: id,
      name: name,
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

AppSettings _settings({
  String? sessionEndPinHash,
  bool stealthEnabled = false,
}) => AppSettings(
  sessionEndPinHash: sessionEndPinHash,
  defaults: AppDefaults(stealth: StealthConfig(enabled: stealthEnabled)),
);

// ---------------------------------------------------------------------------
// Pump helper
// ---------------------------------------------------------------------------

Future<_PushedRoute> _pump(
  WidgetTester tester, {
  List<EmergencyContact> contacts = const <EmergencyContact>[],
  List<SessionMode> modes = const <SessionMode>[],
  _FakeChecklistRepository? repo,
  _FakeAppSettingsRepository? settingsRepo,
  Future<bool> Function()? permissionLookup,
  Future<bool> Function()? permissionRequester,
}) async {
  final pushed = _PushedRoute();
  final router = GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (_, _) => Material(
          child: SafetySetupChecklist(
            contacts: contacts,
            modes: modes,
            // Default the lookup to "denied" so the test does not hang
            // waiting on the real `permission_handler` platform channel.
            permissionLookup: permissionLookup ?? () async => false,
            permissionRequester: permissionRequester ?? () async => false,
          ),
        ),
        routes: <GoRoute>[
          for (final name in <String>[
            RouteNames.contactForm,
            RouteNames.pinSetup,
            RouteNames.settingsStealth,
            RouteNames.modes,
          ])
            GoRoute(
              path: name,
              name: name,
              builder: (_, GoRouterState state) {
                pushed.lastPushed = name;
                pushed.lastQueryParameters = Map<String, String>.from(
                  state.uri.queryParameters,
                );
                return _Blank(routeName: name);
              },
            ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        homeChecklistRepositoryProvider.overrideWithValue(
          repo ?? _FakeChecklistRepository(),
        ),
        appSettingsRepositoryProvider.overrideWithValue(
          settingsRepo ?? _FakeAppSettingsRepository(),
        ),
      ],
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
  return pushed;
}

/// Captures the name + query params of the last GoRouter push so tests
/// can assert tap-to-navigate behavior.
class _PushedRoute {
  String? lastPushed;
  Map<String, String> lastQueryParameters = <String, String>{};
}

class _Blank extends StatelessWidget {
  const _Blank({required this.routeName});
  final String routeName;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text('route: $routeName'));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SafetySetupChecklist — render', () {
    testWidgets('renders the card with title + progress when nothing is done', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.homeChecklistTitle), findsOneWidget);
      expect(find.text(l10n.homeChecklistProgress('0', '6')), findsOneWidget);
      // All 6 item titles render in the expanded card.
      expect(find.text(l10n.homeChecklistItem1Title), findsOneWidget);
      expect(find.text(l10n.homeChecklistItem6Title), findsOneWidget);
    });

    testWidgets('renders nothing when dismissed flag is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeChecklistRepository(dismissed: true);
      await _pump(tester, repo: repo);
      expect(find.text(l10n.homeChecklistTitle), findsNothing);
    });
  });

  group('SafetySetupChecklist — all-done banner', () {
    testWidgets(
      'shows the "all set" banner when all 6 items are done (first visit)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final repo = _FakeChecklistRepository(simulationDone: true);
        await _pump(
          tester,
          contacts: <EmergencyContact>[_contact('c0', 'Alice')],
          modes: <SessionMode>[_mode('custom-1', 'Custom')],
          repo: repo,
          settingsRepo: _FakeAppSettingsRepository(
            initial: _settings(sessionEndPinHash: 'hash', stealthEnabled: true),
          ),
          permissionLookup: () async => true,
        );
        // The checklist card is gone; the celebration banner takes over.
        expect(find.text(l10n.homeChecklistTitle), findsNothing);
        expect(find.text(l10n.homeChecklistAllDoneBanner), findsOneWidget);
        expect(
          find.byKey(const Key('safety-setup-all-done-banner')),
          findsOneWidget,
        );
        // Flag persisted so the banner is a one-time celebration.
        check(repo.markAllDoneCelebratedCalls).equals(1);
      },
    );

    testWidgets(
      'renders nothing once the banner was already shown (subsequent visit)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final repo = _FakeChecklistRepository(
          simulationDone: true,
          allDoneCelebrated: true,
        );
        await _pump(
          tester,
          contacts: <EmergencyContact>[_contact('c0', 'Alice')],
          modes: <SessionMode>[_mode('custom-1', 'Custom')],
          repo: repo,
          settingsRepo: _FakeAppSettingsRepository(
            initial: _settings(sessionEndPinHash: 'hash', stealthEnabled: true),
          ),
          permissionLookup: () async => true,
        );
        expect(find.text(l10n.homeChecklistTitle), findsNothing);
        expect(find.text(l10n.homeChecklistAllDoneBanner), findsNothing);
        // No re-persist when it was already celebrated.
        check(repo.markAllDoneCelebratedCalls).equals(0);
      },
    );

    testWidgets(
      'completing the final item shows the banner and persists once',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // 5/6 done; the notification permission is the only missing item.
        final repo = _FakeChecklistRepository(simulationDone: true);
        await _pump(
          tester,
          contacts: <EmergencyContact>[_contact('c0', 'Alice')],
          modes: <SessionMode>[_mode('custom-1', 'Custom')],
          repo: repo,
          settingsRepo: _FakeAppSettingsRepository(
            initial: _settings(sessionEndPinHash: 'hash', stealthEnabled: true),
          ),
          permissionLookup: () async => false,
          permissionRequester: () async => true,
        );
        // Card still visible at 5/6, no celebration yet.
        expect(find.text(l10n.homeChecklistProgress('5', '6')), findsOneWidget);
        check(repo.markAllDoneCelebratedCalls).equals(0);
        // Grant the final permission → completes the checklist.
        await tester.tap(find.text(l10n.homeChecklistItem6Title));
        await tester.pumpAndSettle();
        expect(find.text(l10n.homeChecklistAllDoneBanner), findsOneWidget);
        check(repo.markAllDoneCelebratedCalls).equals(1);
      },
    );
  });

  group('SafetySetupChecklist — completion sources', () {
    testWidgets('item 1 flips to done when contacts are non-empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        contacts: <EmergencyContact>[_contact('c0', 'Alice')],
      );
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });

    testWidgets('item 2 flips to done when sessionEndPinHash is set', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        settingsRepo: _FakeAppSettingsRepository(
          initial: _settings(sessionEndPinHash: 'hashed'),
        ),
      );
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });

    testWidgets('item 3 flips to done when defaults.stealth.enabled is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        settingsRepo: _FakeAppSettingsRepository(
          initial: _settings(stealthEnabled: true),
        ),
      );
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });

    testWidgets('item 4 flips to done when simulation flag is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, repo: _FakeChecklistRepository(simulationDone: true));
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });

    testWidgets('item 5 flips to done when a non-seed mode exists', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, modes: <SessionMode>[_mode('user-mode-1', 'Custom')]);
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });

    testWidgets('item 5 stays UNDONE when only seed modes (walk/date) exist', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        modes: <SessionMode>[
          _mode(SeedData.walkModeId, 'Walk Mode'),
          _mode(SeedData.dateModeId, 'Date Mode'),
        ],
      );
      expect(find.text(l10n.homeChecklistProgress('0', '6')), findsOneWidget);
    });

    testWidgets('item 6 flips to done when permissionLookup returns true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, permissionLookup: () async => true);
      expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
    });
  });

  group('SafetySetupChecklist — tap navigation', () {
    testWidgets('tapping item 1 pushes the contact-form route', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final pushed = await _pump(tester);
      await tester.tap(find.text(l10n.homeChecklistItem1Title));
      await tester.pumpAndSettle();
      check(pushed.lastPushed).equals(RouteNames.contactForm);
    });

    testWidgets('tapping item 2 pushes pin-setup with ?type=sessionEnd', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final pushed = await _pump(tester);
      await tester.tap(find.text(l10n.homeChecklistItem2Title));
      await tester.pumpAndSettle();
      check(pushed.lastPushed).equals(RouteNames.pinSetup);
      check(pushed.lastQueryParameters['type']).equals('sessionEnd');
    });

    testWidgets(
      'tapping item 3 opens tutorial; "Go there" pushes settings-stealth',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final pushed = await _pump(tester);
        await tester.tap(find.text(l10n.homeChecklistItem3Title));
        await tester.pumpAndSettle();
        expect(find.text(l10n.checklistTutorial3Body), findsOneWidget);
        await tester.tap(find.text(l10n.homeChecklistGoThere));
        await tester.pumpAndSettle();
        check(pushed.lastPushed).equals(RouteNames.settingsStealth);
      },
    );

    testWidgets('tapping item 4 opens tutorial WITHOUT a "Go there" button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      await tester.tap(find.text(l10n.homeChecklistItem4Title));
      await tester.pumpAndSettle();
      expect(find.text(l10n.checklistTutorial4Body), findsOneWidget);
      // The simulate-tutorial sheet only confirms; no deep-link button.
      expect(find.text(l10n.homeChecklistGoThere), findsNothing);
      expect(find.text(l10n.homeChecklistGotIt), findsOneWidget);
    });

    testWidgets('tapping item 5 opens tutorial; "Go there" pushes modes', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final pushed = await _pump(tester);
      await tester.tap(find.text(l10n.homeChecklistItem5Title));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.homeChecklistGoThere));
      await tester.pumpAndSettle();
      check(pushed.lastPushed).equals(RouteNames.modes);
    });

    testWidgets(
      'tapping item 6 invokes the permission requester and flips state',
      (WidgetTester tester) async {
        // Permission is currently denied; requester grants it.
        final l10n = await loadL10n(const Locale('en'));
        await _pump(
          tester,
          permissionLookup: () async => false,
          permissionRequester: () async => true,
        );
        await tester.tap(find.text(l10n.homeChecklistItem6Title));
        await tester.pumpAndSettle();
        // After the grant, the progress reflects the change.
        expect(find.text(l10n.homeChecklistProgress('1', '6')), findsOneWidget);
      },
    );
  });

  group('SafetySetupChecklist — info sheet', () {
    testWidgets('tapping the (ℹ) icon opens the info bottom sheet', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // The first info icon belongs to item 1.
      final infoIcons = find.byIcon(Icons.info_outline);
      expect(infoIcons, findsNWidgets(6));
      await tester.tap(infoIcons.first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.checklistInfo1Body), findsOneWidget);
      // Single dismiss action: "Got it".
      expect(find.text(l10n.homeChecklistGotIt), findsOneWidget);
      expect(find.text(l10n.homeChecklistGoThere), findsNothing);
    });
  });

  group('SafetySetupChecklist — dismiss / collapse', () {
    testWidgets('tapping the [×] sets the dismissed flag and hides the card', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeChecklistRepository();
      await _pump(tester, repo: repo);
      await tester.tap(find.byTooltip(l10n.homeChecklistDismissTooltip));
      await tester.pumpAndSettle();
      expect(find.text(l10n.homeChecklistTitle), findsNothing);
      check(repo.dismissCalls).equals(1);
    });

    testWidgets('tapping the chevron toggles expanded state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Expanded by default — items are visible.
      expect(find.text(l10n.homeChecklistItem1Title), findsOneWidget);
      await tester.tap(find.byTooltip(l10n.homeChecklistCollapseTooltip));
      await tester.pumpAndSettle();
      // Collapsed — items hidden but header stays.
      expect(find.text(l10n.homeChecklistTitle), findsOneWidget);
      expect(find.text(l10n.homeChecklistItem1Title), findsNothing);
    });

    testWidgets(
      'expanded by default on first visit; collapsed on subsequent visits',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // First visit — flag false → expanded (matches the fake's default).
        final repo = _FakeChecklistRepository();
        await _pump(tester, repo: repo);
        expect(find.text(l10n.homeChecklistItem1Title), findsOneWidget);
        // Side effect: flag has been persisted.
        check(repo.markFirstVisitDoneCalls).equals(1);
      },
    );
  });

  group('SafetySetupChecklist — progress bar', () {
    testWidgets('progress bar value reflects done count / 6', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        contacts: <EmergencyContact>[_contact('c0', 'Alice')],
        settingsRepo: _FakeAppSettingsRepository(
          initial: _settings(stealthEnabled: true),
        ),
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      check(bar.value).isNotNull().equals(2 / 6);
    });
  });

  // ── Item 6 delegates to the shared ensureNotificationPermission helper ──
  group('SafetySetupChecklist — item 6 DRY delegation', () {
    testWidgets(
      'tapping item 6 (no injected requester) routes through the shared '
      'helper: its rationale dialog appears, then requests on Allow',
      (WidgetTester tester) async {
        // Mount directly so the real `permissionRequester` default runs
        // (which delegates to `ensureNotificationPermission`). The platform
        // is swapped to a denied (not permanent) status so the shared
        // helper's rationale dialog surfaces — proving the delegation
        // (spec 04:504 item 6).
        final perm = _FakePermissionHandlerPlatform(
          status: PermissionStatus.denied,
        );
        final original = PermissionHandlerPlatform.instance;
        PermissionHandlerPlatform.instance = perm;
        addTearDown(() => PermissionHandlerPlatform.instance = original);

        final l10n = await loadL10n(const Locale('en'));
        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              homeChecklistRepositoryProvider.overrideWithValue(
                _FakeChecklistRepository(),
              ),
              appSettingsRepositoryProvider.overrideWithValue(
                _FakeAppSettingsRepository(),
              ),
            ],
            child: const MaterialApp(
              localizationsDelegates: <LocalizationsDelegate<Object>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Material(
                // permissionLookup forces item 6 incomplete; NO
                // permissionRequester → the real default (shared helper).
                child: SafetySetupChecklist(
                  contacts: <EmergencyContact>[],
                  modes: <SessionMode>[],
                  permissionLookup: _alwaysFalse,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.homeChecklistItem6Title));
        await tester.pumpAndSettle();
        // The shared helper's rationale dialog is on screen.
        expect(find.text(l10n.permissionNotifRationaleTitle), findsOneWidget);
        check(perm.requestPermissionsCalls).equals(0);
        await tester.tap(find.text(l10n.permissionNotifAllow));
        await tester.pumpAndSettle();
        check(perm.requestPermissionsCalls).equals(1);
      },
    );
  });
}

/// Top-level lookup that always reports the notification permission as
/// not-granted (keeps checklist item 6 incomplete).
Future<bool> _alwaysFalse() async => false;
