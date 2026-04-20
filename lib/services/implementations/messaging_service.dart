/// Real messaging-service implementation.
///
/// Dart-side only. The Android native side lives under
/// `com.guardianangela.app/sms` (WorkManager + SEND_SMS + retries); it
/// lands in Phase 10. iOS falls back to `url_launcher` with `sms:`
/// URIs. WhatsApp and Telegram always use `url_launcher` deep-links.
///
/// [sendMessage] respects `isSimulation` (4-layer defense layer 2):
/// in simulation mode, no real send is attempted — a simulated work
/// id is returned and a fake delivery update is emitted.
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Real platform-backed implementation of
/// [MessagingServiceProtocol].
final class MessagingService implements MessagingServiceProtocol {
  /// Creates the real messaging service.
  MessagingService() {
    _subscribeToNativeDelivery();
  }

  /// Method channel for Android SEND_SMS + WorkManager scheduling.
  /// Phase 10 wires the native side.
  static const MethodChannel _smsChannel = MethodChannel(
    'com.guardianangela.app/sms',
  );

  /// Event channel for WorkManager delivery status updates.
  /// Phase 10 wires the native side.
  static const EventChannel _smsEventChannel = EventChannel(
    'com.guardianangela.app/sms_events',
  );

  final Uuid _uuid = const Uuid();
  final StreamController<MessageDeliveryUpdate> _deliveryController =
      StreamController<MessageDeliveryUpdate>.broadcast();
  final StreamController<SmsRetryExhaustedEvent> _retryExhaustedController =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  /// Cache of enqueued work for `retryExhaustedSms`.
  final Map<String, _PendingSend> _pending = <String, _PendingSend>{};

  StreamSubscription<Object?>? _nativeEventSub;

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates =>
      _deliveryController.stream;

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      _retryExhaustedController.stream;

  @override
  Future<bool> canAutoSend(MessageChannel channel) async {
    // SMS can be sent silently only on Android (requires native bridge).
    // WhatsApp/Telegram always route via url_launcher (user-visible).
    return channel == MessageChannel.sms && Platform.isAndroid;
  }

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async {
    final id = _uuid.v4();
    if (isSimulation) {
      developer.log(
        '[SIM-BLOCK] messaging.sendMessage '
        'to=${contact.phoneNumber} channel=${channel.name}',
      );
      _deliveryController.add(
        MessageDeliveryUpdate(workId: id, status: 'simulated'),
      );
      return MessageWorkId(id);
    }
    _pending[id] = _PendingSend(
      recipient: contact.phoneNumber,
      message: message,
      channel: channel,
    );

    switch (channel) {
      case MessageChannel.sms:
        await _sendSms(id, contact.phoneNumber, message);
      case MessageChannel.whatsapp:
        await _sendWhatsApp(id, contact.phoneNumber, message);
      case MessageChannel.telegram:
        await _sendTelegram(id, contact.phoneNumber, message);
      case MessageChannel.phoneCall:
        throw ArgumentError.value(
          channel,
          'channel',
          'phoneCall is handled by PhoneService, not MessagingService',
        );
    }
    return MessageWorkId(id);
  }

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async {
    final results = <MessageWorkId>[];
    for (final contact in contacts) {
      for (final channel in contact.channels) {
        if (channel == MessageChannel.phoneCall) continue;
        results.add(
          await sendMessage(
            contact: contact,
            message: message,
            channel: channel,
            isSimulation: isSimulation,
          ),
        );
      }
    }
    return results;
  }

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    for (final id in workIds) {
      _pending.remove(id.value);
    }
    try {
      await _smsChannel.invokeMethod<void>('cancelPending', {
        'workIds': workIds.map((w) => w.value).toList(),
      });
    } on MissingPluginException {
      developer.log('messaging.cancelPending not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'messaging.cancelPending platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<void> retryExhaustedSms(String workId) async {
    final entry = _pending[workId];
    if (entry == null) {
      developer.log('messaging.retryExhaustedSms: unknown workId=$workId');
      return;
    }
    try {
      await _smsChannel.invokeMethod<void>('retry', {
        'workId': workId,
        'recipient': entry.recipient,
        'message': entry.message,
      });
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log(
        'messaging.retryExhaustedSms platform error',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<void> _sendSms(String workId, String recipient, String message) async {
    if (Platform.isAndroid) {
      try {
        await _smsChannel.invokeMethod<void>('send', {
          'workId': workId,
          'recipient': recipient,
          'message': message,
        });
        _deliveryController.add(
          MessageDeliveryUpdate(workId: workId, status: 'queued'),
        );
        return;
      } on MissingPluginException {
        // Phase 10 not wired — surface a deterministic error.
        return Future.error('Not wired — Phase 10');
      } on PlatformException catch (e, s) {
        developer.log('sms send platform error', error: e, stackTrace: s);
        rethrow;
      }
    }
    // iOS: open SMS composer via url_launcher.
    final uri = Uri(
      scheme: 'sms',
      path: recipient,
      queryParameters: {'body': message},
    );
    final ok = await launchUrl(uri);
    _deliveryController.add(
      MessageDeliveryUpdate(workId: workId, status: ok ? 'handoff' : 'failed'),
    );
  }

  Future<void> _sendWhatsApp(
    String workId,
    String recipient,
    String message,
  ) async {
    final sanitized = _digitsOnly(recipient);
    final uri = Uri.parse(
      'https://wa.me/$sanitized?text=${Uri.encodeComponent(message)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    _deliveryController.add(
      MessageDeliveryUpdate(workId: workId, status: ok ? 'handoff' : 'failed'),
    );
  }

  Future<void> _sendTelegram(
    String workId,
    String recipient,
    String message,
  ) async {
    final sanitized = _digitsOnly(recipient);
    final uri = Uri.parse(
      'https://t.me/+$sanitized?text=${Uri.encodeComponent(message)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    _deliveryController.add(
      MessageDeliveryUpdate(workId: workId, status: ok ? 'handoff' : 'failed'),
    );
  }

  String _digitsOnly(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

  void _subscribeToNativeDelivery() {
    if (!Platform.isAndroid) return;
    try {
      _nativeEventSub = _smsEventChannel.receiveBroadcastStream().listen(
        _onNativeEvent,
        onError: (Object e, StackTrace s) {
          developer.log('sms event stream error', error: e, stackTrace: s);
        },
      );
    } on MissingPluginException {
      // Phase 10 not wired yet.
      developer.log('sms event channel not wired — Phase 10');
    }
  }

  /// Cancels the native event subscription. Intended for app-shutdown
  /// cleanup; callers that never dispose the service can safely skip
  /// this.
  Future<void> dispose() async {
    await _nativeEventSub?.cancel();
    _nativeEventSub = null;
    await _deliveryController.close();
    await _retryExhaustedController.close();
  }

  void _onNativeEvent(Object? rawEvent) {
    if (rawEvent is! Map) return;
    final map = Map<String, Object?>.from(rawEvent);
    final type = map['type'] as String?;
    final workId = map['workId'] as String?;
    if (workId == null) return;
    if (type == 'retry_exhausted') {
      final entry = _pending[workId];
      _retryExhaustedController.add(
        SmsRetryExhaustedEvent(
          workId: workId,
          recipient: entry?.recipient ?? '',
          message: entry?.message ?? '',
        ),
      );
    } else {
      final status = map['status'] as String? ?? type ?? 'unknown';
      _deliveryController.add(
        MessageDeliveryUpdate(workId: workId, status: status),
      );
    }
  }
}

/// Internal cache entry for retry plumbing.
final class _PendingSend {
  _PendingSend({
    required this.recipient,
    required this.message,
    required this.channel,
  });

  final String recipient;
  final String message;
  final MessageChannel channel;
}
