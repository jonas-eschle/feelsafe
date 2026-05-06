/// Structural tests for `lib/router/app_router.dart`.
///
/// Full end-to-end route rendering pulls in most of the app's
/// controllers and platform channels, so these tests stay at the
/// `GoRouter` metadata layer — every `RouteNames` constant must be
/// wired to exactly one route, names must be unique, and the route
/// list size must match the screen inventory.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/router/app_router.dart';

/// Reads every [GoRoute] path/name pair off the top-level router.
List<({String name, String path})> _routes() {
  final out = <({String name, String path})>[];
  for (final r in appRouter.configuration.routes) {
    if (r is GoRoute) {
      out.add((name: r.name!, path: r.path));
    }
  }
  return out;
}

/// Every `RouteNames.*` string literal defined in the canonical list.
const List<String> _allRouteNames = [
  RouteNames.home,
  RouteNames.onboarding,
  RouteNames.session,
  RouteNames.sessionCompleted,
  RouteNames.simulationSummary,
  RouteNames.fakeCall,
  RouteNames.contacts,
  RouteNames.contactForm,
  RouteNames.modes,
  RouteNames.modeEditor,
  RouteNames.stepPreview,
  RouteNames.distressModes,
  RouteNames.distressModeEditor,
  RouteNames.templates,
  RouteNames.templateEditor,
  RouteNames.profile,
  RouteNames.settings,
  RouteNames.settingsSecurity,
  RouteNames.settingsStealth,
  RouteNames.pinSetup,
  RouteNames.batteryAlert,
  RouteNames.eventDefaults,
  RouteNames.gpsLogging,
  RouteNames.reminderTemplates,
  RouteNames.notificationSettings,
  RouteNames.historyRetention,
  RouteNames.backup,
  RouteNames.pastEvents,
  RouteNames.pastEventDetail,
  RouteNames.evidenceExport,
  RouteNames.about,
  RouteNames.feedback,
];

void main() {
  test('initialLocation is the home route', () {
    check(
      appRouter.configuration.routes.whereType<GoRoute>().first.path,
    ).equals(RouteNames.home);
  });

  test('every RouteNames constant is registered on the router', () {
    final registered = _routes().map((r) => r.path).toSet();
    for (final name in _allRouteNames) {
      check(
        because: 'route "$name" is referenced but not registered',
        registered.contains(name),
      ).isTrue();
    }
  });

  test('route paths are unique', () {
    final paths = _routes().map((r) => r.path).toList();
    check(paths.length).equals(paths.toSet().length);
  });

  test('route names are unique', () {
    final names = _routes().map((r) => r.name).toList();
    check(names.length).equals(names.toSet().length);
  });

  test('RouteNames.home is the root "/"', () {
    check(RouteNames.home).equals('/');
  });

  test('onboarding route is "/onboarding"', () {
    check(RouteNames.onboarding).equals('/onboarding');
  });

  test('every registered route has a builder', () {
    for (final r in appRouter.configuration.routes) {
      if (r is GoRoute) {
        check(r.builder).isNotNull();
      }
    }
  });

  test('settings submenu paths nest under /settings', () {
    const submenu = [
      RouteNames.settingsSecurity,
      RouteNames.settingsStealth,
      RouteNames.pinSetup,
      RouteNames.batteryAlert,
      RouteNames.eventDefaults,
      RouteNames.gpsLogging,
      RouteNames.reminderTemplates,
      RouteNames.notificationSettings,
      RouteNames.historyRetention,
      RouteNames.backup,
    ];
    for (final p in submenu) {
      check(p.startsWith('/settings')).isTrue();
    }
  });

  test('past-events submenu paths nest under /past-events', () {
    check(RouteNames.pastEventDetail.startsWith('/past-events')).isTrue();
    check(RouteNames.evidenceExport.startsWith('/past-events')).isTrue();
  });

  test('session submenu paths nest under /session', () {
    check(RouteNames.sessionCompleted.startsWith('/session')).isTrue();
    check(RouteNames.simulationSummary.startsWith('/session')).isTrue();
  });

  test('route count matches the canonical RouteNames inventory', () {
    check(_routes().length).equals(_allRouteNames.length);
  });

  test('named routes expose the expected names', () {
    final names = _routes().map((r) => r.name).toSet();
    for (final n in const [
      'home',
      'onboarding',
      'session',
      'sessionCompleted',
      'simulationSummary',
      'fakeCall',
      'contacts',
      'contactForm',
      'modes',
      'modeEditor',
      'distressModes',
      'distressModeEditor',
      'templates',
      'templateEditor',
      'profile',
      'settings',
      'settingsSecurity',
      'settingsStealth',
      'pinSetup',
      'batteryAlert',
      'eventDefaults',
      'gpsLogging',
      'reminderTemplates',
      'notificationSettings',
      'historyRetention',
      'backup',
      'pastEvents',
      'pastEventDetail',
      'evidenceExport',
      'about',
      'feedback',
    ]) {
      check(
        because: 'expected named route "$n"',
        names.contains(n),
      ).isTrue();
    }
  });
}
