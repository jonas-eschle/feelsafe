import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/notification_service.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';

// ---------------------------------------------------------------------------
// Additional fakes
// ---------------------------------------------------------------------------

/// Captures NotificationDetails passed to plugin.show for F16 tests.
class _CapturingPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  /// All (id, title, body, details) tuples captured by [show].
  final List<(int, String?, String?, NotificationDetails?)> shown = [];

  /// The foreground response callback captured at [initialize] so tests can
  /// drive a notification tap through the real `_onResponse` handler.
  void Function(NotificationResponse)? lastOnResponse;

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    shown.add((id, title, body, notificationDetails));
  }

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    lastOnResponse = onDidReceiveNotificationResponse;
    return true;
  }

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() => null;
}

/// Captures [AndroidNotificationChannel] arguments passed to
/// [createNotificationChannel] during [RealNotificationService.init].
///
/// Used by G9 to assert the ga_sms_retry channel is created with
/// [Importance.high] without requiring a real Android device.
class _CapturingAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {
  final List<AndroidNotificationChannel> channels = [];

  @override
  Future<void> createNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    channels.add(channel);
  }
}

/// [_CapturingPlugin] variant that returns [_CapturingAndroidPlugin] from
/// [resolvePlatformSpecificImplementation] so G9 can assert channel creation.
class _CapturingPluginWithAndroid extends _CapturingPlugin {
  final _CapturingAndroidPlugin androidPlugin = _CapturingAndroidPlugin();

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() {
    if (T == AndroidFlutterLocalNotificationsPlugin) {
      return androidPlugin as T?;
    }
    return null;
  }
}

/// Creates a [RealNotificationService] backed by [_CapturingPlugin].
Future<(RealNotificationService, _CapturingPlugin)>
_makeCapturingService() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final plugin = _CapturingPlugin();
  final svc = RealNotificationService(
    plugin: plugin,
    prefsFactory: () async => prefs,
  );
  await svc.init();
  return (svc, plugin);
}

/// Creates a [RealNotificationService] backed by [_CapturingPluginWithAndroid]
/// so Android channel creation can be asserted in tests.
///
/// Passes [forceAndroidChannels: true] so [_createAndroidChannels] runs even
/// on non-Android test hosts.
Future<(RealNotificationService, _CapturingPluginWithAndroid)>
_makeCapturingServiceWithAndroid() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final plugin = _CapturingPluginWithAndroid();
  final svc = RealNotificationService(
    plugin: plugin,
    prefsFactory: () async => prefs,
    forceAndroidChannels: true,
  );
  await svc.init();
  return (svc, plugin);
}

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

/// Mock iOS platform plugin for the iOS isChannelEnabled branch (the only
/// platform branch reachable on the non-Android, non-iOS host).
class _MockIOSPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

/// A [_CapturingPlugin] that resolves a caller-supplied iOS platform mock so
/// the iOS branch of RealNotificationService.isChannelEnabled runs on the
/// host. Also records [cancel] calls.
class _PlatformRoutingPlugin extends _CapturingPlugin {
  _PlatformRoutingPlugin({this.ios});

  final IOSFlutterLocalNotificationsPlugin? ios;
  final List<int> cancelled = [];

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() {
    if (T == IOSFlutterLocalNotificationsPlugin) return ios as T?;
    return null;
  }

  @override
  Future<void> cancel({required int id, String? tag}) async =>
      cancelled.add(id);
}

/// Fake [InitializationSettings] for mocktail fallback registration.
class _FakeInitializationSettings extends Fake
    implements InitializationSettings {}

/// Fake [NotificationResponse] for mocktail fallback registration.
class _FakeNotificationResponse extends Fake implements NotificationResponse {}

// ---------------------------------------------------------------------------
// Test helpers for Fix D (background-response replay)
// ---------------------------------------------------------------------------

/// Creates a minimal [RealNotificationService] with a mocked plugin and a
/// custom [prefsFactory] so init() doesn't hit real platform channels.
///
/// [pendingActions] pre-seeds the SharedPreferences list that simulates
/// actions received while the app was killed.
Future<RealNotificationService> _makeReplayService({
  List<String> pendingActions = const [],
}) async {
  // Set up shared_preferences in-memory for test.
  SharedPreferences.setMockInitialValues(
    pendingActions.isEmpty
        ? {}
        : {'pending_notification_actions': pendingActions},
  );

  final prefs = await SharedPreferences.getInstance();

  // Stub plugin so initialize() and resolvePlatformSpecificImplementation
  // don't throw MissingPluginException.
  final plugin = _MockFlutterLocalNotificationsPlugin();
  when(
    () => plugin.initialize(
      settings: any(named: 'settings'),
      onDidReceiveNotificationResponse: any(
        named: 'onDidReceiveNotificationResponse',
      ),
      onDidReceiveBackgroundNotificationResponse: any(
        named: 'onDidReceiveBackgroundNotificationResponse',
      ),
    ),
  ).thenAnswer((_) async => true);
  when(
    () => plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >(),
  ).thenReturn(null);

  return RealNotificationService(
    plugin: plugin,
    prefsFactory: () async => prefs,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationNotificationService _sim() => SimulationNotificationService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Register mocktail fallback values for types used with `any(named: ...)`.
  // This is required once per test isolate for each type that mocktail
  // intercepts via matchers.
  setUpAll(() {
    registerFallbackValue(_FakeInitializationSettings());
    registerFallbackValue(_FakeNotificationResponse());
  });

  // =========================================================================
  // SimulationNotificationService
  // =========================================================================

  group('SimulationNotificationService', () {
    late SimulationNotificationService s;

    setUp(() => s = _sim());
    tearDown(() => s.dispose());

    group('constructor', () {
      test('implements NotificationServiceProtocol', () {
        check(s).isA<NotificationServiceProtocol>();
      });

      test('starts with empty calls', () {
        check(s.calls).isEmpty();
      });
    });

    group('requestPermission', () {
      test('records call', () async {
        await s.requestPermission();
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('requestPermission');
      });

      test('returns true by default', () async {
        check(await s.requestPermission()).isTrue();
      });

      test('returns false when simulatedPermissionGranted=false', () async {
        s.simulatedPermissionGranted = false;
        check(await s.requestPermission()).isFalse();
      });
    });

    group('showDisguisedReminder', () {
      test('records method, id, title, body', () async {
        await s.showDisguisedReminder(id: 42, title: 'T', body: 'B');
        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call.method).equals('showDisguisedReminder');
        check(call.id).equals(42);
        check(call.title).equals('T');
        check(call.body).equals('B');
      });

      test('different ids accumulate separately', () async {
        await s.showDisguisedReminder(id: 1, title: 'A', body: 'a');
        await s.showDisguisedReminder(id: 2, title: 'B', body: 'b');
        check(s.calls).length.equals(2);
        check(s.calls[0].id).equals(1);
        check(s.calls[1].id).equals(2);
      });
    });

    group('showSmsRetryExhaustedNotification', () {
      test('records method, contactName, actionPayload', () async {
        await s.showSmsRetryExhaustedNotification(
          contactName: 'Alice',
          actionPayload: 'payload_001',
        );
        final call = s.calls.first;
        check(call.method).equals('showSmsRetryExhaustedNotification');
        check(call.contactName).equals('Alice');
        check(call.actionPayload).equals('payload_001');
      });

      test('actionPayload is distinct from prefix', () async {
        await s.showSmsRetryExhaustedNotification(
          contactName: 'Bob',
          actionPayload: 'job_456',
        );
        check(s.calls.first.actionPayload).equals('job_456');
      });
    });

    group('showForegroundServiceNotification', () {
      test('records title and body', () async {
        await s.showForegroundServiceNotification(
          title: 'Active',
          body: 'Session running',
        );
        final call = s.calls.first;
        check(call.method).equals('showForegroundServiceNotification');
        check(call.title).equals('Active');
        check(call.body).equals('Session running');
      });

      test('stealth=false by default', () async {
        await s.showForegroundServiceNotification(title: 'T', body: 'B');
        check(s.calls.first.stealth).equals(false);
      });

      test('stealth=true recorded when set', () async {
        await s.showForegroundServiceNotification(
          title: 'Music playing',
          body: '',
          stealth: true,
        );
        check(s.calls.first.stealth).equals(true);
      });
    });

    group('cancel', () {
      test('records cancel with id', () async {
        await s.cancel(99);
        check(s.calls.first.method).equals('cancel');
        check(s.calls.first.id).equals(99);
      });

      test('cancelling multiple ids records all', () async {
        await s.cancel(1);
        await s.cancel(2);
        check(s.calls).length.equals(2);
        check(s.calls[1].id).equals(2);
      });
    });

    group('actionTaps', () {
      test('injectActionTap emits to actionTaps', () async {
        final emitted = <String>[];
        final sub = s.actionTaps.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectActionTap('ga_retry_sms_job_1');
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals(['ga_retry_sms_job_1']);
      });

      test('multiple taps emit in order', () async {
        final emitted = <String>[];
        final sub = s.actionTaps.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectActionTap('tap_a');
        s.injectActionTap('tap_b');
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals(['tap_a', 'tap_b']);
      });

      test('actionTaps is broadcast stream', () {
        final sub1 = s.actionTaps.listen((_) {});
        final sub2 = s.actionTaps.listen((_) {});
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);
        check(true).isTrue(); // no exception = broadcast
      });

      test('action tap prefix matches kActionRetrySmsPrefix', () {
        const payload = 'my_payload';
        check('$kActionRetrySmsPrefix$payload').startsWith('ga_retry_sms_');
      });
    });

    group('reset', () {
      test('clears all recorded calls', () async {
        await s.showDisguisedReminder(id: 1, title: 'T', body: 'B');
        s.reset();
        check(s.calls).isEmpty();
      });
    });

    // -----------------------------------------------------------------------
    // F7: showAlarmEscalation (Extra-35 flags)
    // -----------------------------------------------------------------------

    group('showAlarmEscalation (F7)', () {
      test('records method with id, title, body', () async {
        await s.showAlarmEscalation(id: 101, title: 'ALERT', body: 'Help!');
        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call.method).equals('showAlarmEscalation');
        check(call.id).equals(101);
        check(call.title).equals('ALERT');
        check(call.body).equals('Help!');
      });

      test('records default sound critical_alert.wav', () async {
        await s.showAlarmEscalation(id: 1, title: 'T', body: 'B');
        check(s.calls.first.sound).equals('critical_alert.wav');
      });

      test('records custom sound when provided', () async {
        await s.showAlarmEscalation(
          id: 2,
          title: 'T',
          body: 'B',
          sound: 'siren.wav',
        );
        check(s.calls.first.sound).equals('siren.wav');
      });

      test('different ids accumulate separately', () async {
        await s.showAlarmEscalation(id: 10, title: 'First', body: 'f');
        await s.showAlarmEscalation(id: 11, title: 'Second', body: 's');
        check(s.calls).length.equals(2);
        check(s.calls[0].id).equals(10);
        check(s.calls[1].id).equals(11);
      });

      test('reset clears showAlarmEscalation calls', () async {
        await s.showAlarmEscalation(id: 99, title: 'T', body: 'B');
        s.reset();
        check(s.calls).isEmpty();
      });

      test('protocol contract: showAlarmEscalation is part of protocol', () {
        check(s).isA<NotificationServiceProtocol>();
      });
    });
  });

  // =========================================================================
  // F16: showDisguisedReminder has correct Extra-35 flags
  // =========================================================================

  group('RealNotificationService — showDisguisedReminder flags (F16)', () {
    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'F16: showDisguisedReminder calls plugin.show with correct id/title/body',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(
          id: 55,
          title: 'Check-in',
          body: 'Time to check in.',
        );
        check(plugin.shown).length.equals(1);
        final (capturedId, capturedTitle, capturedBody, _) = plugin.shown.first;
        check(capturedId).equals(55);
        check(capturedTitle).equals('Check-in');
        check(capturedBody).equals('Time to check in.');
      },
    );

    test(
      'F16: showDisguisedReminder provides Android details with fullScreenIntent',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(id: 56, title: 'T', body: 'B');
        final (_, _, _, details) = plugin.shown.first;
        check(details).isNotNull();
        check(details!.android).isNotNull();
        check(details.android!.fullScreenIntent).isTrue();
      },
    );

    test(
      'F16: showDisguisedReminder Android importance is Importance.max',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(id: 57, title: 'T', body: 'B');
        final (_, _, _, details) = plugin.shown.first;
        check(details!.android!.importance).equals(Importance.max);
      },
    );

    test('F16: showDisguisedReminder Android category is alarm', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showDisguisedReminder(id: 58, title: 'T', body: 'B');
      final (_, _, _, details) = plugin.shown.first;
      check(
        details!.android!.category,
      ).equals(AndroidNotificationCategory.alarm);
    });

    test('F16: showDisguisedReminder Android visibility is public', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showDisguisedReminder(id: 59, title: 'T', body: 'B');
      final (_, _, _, details) = plugin.shown.first;
      check(details!.android!.visibility).equals(NotificationVisibility.public);
    });

    test(
      'F16: showDisguisedReminder iOS interruptionLevel is timeSensitive',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(id: 60, title: 'T', body: 'B');
        final (_, _, _, details) = plugin.shown.first;
        check(details!.iOS).isNotNull();
        check(
          details.iOS!.interruptionLevel,
        ).equals(InterruptionLevel.timeSensitive);
      },
    );
  });

  // =========================================================================
  // G10: showAlarmEscalation iOS interruptionLevel is critical (not timeSensitive)
  // =========================================================================

  group('G10: RealNotificationService — showAlarmEscalation iOS flags', () {
    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'showAlarmEscalation iOS interruptionLevel is critical (bypasses DND)',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showAlarmEscalation(id: 51, title: 'Alarm', body: 'Active.');
        final (_, _, _, details) = plugin.shown.first;
        check(details).isNotNull();
        check(details!.iOS).isNotNull();
        check(
          details.iOS!.interruptionLevel,
        ).equals(InterruptionLevel.critical);
      },
    );

    test(
      'showAlarmEscalation iOS interruptionLevel is NOT timeSensitive',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showAlarmEscalation(id: 52, title: 'T', body: 'B');
        final (_, _, _, details) = plugin.shown.first;
        check(
          details!.iOS!.interruptionLevel,
        ).not((c) => c.equals(InterruptionLevel.timeSensitive));
      },
    );
  });

  // =========================================================================
  // F9: ga_sms_retry channel constant (defined in notification_service.dart)
  // =========================================================================

  group('Notification channel IDs (F9)', () {
    test('kSmsRetryChannelId is defined as ga_sms_retry', () {
      check(kSmsRetryChannelId).equals('ga_sms_retry');
    });

    test('kSmsRetryChannelId is distinct from other channel IDs', () {
      check(kSmsRetryChannelId).not((c) => c.equals('session_service'));
      check(kSmsRetryChannelId).not((c) => c.equals('reminders'));
      check(kSmsRetryChannelId).not((c) => c.equals('distress'));
    });
  });

  // =========================================================================
  // G9: init() creates ga_sms_retry Android channel with Importance.high
  // =========================================================================

  group('G9: RealNotificationService.init — Android channel creation', () {
    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'init creates ga_sms_retry channel with Importance.high via Android plugin',
      () async {
        final (_, plugin) = await _makeCapturingServiceWithAndroid();
        final retryChannel = plugin.androidPlugin.channels.firstWhere(
          (ch) => ch.id == kSmsRetryChannelId,
          orElse: () => throw StateError(
            'ga_sms_retry channel not created during init()',
          ),
        );
        check(retryChannel.importance).equals(Importance.high);
      },
    );

    test('init creates exactly one ga_sms_retry channel', () async {
      final (_, plugin) = await _makeCapturingServiceWithAndroid();
      final retryChannels = plugin.androidPlugin.channels
          .where((ch) => ch.id == kSmsRetryChannelId)
          .toList();
      check(retryChannels).length.equals(1);
    });
  });

  // =========================================================================
  // kActionRetrySmsPrefix constant
  // =========================================================================

  group('kActionRetrySmsPrefix', () {
    test('defined as ga_retry_sms_', () {
      check(kActionRetrySmsPrefix).equals('ga_retry_sms_');
    });

    test('can be used to detect retry tap', () {
      const tap = 'ga_retry_sms_job_abc';
      check(tap.startsWith(kActionRetrySmsPrefix)).isTrue();
    });

    test('non-retry tap does not start with prefix', () {
      const tap = 'some_other_action';
      check(tap.startsWith(kActionRetrySmsPrefix)).isFalse();
    });
  });

  // =========================================================================
  // Protocol contracts
  // =========================================================================

  group('NotificationServiceProtocol contracts', () {
    test('SimulationNotificationService satisfies full protocol', () async {
      final service = _sim();
      addTearDown(service.dispose);

      await service.requestPermission();
      await service.showDisguisedReminder(id: 1, title: 'T', body: 'B');
      await service.showSmsRetryExhaustedNotification(
        contactName: 'C',
        actionPayload: 'p',
      );
      await service.showForegroundServiceNotification(title: 'T', body: 'B');
      await service.cancel(1);
      check(service.actionTaps).isA<Stream<String>>();
      check(service.calls).length.equals(5);
    });
  });

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — NotificationService', () {
    late ProviderContainer container;
    late SimulationNotificationService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationNotificationService', () {
      final s = container.read(notificationServiceProvider);
      check(s).isA<SimulationNotificationService>();
    });

    test('simulation is not RealNotificationService', () {
      final s = container.read(notificationServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealNotificationService'));
    });

    test('simulation starts with empty calls', () {
      final s =
          container.read(notificationServiceProvider)
              as SimulationNotificationService;
      check(s.calls).isEmpty();
    });
  });

  // =========================================================================
  // Fix D — Background notification response replay
  // =========================================================================

  group('RealNotificationService — background action replay', () {
    tearDown(() {
      // Clear mock values between tests.
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'init with no pending actions: first subscriber receives nothing',
      () async {
        final svc = await _makeReplayService();
        await svc.init();

        final received = <String>[];
        final sub = svc.actionTaps.listen(received.add);
        // Give the stream time to flush.
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        check(received).isEmpty();
      },
    );

    test(
      'init with pending action: first subscriber receives the action',
      () async {
        final svc = await _makeReplayService(
          pendingActions: ['background:im_safe'],
        );
        await svc.init();

        final received = <String>[];
        final sub = svc.actionTaps.listen(received.add);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        check(received).deepEquals(['background:im_safe']);
      },
    );

    test('ordering of pending actions is preserved', () async {
      final svc = await _makeReplayService(
        pendingActions: ['action_a', 'action_b', 'action_c'],
      );
      await svc.init();

      final received = <String>[];
      final sub = svc.actionTaps.listen(received.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      check(received).deepEquals(['action_a', 'action_b', 'action_c']);
    });

    test('pending list is cleared from SharedPreferences after init', () async {
      SharedPreferences.setMockInitialValues({
        'pending_notification_actions': ['background:pause'],
      });
      final prefs = await SharedPreferences.getInstance();

      final plugin = _MockFlutterLocalNotificationsPlugin();
      when(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
          onDidReceiveBackgroundNotificationResponse: any(
            named: 'onDidReceiveBackgroundNotificationResponse',
          ),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);

      final svc = RealNotificationService(
        plugin: plugin,
        prefsFactory: () async => prefs,
      );
      await svc.init();

      // Subscribe to trigger flush.
      final sub = svc.actionTaps.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // The key should have been removed.
      final remaining = prefs.getStringList('pending_notification_actions');
      check(remaining).isNull();
    });

    test(
      'second subscriber does not re-receive already-flushed actions',
      () async {
        final svc = await _makeReplayService(
          pendingActions: ['background:resume'],
        );
        await svc.init();

        final first = <String>[];
        final second = <String>[];

        final sub1 = svc.actionTaps.listen(first.add);
        await Future<void>.delayed(Duration.zero);
        await sub1.cancel();

        final sub2 = svc.actionTaps.listen(second.add);
        await Future<void>.delayed(Duration.zero);
        await sub2.cancel();

        // First subscriber got the replayed action; second got nothing.
        check(first).deepEquals(['background:resume']);
        check(second).isEmpty();
      },
    );
  });

  // =========================================================================
  // C6b: RealNotificationService host-reachable branches
  //
  // On the Linux host Platform.isAndroid == false and Platform.isIOS == false.
  // So isChannelEnabled takes its `!isAndroid` (iOS-impl) branch, openChannel-
  // Settings early-returns, requestPermission falls through to the desktop
  // `return true`, and cancel / _onResponse / the top-level _onBackground-
  // Response run unconditionally. The Android-gated branches (channel-query,
  // _channelIdFor) and the iOS requestPermissions branch are device-only and
  // covered on-device / via CI build, not here.
  // =========================================================================

  group('RealNotificationService — host branches (C6b)', () {
    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('requestPermission falls through to true on the desktop/host '
        'branch (neither Android nor iOS)', () async {
      final (svc, _) = await _makeCapturingService();
      check(await svc.requestPermission()).isTrue();
    });

    test('isChannelEnabled queries the iOS impl and maps isEnabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ios = _MockIOSPlugin();
      when(ios.checkPermissions).thenAnswer(
        (_) async => const NotificationsEnabledOptions(
          isEnabled: false,
          isSoundEnabled: false,
          isAlertEnabled: false,
          isBadgeEnabled: false,
          isProvisionalEnabled: false,
          isCriticalEnabled: false,
          isProvidesAppNotificationSettingsEnabled: false,
        ),
      );
      final plugin = _PlatformRoutingPlugin(ios: ios);
      final svc = RealNotificationService(
        plugin: plugin,
        prefsFactory: () async => prefs,
      );
      await svc.init();
      check(await svc.isChannelEnabled(NotificationChannelKey.alarm)).isFalse();
    });

    test('isChannelEnabled returns true (conservative) when the iOS impl '
        'throws', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final ios = _MockIOSPlugin();
      when(ios.checkPermissions).thenThrow(Exception('os error'));
      final plugin = _PlatformRoutingPlugin(ios: ios);
      final svc = RealNotificationService(
        plugin: plugin,
        prefsFactory: () async => prefs,
      );
      await svc.init();
      check(
        await svc.isChannelEnabled(NotificationChannelKey.reminder),
      ).isTrue();
    });

    test('openChannelSettings is a no-op on the non-Android host', () async {
      final (svc, _) = await _makeCapturingService();
      // Must complete without throwing (the caller falls back to
      // permission_handler.openAppSettings on iOS/desktop).
      await svc.openChannelSettings(NotificationChannelKey.alarm);
    });

    test('showSmsRetryExhaustedNotification shows a high-importance retry '
        'notification with a prefixed Retry action', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showSmsRetryExhaustedNotification(
        contactName: 'Ivan',
        actionPayload: 'wm-42',
      );
      check(plugin.shown).length.equals(1);
      final (id, title, _, details) = plugin.shown.first;
      check(id).equals('wm-42'.hashCode);
      check(title!).contains('Ivan');
      final action = details!.android!.actions!.single;
      check(action.id).equals('${kActionRetrySmsPrefix}wm-42');
      check(details.android!.importance).equals(Importance.high);
    });

    test('cancel forwards the id to the plugin', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final plugin = _PlatformRoutingPlugin();
      final svc = RealNotificationService(
        plugin: plugin,
        prefsFactory: () async => prefs,
      );
      await svc.init();
      await svc.cancel(7);
      check(plugin.cancelled).deepEquals([7]);
    });

    test(
      'a foreground notification response is forwarded to actionTaps',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        final received = <String>[];
        final sub = svc.actionTaps.listen(received.add);
        addTearDown(sub.cancel);
        // Invoke the captured onDidReceiveNotificationResponse callback.
        plugin.lastOnResponse?.call(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            actionId: 'ga_retry_sms_job-1',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        check(received).deepEquals(['ga_retry_sms_job-1']);
      },
    );

    test(
      'a response with neither actionId nor payload emits nothing',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        final received = <String>[];
        final sub = svc.actionTaps.listen(received.add);
        addTearDown(sub.cancel);
        plugin.lastOnResponse?.call(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        check(received).isEmpty();
      },
    );
  });

  // =========================================================================
  // C6b: top-level background-response handler persists to SharedPreferences
  // =========================================================================

  group('notificationBackgroundResponse (top-level handler)', () {
    tearDown(() => SharedPreferences.setMockInitialValues({}));

    test(
      'appends the actionId to the persisted pending list (ordered)',
      () async {
        SharedPreferences.setMockInitialValues({
          'pending_notification_actions': ['first'],
        });
        await notificationBackgroundResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
            actionId: 'second',
          ),
        );
        final prefs = await SharedPreferences.getInstance();
        check(
          prefs.getStringList('pending_notification_actions'),
        ).isNotNull().deepEquals(['first', 'second']);
      },
    );

    test(
      'falls back to payload and seeds an empty list when none exists',
      () async {
        SharedPreferences.setMockInitialValues({});
        await notificationBackgroundResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'background:pause',
          ),
        );
        final prefs = await SharedPreferences.getInstance();
        check(
          prefs.getStringList('pending_notification_actions'),
        ).isNotNull().deepEquals(['background:pause']);
      },
    );

    test('a null/empty action id persists nothing', () async {
      SharedPreferences.setMockInitialValues({});
      await notificationBackgroundResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      check(prefs.getStringList('pending_notification_actions')).isNull();
    });
  });

  // -------------------------------------------------------------------------
  // C3: notification disguise (stealth) — foreground service + reminder
  // -------------------------------------------------------------------------

  group('RealNotificationService — notification disguise (#15 C3)', () {
    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'foreground non-stealth uses real channel name + default icon',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showForegroundServiceNotification(
          title: 'Guardian Angela is active',
          body: 'Running',
        );
        final (_, _, _, details) = plugin.shown.first;
        check(details!.android!.channelName).equals('System Service');
        check(details.android!.icon).isNull();
      },
    );

    test('foreground stealth uses generic channel name + neutral icon', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showForegroundServiceNotification(
        title: 'Music',
        body: 'Playing',
        stealth: true,
        fakeName: 'Music',
      );
      final (_, title, _, details) = plugin.shown.first;
      // Title carries the disguise app name (fakeName), supplied by the caller.
      check(title).equals('Music');
      // Channel name is generic; the channel *id* is still session_service.
      check(details!.android!.channelName).equals('Updates');
      check(details.android!.channelId).equals('session_service');
      // A neutral, non-branded status-bar icon is used.
      check(details.android!.icon).equals('ic_stat_stealth');
    });

    test(
      'disguised reminder non-stealth uses real channel + default icon',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(id: 1, title: 'T', body: 'B');
        final (_, _, _, details) = plugin.shown.first;
        check(details!.android!.channelName).equals('Reminders');
        check(details.android!.icon).isNull();
      },
    );

    test('disguised reminder stealth swaps channel name + icon', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showDisguisedReminder(
        id: 1,
        title: 'Calendar event',
        body: 'Tap to view',
        stealth: true,
      );
      final (_, _, _, details) = plugin.shown.first;
      check(details!.android!.channelName).equals('Updates');
      check(details.android!.icon).equals('ic_stat_stealth');
    });

    test(
      'disguised reminder stealth PRESERVES all Extra-35 lock-screen flags',
      () async {
        final (svc, plugin) = await _makeCapturingService();
        await svc.showDisguisedReminder(
          id: 1,
          title: 'T',
          body: 'B',
          stealth: true,
        );
        final (_, _, _, details) = plugin.shown.first;
        // The disguise must NOT weaken the wake-the-locked-device guarantees.
        check(details!.android!.fullScreenIntent).isTrue();
        check(details.android!.importance).equals(Importance.max);
        check(details.android!.priority).equals(Priority.max);
        check(
          details.android!.category,
        ).equals(AndroidNotificationCategory.alarm);
        check(
          details.android!.visibility,
        ).equals(NotificationVisibility.public);
        check(
          details.iOS!.interruptionLevel,
        ).equals(InterruptionLevel.timeSensitive);
      },
    );

    test('foreground stealth preserves ongoing + low importance', () async {
      final (svc, plugin) = await _makeCapturingService();
      await svc.showForegroundServiceNotification(
        title: 'Music',
        body: '',
        stealth: true,
      );
      final (id, _, _, details) = plugin.shown.first;
      check(id).equals(kForegroundNotificationId);
      check(details!.android!.ongoing).isTrue();
      check(details.android!.importance).equals(Importance.low);
    });
  });
}
