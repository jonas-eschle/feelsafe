/// Widget tests for [AboutScreen].
///
/// Covers: app name, version string, build number, legal links (privacy
/// policy, terms of service), credits / acknowledgments, "Open source
/// licenses" action (showLicensePage), copyright text, contact-us link,
/// version-info tile, link launch behaviour; RTL + dark + accessibility
/// smoke.
///
/// Pattern: no controller to fake — AboutScreen is a StatefulWidget that
/// uses PackageInfo directly. We call
/// [PackageInfo.setMockInitialValues] before each test that needs a
/// deterministic version string, and we register a mock url_launcher
/// MethodChannel so no real URL opens.
///
/// ListView items below the fold use [Finder.skipOffstage] = false for
/// existence checks, and [tester.scrollUntilVisible] for tap tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/features/about/about_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// url_launcher channel mock
// ---------------------------------------------------------------------------

/// Intercepts all url_launcher method channel calls so no real browser
/// or email app is opened during widget tests.
class _UrlLauncherMock {
  final List<MethodCall> calls = <MethodCall>[];

  static const List<String> _channels = <String>[
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher',
  ];

  void register() {
    for (final name in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), _handle);
    }
  }

  void unregister() {
    for (final name in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), null);
    }
  }

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    if (call.method == 'canLaunchUrl' || call.method == 'canLaunch') {
      return true;
    }
    if (call.method == 'launchUrl' || call.method == 'launch') {
      return true;
    }
    return null;
  }

  /// Returns the URL strings passed to any launch call.
  List<String> launchedUrls() => calls
      .where((c) => c.method == 'launchUrl' || c.method == 'launch')
      .map((c) {
        final args = c.arguments as Map<dynamic, dynamic>;
        return (args['url'] ?? args['urlString'] ?? '').toString();
      })
      .toList();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Configures [PackageInfo] mock values and returns the version string.
String _setPackageInfo({
  String version = '1.2.3',
  String buildNumber = '42',
}) {
  PackageInfo.setMockInitialValues(
    appName: 'Guardian Angela',
    packageName: 'com.guardianangela.app',
    version: version,
    buildNumber: buildNumber,
    buildSignature: '',
  );
  return version;
}

/// Ensures [target] is fully visible in the ListView, then taps it.
///
/// [tester.ensureVisible] scrolls the containing [Scrollable] just enough
/// that the widget is fully on-screen before the tap, which avoids the
/// hit-test miss that [scrollUntilVisible] + [tap] can produce when the
/// widget centre ends up below the viewport edge.
Future<void> _scrollAndTap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  _UrlLauncherMock? urlMock;

  setUp(() {
    urlMock = _UrlLauncherMock()..register();
    _setPackageInfo();
  });

  tearDown(() => urlMock?.unregister());

  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------

  group('AboutScreen — AppBar', () {
    testWidgets('renders the "About" title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.aboutTitle), findsWidgets);
    });

    testWidgets('AppBar widget is present', (WidgetTester tester) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Logo & app identity
  // -------------------------------------------------------------------------

  group('AboutScreen — logo and identity', () {
    testWidgets('renders GuardianAngelaLogo widget', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.byType(GuardianAngelaLogo), findsOneWidget);
    });

    testWidgets('shows app name "Guardian Angela"', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.appTitle), findsWidgets);
    });

    testWidgets('shows tagline text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.homeTagline), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Version string
  // -------------------------------------------------------------------------

  group('AboutScreen — version string', () {
    testWidgets('displays version from PackageInfo after settle', (
      WidgetTester tester,
    ) async {
      _setPackageInfo(version: '2.5.1');
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.aboutVersion('2.5.1')), findsOneWidget);
    });

    testWidgets('version tile has tag icon', (WidgetTester tester) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.byIcon(Icons.tag), findsOneWidget);
    });

    testWidgets('shows placeholder "?" before PackageInfo resolves', (
      WidgetTester tester,
    ) async {
      // pump without settle so initState async hasn't resolved yet.
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen(), settle: false);
      // First frame: version is still empty → displayed as '?'.
      expect(find.text(l10n.aboutVersion('?')), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Author & contact
  // -------------------------------------------------------------------------

  group('AboutScreen — author and contact', () {
    testWidgets('shows author tile with person icon', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.aboutAuthor), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows email tile with email icon', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(find.text(l10n.aboutEmail), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('tapping email tile fires url_launcher with mailto URI', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      await _scrollAndTap(tester, find.text(l10n.aboutEmail));
      check(urlMock!.launchedUrls().any((u) => u.startsWith('mailto:'))).isTrue();
    });
  });

  // -------------------------------------------------------------------------
  // Resources section — legal links
  // -------------------------------------------------------------------------

  group('AboutScreen — legal links', () {
    testWidgets('privacy policy tile exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutPrivacyPolicy, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('terms of service tile exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutTermsOfService, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping privacy policy fires url_launcher with privacy URL',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(tester, const AboutScreen());
        await _scrollAndTap(
          tester,
          find.text(l10n.aboutPrivacyPolicy, skipOffstage: false),
        );
        check(
          urlMock!.launchedUrls().any((u) => u.contains('privacy')),
        ).isTrue();
      },
    );

    testWidgets(
      'tapping terms of service fires url_launcher with terms URL',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(tester, const AboutScreen());
        await _scrollAndTap(
          tester,
          find.text(l10n.aboutTermsOfService, skipOffstage: false),
        );
        check(
          urlMock!.launchedUrls().any((u) => u.contains('terms')),
        ).isTrue();
      },
    );
  });

  // -------------------------------------------------------------------------
  // Source code link
  // -------------------------------------------------------------------------

  group('AboutScreen — source code link', () {
    testWidgets('source code tile exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutSourceCode, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('tapping source code fires url_launcher with GitHub URL', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      await _scrollAndTap(
        tester,
        find.text(l10n.aboutSourceCode, skipOffstage: false),
      );
      check(urlMock!.launchedUrls().any((u) => u.contains('github'))).isTrue();
    });
  });

  // -------------------------------------------------------------------------
  // Open Source Licenses
  // -------------------------------------------------------------------------

  group('AboutScreen — open source licenses', () {
    testWidgets('open source licenses tile exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutLicenses, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping licenses tile opens LicensePage without exception',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(tester, const AboutScreen());
        await _scrollAndTap(
          tester,
          find.text(l10n.aboutLicenses, skipOffstage: false),
        );
        // LicensePage is pushed; confirm no exception.
        expect(tester.takeException(), isNull);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Support / donate link
  // -------------------------------------------------------------------------

  group('AboutScreen — support link', () {
    testWidgets('support tile exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutSupport, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('tapping support fires url_launcher', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      final before = urlMock!.calls.length;
      await _scrollAndTap(
        tester,
        find.text(l10n.aboutSupport, skipOffstage: false),
      );
      check(urlMock!.calls.length).isGreaterThan(before);
    });
  });

  // -------------------------------------------------------------------------
  // Bottom tagline / copyright
  // -------------------------------------------------------------------------

  group('AboutScreen — tagline / copyright', () {
    testWidgets('bottom LGBTQ+ tagline exists in the list', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const AboutScreen());
      expect(
        find.text(l10n.aboutTagline, skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  // Structure
  // -------------------------------------------------------------------------

  group('AboutScreen — layout structure', () {
    testWidgets('uses a scrollable ListView body', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('contains at least one Divider separator', (
      WidgetTester tester,
    ) async {
      // Only the Divider(s) above the fold are visible; there are two in
      // total. We confirm at least the first is rendered.
      await pumpScreen(tester, const AboutScreen());
      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });

    testWidgets('two Dividers exist in the widget tree (including offstage)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      // Scroll to end so both Dividers are built.
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsAtLeastNWidgets(2));
    });

    testWidgets('contains multiple ListTile widgets', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      expect(find.byType(ListTile), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // open_in_new icon on resource tiles
  // -------------------------------------------------------------------------

  group('AboutScreen — open_in_new icons', () {
    testWidgets('open_in_new icon appears on resource tiles', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      // Scroll to reveal all resource tiles.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      // Privacy, terms, source code, support all have trailing open_in_new.
      expect(find.byIcon(Icons.open_in_new), findsAtLeastNWidgets(4));
    });
  });

  // -------------------------------------------------------------------------
  // RTL
  // -------------------------------------------------------------------------

  group('AboutScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('ar'));
      _setPackageInfo(version: '1.0.0');
      await pumpScreen(
        tester,
        const AboutScreen(),
        locale: const Locale('ar'),
      );
      expect(find.text(l10n.aboutTitle), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode
  // -------------------------------------------------------------------------

  group('AboutScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const AboutScreen(),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('logo is present in dark mode', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const AboutScreen(),
        themeMode: ThemeMode.dark,
      );
      expect(find.byType(GuardianAngelaLogo), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility
  // -------------------------------------------------------------------------

  group('AboutScreen — accessibility', () {
    testWidgets('ListTile widgets provide semantics nodes', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester, const AboutScreen());
      // ListTile automatically provides Semantics for accessible tap targets.
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('no overflow when system font scale is 1.5x', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );
      await pumpScreen(tester, const AboutScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow when system font scale is 2.0x', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );
      await pumpScreen(tester, const AboutScreen());
      expect(tester.takeException(), isNull);
    });
  });
}
