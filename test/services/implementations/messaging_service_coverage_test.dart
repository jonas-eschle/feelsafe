/// Coverage tests for [MessagingService] — targets the
/// `MissingPluginException` catch block in `_subscribeToNativeDelivery`
/// (lines 261-263).
///
/// On Android when the event channel's native side is not yet wired
/// (Phase 10), `receiveBroadcastStream().listen(...)` throws a
/// [MissingPluginException]. The catch block must silently swallow it.
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/services/implementations/messaging_service.dart';

import 'channel_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The SMS method channel must be present to avoid unhandled exceptions
  // from other MessagingService calls.
  const smsChannel = MethodChannel('com.guardianangela.app/sms');

  // The SMS event channel that the service subscribes to on Android.
  const smsEventChannel = EventChannel('com.guardianangela.app/sms_events');

  group('MessagingService._subscribeToNativeDelivery', () {
    test(
      'swallows MissingPluginException when event channel not wired on Android',
      () async {
        // Arrange: install a regular method channel mock so SMS sends don't fail.
        installMethodChannelMock(smsChannel);

        // Make the event channel's listen() call throw MissingPluginException.
        // EventChannel uses MethodChannel(name) with the listen method internally.
        final eventMethodChannel = MethodChannel(
          smsEventChannel.name,
          smsEventChannel.codec,
        );
        installMethodChannelMock(
          eventMethodChannel,
          responder: (_) {
            throw MissingPluginException(
              'No implementation found for method listen',
            );
          },
        );

        // Act: create MessagingService with isAndroid=true so the subscribe
        // path is entered. If MissingPluginException propagates, the
        // constructor throws.
        MessagingService? service;
        check(() {
          service = MessagingService(
            platform: const FakePlatformInfo(isAndroid: true),
          );
        }).returnsNormally();

        // Assert: service was created successfully.
        check(service).isNotNull();
        await service!.dispose();
      },
    );
  });
}
