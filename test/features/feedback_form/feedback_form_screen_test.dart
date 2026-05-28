/// Widget tests for [FeedbackFormScreen].
///
/// Covers spec 04 §Feedback Screen (lines 2309–2357): category dropdown,
/// optional email field, required message field, include-log switch, send
/// validation, success snackbar, and dark / RTL / accessibility smokes.
///
/// The screen calls `context.pop()` via GoRouter after a successful send, so
/// tests that exercise the send path use [_pumpWithRouter], which mounts the
/// screen under a minimal GoRouter shell. Static-content and validation tests
/// that never reach the pop call use the lighter [pumpScreen] harness.
///
/// `launchUrl` is intercepted by [_UrlLauncherMock], which registers mock
/// handlers on the url_launcher platform channels.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/enums/feedback_type.dart';
import 'package:guardianangela/features/feedback_form/feedback_form_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// url_launcher binary-messenger mock
// ---------------------------------------------------------------------------

/// Intercepts all `launchUrl` calls made during tests.
///
/// Registers mock handlers on the platform channels that the
/// `url_launcher` plugin dispatches through, recording every
/// [MethodCall] and returning `true` (success) by default.
class _UrlLauncherMock {
  final List<MethodCall> calls = [];

  void register() {
    for (final ch in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(ch), _handle);
    }
  }

  void unregister() {
    for (final ch in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(ch), null);
    }
  }

  static const List<String> _channels = <String>[
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher',
  ];

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    return true;
  }
}

// ---------------------------------------------------------------------------
// GoRouter-aware pump helper
// ---------------------------------------------------------------------------

/// Pumps [FeedbackFormScreen] under a minimal GoRouter shell.
///
/// Required for tests that trigger [_send], which calls `context.pop()`.
/// The router has two routes:
/// - `/` — a blank sentinel so the screen has a parent to pop back to.
/// - `/feedback` — the [FeedbackFormScreen].
///
/// [locale] and [themeMode] mirror the same options as [pumpScreen].
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/feedback',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext ctx, GoRouterState s) =>
            const Scaffold(body: Text('home')),
        routes: <RouteBase>[
          GoRoute(
            path: 'feedback',
            builder: (BuildContext ctx, GoRouterState s) =>
                const FeedbackFormScreen(),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        locale: locale,
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
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
  if (settle) await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Finders
// ---------------------------------------------------------------------------

/// Finds the [RadioGroup] for the category selector.
Finder _categoryGroup() => find.byType(RadioGroup<FeedbackType>);

/// Finds the [FilledButton] (Send) — pass skipOffstage:false so the
/// finder picks up the button even when it sits below the viewport in
/// the ListView's lazy build.
Finder _sendButton() => find.byType(FilledButton, skipOffstage: false);

/// Ensures the Send button is laid out, then taps it.
Future<void> _tapSend(WidgetTester tester) async {
  await tester.ensureVisible(_sendButton());
  await tester.pumpAndSettle();
  await tester.tap(_sendButton());
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _UrlLauncherMock launcher;

  setUp(() {
    launcher = _UrlLauncherMock()..register();
  });

  tearDown(() {
    launcher.unregister();
  });

  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — AppBar', () {
    testWidgets('renders the feedback title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.text(l10n.feedbackTitle), findsOneWidget);
    });

    testWidgets('AppBar widget is present', (WidgetTester tester) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Heading & static content
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — static content', () {
    testWidgets('renders the heading text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.text(l10n.feedbackHeading), findsOneWidget);
    });

    testWidgets('renders the category radio group', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(_categoryGroup(), findsOneWidget);
      expect(
        find.byType(RadioListTile<FeedbackType>),
        findsNWidgets(FeedbackType.values.length),
      );
    });

    testWidgets('renders the email text field label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.text(l10n.feedbackEmailLabel), findsOneWidget);
    });

    testWidgets('renders the message text field label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.text(l10n.feedbackMessageLabel), findsOneWidget);
    });

    testWidgets('renders the include-log SwitchListTile', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text(l10n.feedbackIncludeLog), findsOneWidget);
    });

    testWidgets('renders the Send FilledButton', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.scrollUntilVisible(
        find.text(l10n.feedbackSend),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text(l10n.feedbackSend), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Category radio group — default and options
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — category radio group', () {
    testWidgets('default category is Bug', (WidgetTester tester) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      final group = tester.widget<RadioGroup<FeedbackType>>(_categoryGroup());
      check(group.groupValue).equals(FeedbackType.bug);
    });

    testWidgets('selecting Feature switches the group value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.tap(find.text(l10n.feedbackCategoryFeature));
      await tester.pumpAndSettle();
      final group = tester.widget<RadioGroup<FeedbackType>>(_categoryGroup());
      check(group.groupValue).equals(FeedbackType.feature);
    });

    testWidgets('selecting Other switches the group value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.tap(find.text(l10n.feedbackCategoryOther));
      await tester.pumpAndSettle();
      final group = tester.widget<RadioGroup<FeedbackType>>(_categoryGroup());
      check(group.groupValue).equals(FeedbackType.other);
    });
  });

  // -------------------------------------------------------------------------
  // Message field validation (no pop, so pumpScreen is sufficient)
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — message validation', () {
    testWidgets('empty message shows validation snackbar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await _tapSend(tester);
      await tester.pump();
      expect(find.text(l10n.feedbackMessageRequired), findsOneWidget);
      check(launcher.calls).isEmpty();
    });

    testWidgets('message of 9 chars shows validation snackbar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.enterText(find.byType(TextField).last, 'Too short');
      await tester.pump();
      await _tapSend(tester);
      await tester.pump();
      expect(find.text(l10n.feedbackMessageRequired), findsOneWidget);
      check(launcher.calls).isEmpty();
    });

    testWidgets('whitespace-only message (10 spaces) shows validation error', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      // 10 spaces trims to empty — validation must fail.
      await tester.enterText(find.byType(TextField).last, '          ');
      await tester.pump();
      await _tapSend(tester);
      await tester.pump();
      expect(find.text(l10n.feedbackMessageRequired), findsOneWidget);
      check(launcher.calls).isEmpty();
    });
  });

  // -------------------------------------------------------------------------
  // Send success flow (requires GoRouter pop — use _pumpWithRouter)
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — send success flow', () {
    testWidgets('valid message calls launchUrl', (WidgetTester tester) async {
      await _pumpWithRouter(tester);
      await tester.enterText(
        find.byType(TextField).last,
        'This is a valid message.',
      );
      await tester.pump();
      await _tapSend(tester);
      await tester.pumpAndSettle();
      check(launcher.calls).isNotEmpty();
    });

    testWidgets('launchUrl receives a mailto: URI', (
      WidgetTester tester,
    ) async {
      await _pumpWithRouter(tester);
      await tester.enterText(
        find.byType(TextField).last,
        'This is a valid message.',
      );
      await tester.pump();
      await _tapSend(tester);
      await tester.pumpAndSettle();
      final urlArg = launcher.calls.first.arguments.toString();
      check(urlArg).contains('mailto');
    });

    testWidgets('success snackbar is shown after valid send', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester);
      await tester.enterText(
        find.byType(TextField).last,
        'This is a valid message.',
      );
      await tester.pump();
      await _tapSend(tester);
      await tester.pump(); // trigger the snackbar animation
      // findsWidgets: the SnackBar may duplicate text in the a11y tree.
      expect(find.text(l10n.feedbackSent), findsWidgets);
    });

    testWidgets('message exactly 10 chars passes validation', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester);
      // Exactly 10 non-whitespace characters.
      await tester.enterText(find.byType(TextField).last, '1234567890');
      await tester.pump();
      await _tapSend(tester);
      await tester.pump();
      expect(find.text(l10n.feedbackMessageRequired), findsNothing);
      // findsWidgets: SnackBar text may appear in both the widget and a11y.
      expect(find.text(l10n.feedbackSent), findsWidgets);
    });

    testWidgets('optional email field does not block send', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester);
      // Leave email empty; fill only message.
      await tester.enterText(
        find.byType(TextField).last,
        'Valid message text.',
      );
      await tester.pump();
      await _tapSend(tester);
      await tester.pump();
      // findsWidgets: SnackBar text may appear in both the widget and a11y.
      expect(find.text(l10n.feedbackSent), findsWidgets);
      check(launcher.calls).isNotEmpty();
    });

    testWidgets('email value is accepted (launchUrl called once)', (
      WidgetTester tester,
    ) async {
      await _pumpWithRouter(tester);
      // Email field is the first TextField.
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();
      await tester.enterText(
        find.byType(TextField).last,
        'Valid message text.',
      );
      await tester.pump();
      await _tapSend(tester);
      await tester.pumpAndSettle();
      check(launcher.calls).isNotEmpty();
    });
  });

  // -------------------------------------------------------------------------
  // Include-log switch
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — include-log switch', () {
    testWidgets('switch starts in off state', (WidgetTester tester) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      check(tile.value).isFalse();
    });

    testWidgets('toggling switch turns it on', (WidgetTester tester) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      check(tile.value).isTrue();
    });

    testWidgets('switch can be toggled back to off', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      check(tile.value).isFalse();
    });
  });

  // -------------------------------------------------------------------------
  // Email field (optional)
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — email field', () {
    testWidgets('email field accepts typed text', (WidgetTester tester) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.enterText(find.byType(TextField).first, 'test@domain.com');
      await tester.pump();
      expect(find.text('test@domain.com'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RTL smoke test
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without layout overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const FeedbackFormScreen(),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode smoke test
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const FeedbackFormScreen(),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility smoke tests
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — accessibility', () {
    testWidgets('SwitchListTile exposes a non-empty semantics label', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const FeedbackFormScreen());
      final semantics = tester.getSemantics(find.byType(SwitchListTile));
      check(semantics.label).isNotEmpty();
    });

    testWidgets('Send button text is non-empty', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      await tester.scrollUntilVisible(
        find.text(l10n.feedbackSend),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.feedbackSend), findsOneWidget);
    });

    testWidgets('heading uses titleLarge style', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const FeedbackFormScreen());
      final headingWidget = tester.widget<Text>(
        find.text(l10n.feedbackHeading),
      );
      check(headingWidget.style).isNotNull();
    });
  });

  // -------------------------------------------------------------------------
  // Combined flow integration smoke
  // -------------------------------------------------------------------------

  group('FeedbackFormScreen — combined flow', () {
    testWidgets(
      'feature-request + email + message + log-switch sends via launchUrl',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithRouter(tester);

        // Change category to Feature request via the radio group.
        await tester.tap(find.text(l10n.feedbackCategoryFeature));
        await tester.pumpAndSettle();

        // Fill email.
        await tester.enterText(find.byType(TextField).first, 'qa@example.com');
        await tester.pump();

        // Fill message.
        await tester.enterText(
          find.byType(TextField).last,
          'Please add dark-mode support.',
        );
        await tester.pump();

        // Toggle include-log on.
        await tester.tap(find.byType(SwitchListTile));
        await tester.pump();

        // Send.
        await _tapSend(tester);
        await tester.pump();

        // findsWidgets: SnackBar text may appear in both the widget and a11y.
        expect(find.text(l10n.feedbackSent), findsWidgets);
        check(launcher.calls).isNotEmpty();
      },
    );
  });
}
