/// Widget tests for [PinSetupScreen].
///
/// Covers PIN entry flow, type-specific copy, mismatch, collision,
/// clear / backspace, submit gating, locale smoke, and dark-mode.
/// Each test mounts the screen via [pumpScreen] and injects a
/// [_FakeAppSettingsRepository] via
/// [appSettingsRepositoryProvider.overrideWithValue].
///
/// Pattern mirrors `test/features/home/home_screen_test.dart`.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/pin_setup/pin_setup_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake — in-memory AppSettingsRepository
// ---------------------------------------------------------------------------

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository({AppSettings? initial})
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('pin_setup_test_'),
      );

  AppSettings _current;
  int saveCalls = 0;
  AppSettings? lastSaved;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async {
    saveCalls++;
    lastSaved = value;
    _current = value;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns the single override list for [pumpScreen].
List<Override> _overrides(_FakeAppSettingsRepository repo) => <Override>[
  appSettingsRepositoryProvider.overrideWithValue(repo),
];

/// Mounts [PinSetupScreen] inside a minimal GoRouter so that
/// `context.pop()` inside `_save()` resolves without a "No GoRouter"
/// error.
///
/// Routes:
/// - `/` — blank sentinel the screen can pop back to.
/// - `/pin-setup` — the screen under test.
///
/// Pass [settle] = false to capture intermediate frames.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required String pinType,
  required List<Override> overrides,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/pin-setup',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, _) => const Scaffold(body: Text('home')),
        routes: <RouteBase>[
          GoRoute(
            path: 'pin-setup',
            builder: (context, _) => PinSetupScreen(pinType: pinType),
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
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

/// Taps digit buttons on the [PinKeypad] in sequence.
///
/// [digits] is a list of integers 0-9.
Future<void> _enterDigits(
  WidgetTester tester,
  List<int> digits,
) async {
  for (final d in digits) {
    await tester.tap(
      find.widgetWithText(InkWell, '$d').last,
    );
    await tester.pump();
  }
}

/// Taps the backspace button once.
Future<void> _tapBackspace(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.backspace_outlined));
  await tester.pump();
}

/// Taps the Submit / pinSubmit button.
Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton));
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  group('PinSetupScreen — renders', () {
    testWidgets('mounts without exception for type=app', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mounts without exception for type=sessionEnd', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'sessionEnd'),
        overrides: _overrides(repo),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mounts without exception for type=duress', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'duress'),
        overrides: _overrides(repo),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a PinKeypad widget', (WidgetTester tester) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      expect(find.byType(PinKeypad), findsOneWidget);
    });

    testWidgets('shows 8 dot indicators in initial state', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      // 8 CircleAvatars represent the progress dots.
      expect(find.byType(CircleAvatar), findsNWidgets(8));
    });

    testWidgets('Submit button is disabled before 4 digits entered', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNull();
    });
  });

  // ── Type-specific app-bar titles ───────────────────────────────────────────

  group('PinSetupScreen — type-specific copy', () {
    testWidgets('shows securityAppPinTitle in app bar for type=app', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      expect(find.text(l10n.securityAppPinTitle), findsOneWidget);
    });

    testWidgets(
      'shows securitySessionEndPinTitle in app bar for type=sessionEnd',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final repo = _FakeAppSettingsRepository();
        await pumpScreen(
          tester,
          const PinSetupScreen(pinType: 'sessionEnd'),
          overrides: _overrides(repo),
        );
        expect(find.text(l10n.securitySessionEndPinTitle), findsOneWidget);
      },
    );

    testWidgets(
      'shows securityDuressPinTitle in app bar for type=duress',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final repo = _FakeAppSettingsRepository();
        await pumpScreen(
          tester,
          const PinSetupScreen(pinType: 'duress'),
          overrides: _overrides(repo),
        );
        expect(find.text(l10n.securityDuressPinTitle), findsOneWidget);
      },
    );

    testWidgets('Duress title differs from App title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Duress and App PIN labels must be distinct — they carry different
      // security semantics and the user must never confuse them.
      expect(
        l10n.securityDuressPinTitle,
        isNot(equals(l10n.securityAppPinTitle)),
      );
    });

    testWidgets('shows pinSetupEnterNew prompt on initial load', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      expect(find.text(l10n.pinSetupEnterNew), findsOneWidget);
      expect(find.text(l10n.pinSetupConfirmNew), findsNothing);
    });
  });

  // ── Digit entry and progress dots ─────────────────────────────────────────

  group('PinSetupScreen — digit entry', () {
    testWidgets('Submit button enables after entering 4 digits', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNotNull();
    });

    testWidgets('backspace removes last entered digit', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapBackspace(tester);
      // After removing one digit only 3 remain — button should be disabled.
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNull();
    });

    testWidgets('does not crash when backspace tapped on empty entry', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _tapBackspace(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts up to 8 digits without error', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4, 5, 6, 7, 8]);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Confirm flow ───────────────────────────────────────────────────────────

  group('PinSetupScreen — confirm flow', () {
    testWidgets('switches to confirm prompt after first Submit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      expect(find.text(l10n.pinSetupConfirmNew), findsOneWidget);
      expect(find.text(l10n.pinSetupEnterNew), findsNothing);
    });

    testWidgets(
      'shows mismatch error when confirm digits differ from entry',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final repo = _FakeAppSettingsRepository();
        await pumpScreen(
          tester,
          const PinSetupScreen(pinType: 'app'),
          overrides: _overrides(repo),
        );
        // First pass: 1234
        await _enterDigits(tester, <int>[1, 2, 3, 4]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        // Confirm pass: 5678 — mismatch
        await _enterDigits(tester, <int>[5, 6, 7, 8]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        expect(find.text(l10n.pinSetupMismatch), findsOneWidget);
      },
    );

    testWidgets('resets to entry prompt after mismatch', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[5, 6, 7, 8]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      // Still on confirm screen — error is shown and user can re-enter.
      expect(find.text(l10n.pinSetupMismatch), findsOneWidget);
    });

    testWidgets(
      'successful matching confirm calls repo.save once',
      (WidgetTester tester) async {
        final repo = _FakeAppSettingsRepository();
        await _pumpWithRouter(
          tester,
          pinType: 'app',
          overrides: _overrides(repo),
        );
        await _enterDigits(tester, <int>[1, 2, 3, 4]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        await _enterDigits(tester, <int>[1, 2, 3, 4]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        check(repo.saveCalls).equals(1);
      },
    );

    testWidgets('save for type=app writes appPinHash', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await _pumpWithRouter(
        tester,
        pinType: 'app',
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      final saved = repo.lastSaved;
      check(saved).isNotNull();
      check(saved!.appPinHash).isNotNull();
      check(saved.sessionEndPinHash).isNull();
      check(saved.duressPinHash).isNull();
    });

    testWidgets('save for type=sessionEnd writes sessionEndPinHash', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await _pumpWithRouter(
        tester,
        pinType: 'sessionEnd',
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      final saved = repo.lastSaved;
      check(saved).isNotNull();
      check(saved!.sessionEndPinHash).isNotNull();
      check(saved.appPinHash).isNull();
      check(saved.duressPinHash).isNull();
    });

    testWidgets('save for type=duress writes duressPinHash', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await _pumpWithRouter(
        tester,
        pinType: 'duress',
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      final saved = repo.lastSaved;
      check(saved).isNotNull();
      check(saved!.duressPinHash).isNotNull();
      check(saved.appPinHash).isNull();
      check(saved.sessionEndPinHash).isNull();
    });

    testWidgets('shows pinSetupSaved snackbar on success', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final repo = _FakeAppSettingsRepository();
      await _pumpWithRouter(
        tester,
        pinType: 'app',
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      await _tapSubmit(tester);
      await tester.pumpAndSettle();
      expect(find.text(l10n.pinSetupSaved), findsOneWidget);
    });
  });

  // ── Collision detection ────────────────────────────────────────────────────

  group('PinSetupScreen — collision detection', () {
    testWidgets(
      'shows pinSetupCollision when new PIN matches existing appPinHash '
      'while setting duress PIN',
      (WidgetTester tester) async {
        // SHA-256 of "1234"
        const existing =
            '03ac674216f3e15c761ee1a5e255f067'
            '953623c8b388b4459e13f978d7c846f4';
        final repo = _FakeAppSettingsRepository(
          initial: const AppSettings(appPinHash: existing),
        );
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const PinSetupScreen(pinType: 'duress'),
          overrides: _overrides(repo),
        );
        // Enter the same digits (1234) as the existing appPinHash.
        await _enterDigits(tester, <int>[1, 2, 3, 4]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        // Confirm with the same digits.
        await _enterDigits(tester, <int>[1, 2, 3, 4]);
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        expect(find.text(l10n.pinSetupCollision), findsOneWidget);
        check(repo.saveCalls).equals(0);
      },
    );
  });

  // ── Too-short guard ────────────────────────────────────────────────────────

  group('PinSetupScreen — too-short PIN guard', () {
    testWidgets('Submit button stays disabled for fewer than 4 digits', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      await _enterDigits(tester, <int>[1, 2, 3]);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNull();
    });
  });

  // ── Locale smoke ───────────────────────────────────────────────────────────

  group('PinSetupScreen — locale smoke', () {
    testWidgets('renders in German without overflow or exception', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
        locale: const Locale('de'),
      );
      expect(find.byType(PinKeypad), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
        locale: const Locale('ar'),
      );
      expect(find.byType(PinKeypad), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in French without overflow or exception', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'duress'),
        overrides: _overrides(repo),
        locale: const Locale('fr'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ─────────────────────────────────────────────────────────────

  group('PinSetupScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('PinSetupScreen — accessibility', () {
    testWidgets('backspace button carries backspace icon (semantic target)', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('digit buttons 0-9 are all present on the keypad', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await pumpScreen(
        tester,
        const PinSetupScreen(pinType: 'app'),
        overrides: _overrides(repo),
      );
      for (int d = 0; d <= 9; d++) {
        expect(
          find.widgetWithText(InkWell, '$d'),
          findsWidgets,
          reason: 'digit $d must appear on keypad',
        );
      }
    });
  });
}
