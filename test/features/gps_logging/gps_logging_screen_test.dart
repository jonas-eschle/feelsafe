/// Widget tests for [GpsLoggingScreen].
///
/// Pattern mirrors `test/features/home/home_screen_test.dart`:
/// 1. [_FakeGpsLoggingController] subclasses the real controller and
///    overrides `build()` to return a canned [GpsLoggingState].
/// 2. Each `testWidgets` body calls `pumpScreen` with
///    `gpsLoggingControllerProvider.overrideWith(() => fake)`.
/// 3. Assertions use `find`, `check`, and l10n strings loaded via
///    `loadL10n`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/gps_logging/gps_logging_controller.dart';
import 'package:guardianangela/features/gps_logging/gps_logging_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakeGpsLoggingController extends GpsLoggingController {
  _FakeGpsLoggingController(this._initial);

  final GpsLoggingState _initial;

  int setEnabledCalls = 0;
  bool? lastEnabled;
  int setIntervalCalls = 0;
  int? lastInterval;
  int setAccuracyCalls = 0;
  GpsAccuracy? lastAccuracy;
  int setFormatCalls = 0;
  GpsFormat? lastFormat;
  int setIncludeInSmsCalls = 0;
  bool? lastIncludeInSms;

  @override
  Future<GpsLoggingState> build() async => _initial;

  @override
  Future<void> setEnabled(bool v) async {
    setEnabledCalls++;
    lastEnabled = v;
    state = AsyncData(
      GpsLoggingState(config: _initial.config.copyWith(enabled: v)),
    );
  }

  @override
  Future<void> setInterval(int seconds) async {
    setIntervalCalls++;
    lastInterval = seconds;
    state = AsyncData(
      GpsLoggingState(
        config: _initial.config.copyWith(intervalSeconds: seconds),
      ),
    );
  }

  @override
  Future<void> setAccuracy(GpsAccuracy a) async {
    setAccuracyCalls++;
    lastAccuracy = a;
    state = AsyncData(
      GpsLoggingState(config: _initial.config.copyWith(accuracy: a)),
    );
  }

  @override
  Future<void> setFormat(GpsFormat f) async {
    setFormatCalls++;
    lastFormat = f;
    state = AsyncData(
      GpsLoggingState(config: _initial.config.copyWith(format: f)),
    );
  }

  @override
  Future<void> setIncludeInSms(bool v) async {
    setIncludeInSmsCalls++;
    lastIncludeInSms = v;
    state = AsyncData(
      GpsLoggingState(config: _initial.config.copyWith(includeInSms: v)),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GpsLoggingState _state({
  bool enabled = true,
  int intervalSeconds = 30,
  GpsAccuracy accuracy = GpsAccuracy.high,
  GpsFormat format = GpsFormat.decimal,
  bool includeInSms = true,
}) => GpsLoggingState(
  config: GpsLoggingConfig(
    enabled: enabled,
    intervalSeconds: intervalSeconds,
    accuracy: accuracy,
    format: format,
    includeInSms: includeInSms,
  ),
);

Future<void> _pump(
  WidgetTester tester,
  _FakeGpsLoggingController fake, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) => pumpScreen(
  tester,
  const GpsLoggingScreen(),
  overrides: <Override>[
    gpsLoggingControllerProvider.overrideWith(() => fake),
  ],
  locale: locale,
  themeMode: themeMode,
  settle: settle,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — AppBar', () {
    testWidgets('renders the screen title in the AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.text(l10n.settingsGpsLoggingRow), findsWidgets);
    });

    testWidgets('renders an AppBar widget', (WidgetTester tester) async {
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Async states
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — async states', () {
    testWidgets(
      'shows CircularProgressIndicator on first frame (loading)',
      (WidgetTester tester) async {
        await _pump(
          tester,
          _FakeGpsLoggingController(_state()),
          settle: false,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'CircularProgressIndicator is gone after settling',
      (WidgetTester tester) async {
        await _pump(tester, _FakeGpsLoggingController(_state()));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('shows error text when controller emits an error', (
      WidgetTester tester,
    ) async {
      final fake = _FakeGpsLoggingController(_state());
      await _pump(tester, fake);
      // Force error state after initial load.
      fake.state = AsyncError(Exception('boom'), StackTrace.empty);
      await tester.pump();
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Enable toggle (SwitchListTile)
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — enable toggle', () {
    testWidgets('enabled switch is on when config.enabled is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state()));
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.gpsLoggingEnabled),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('enabled switch is off when config.enabled is false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state(enabled: false)));
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.gpsLoggingEnabled),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isFalse();
    });

    testWidgets('toggling the switch calls setEnabled(false) when on', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeGpsLoggingController(_state());
      await _pump(tester, fake);
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.gpsLoggingEnabled),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabled).equals(false);
    });

    testWidgets('toggling the switch calls setEnabled(true) when off', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeGpsLoggingController(_state(enabled: false));
      await _pump(tester, fake);
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.gpsLoggingEnabled),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.setEnabledCalls).equals(1);
      check(fake.lastEnabled).equals(true);
    });
  });

  // -------------------------------------------------------------------------
  // Interval slider (TimingSlider)
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — interval slider', () {
    testWidgets('renders the interval label', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.text(l10n.gpsLoggingIntervalLabel), findsOneWidget);
    });

    testWidgets('renders a TimingSlider widget', (WidgetTester tester) async {
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.byType(TimingSlider), findsOneWidget);
    });

    testWidgets(
      'TimingSlider receives the current intervalSeconds from config',
      (WidgetTester tester) async {
        await _pump(
          tester,
          _FakeGpsLoggingController(_state(intervalSeconds: 60)),
        );
        final slider = tester.widget<TimingSlider>(find.byType(TimingSlider));
        check(slider.valueSeconds).equals(60);
      },
    );

    testWidgets('TimingSlider has correct min/max bounds', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeGpsLoggingController(_state()));
      final slider = tester.widget<TimingSlider>(find.byType(TimingSlider));
      check(slider.minSeconds).equals(10);
      check(slider.maxSeconds).equals(3600);
    });
  });

  // -------------------------------------------------------------------------
  // Accuracy dropdown
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — accuracy dropdown', () {
    testWidgets('renders the accuracy label', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.text(l10n.gpsLoggingAccuracyLabel), findsOneWidget);
    });

    testWidgets('shows "High" when accuracy is GpsAccuracy.high', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state()),
      );
      expect(find.text(l10n.gpsLoggingAccuracyHigh), findsWidgets);
    });

    testWidgets('shows "Balanced" when accuracy is GpsAccuracy.medium', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state(accuracy: GpsAccuracy.medium)),
      );
      expect(find.text(l10n.gpsLoggingAccuracyBalanced), findsWidgets);
    });

    testWidgets('shows "Low" when accuracy is GpsAccuracy.low', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state(accuracy: GpsAccuracy.low)),
      );
      expect(find.text(l10n.gpsLoggingAccuracyLow), findsWidgets);
    });

    testWidgets(
      'selecting a new accuracy value calls setAccuracy',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeGpsLoggingController(_state());
        await _pump(tester, fake);
        // Open the accuracy dropdown.
        await tester.tap(
          find
              .ancestor(
                of: find.text(l10n.gpsLoggingAccuracyHigh),
                matching: find.byType(DropdownButton<GpsAccuracy>),
              )
              .first,
        );
        await tester.pumpAndSettle();
        // Tap the "Balanced" item in the overlay.
        await tester.tap(
          find.text(l10n.gpsLoggingAccuracyBalanced).last,
        );
        await tester.pumpAndSettle();
        check(fake.setAccuracyCalls).equals(1);
        check(fake.lastAccuracy).equals(GpsAccuracy.medium);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Format dropdown
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — format dropdown', () {
    testWidgets('renders the format label', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeGpsLoggingController(_state()));
      expect(find.text(l10n.gpsLoggingFormatLabel), findsOneWidget);
    });

    testWidgets('shows "Decimal" when format is GpsFormat.decimal', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state()),
      );
      expect(find.text(l10n.gpsLoggingFormatDecimal), findsWidgets);
    });

    testWidgets('shows "DMS" when format is GpsFormat.dms', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state(format: GpsFormat.dms)),
      );
      expect(find.text(l10n.gpsLoggingFormatDms), findsWidgets);
    });

    testWidgets(
      'shows "Address" when format is GpsFormat.openLocationCode',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(
          tester,
          _FakeGpsLoggingController(
            _state(format: GpsFormat.openLocationCode),
          ),
        );
        expect(find.text(l10n.gpsLoggingFormatAddress), findsWidgets);
      },
    );

    testWidgets(
      'selecting DMS from decimal calls setFormat(GpsFormat.dms)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeGpsLoggingController(_state());
        await _pump(tester, fake);
        // Open the format dropdown.
        await tester.tap(
          find
              .ancestor(
                of: find.text(l10n.gpsLoggingFormatDecimal),
                matching: find.byType(DropdownButton<GpsFormat>),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.gpsLoggingFormatDms).last);
        await tester.pumpAndSettle();
        check(fake.setFormatCalls).equals(1);
        check(fake.lastFormat).equals(GpsFormat.dms);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Include-in-SMS toggle
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — include-in-SMS toggle', () {
    testWidgets('include-in-SMS switch is on when includeInSms is true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state()),
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.gpsLoggingIncludeInSms),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('include-in-SMS switch is off when includeInSms is false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeGpsLoggingController(_state(includeInSms: false)),
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.gpsLoggingIncludeInSms),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isFalse();
    });

    testWidgets('toggling include-in-SMS calls setIncludeInSms', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeGpsLoggingController(_state());
      await _pump(tester, fake);
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.gpsLoggingIncludeInSms),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.setIncludeInSmsCalls).equals(1);
      check(fake.lastIncludeInSms).equals(false);
    });
  });

  // -------------------------------------------------------------------------
  // RTL smoke
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeGpsLoggingController(_state()),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode smoke
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeGpsLoggingController(_state()),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility smoke
  // -------------------------------------------------------------------------

  group('GpsLoggingScreen — accessibility', () {
    testWidgets(
      'SwitchListTile tiles are reachable by semantics (label present)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester, _FakeGpsLoggingController(_state()));
        // Both SwitchListTile labels must be in the semantics tree.
        expect(find.text(l10n.gpsLoggingEnabled), findsOneWidget);
        expect(find.text(l10n.gpsLoggingIncludeInSms), findsOneWidget);
      },
    );

    testWidgets(
      'DropdownButton items are accessible as text nodes',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester, _FakeGpsLoggingController(_state()));
        // Both selected values appear as text.
        expect(find.text(l10n.gpsLoggingAccuracyHigh), findsWidgets);
        expect(find.text(l10n.gpsLoggingFormatDecimal), findsWidgets);
      },
    );

    testWidgets('screen renders under large font scale without overflow', (
      WidgetTester tester,
    ) async {
      // Re-use pumpScreen but wrap in a MediaQuery override for 2× scale.
      await pumpScreen(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: GpsLoggingScreen(),
        ),
        overrides: <Override>[
          gpsLoggingControllerProvider.overrideWith(
            () => _FakeGpsLoggingController(_state()),
          ),
        ],
      );
      expect(tester.takeException(), isNull);
    });
  });
}
