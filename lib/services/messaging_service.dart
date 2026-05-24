// Phase 7 native dependency: SMS on Android uses
// MethodChannel('com.guardianangela.app/sms') — SmsChannel.kt + SmsWorker.kt.
// The Dart side calls enqueueSms / cancelWork and listens for smsRetryExhausted
// events. WhatsApp and Telegram use url_launcher (no custom channel).
// iOS SMS falls back to url_launcher with sms: URI.

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/_phone_number_utils.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel constant
// ---------------------------------------------------------------------------

const MethodChannel _smsChannel =
    MethodChannel('com.guardianangela.app/sms');

// ---------------------------------------------------------------------------
// SmsRetryExhaustedEvent
// ---------------------------------------------------------------------------

/// Payload received when Android WorkManager exhausts all SMS retry attempts.
///
/// See spec 05:288.
final class SmsRetryExhaustedEvent {
  /// Creates a [SmsRetryExhaustedEvent].
  const SmsRetryExhaustedEvent({
    required this.workId,
    required this.phoneNumber,
    required this.contactName,
    required this.message,
    this.error,
  });

  /// WorkManager job ID that exhausted its retries.
  final String workId;

  /// Sanitized destination phone number.
  final String phoneNumber;

  /// Display name of the intended recipient contact.
  final String contactName;

  /// The message body that was never delivered.
  final String message;

  /// Optional error description from the native layer.
  final String? error;

  @override
  String toString() =>
      'SmsRetryExhaustedEvent(workId=$workId, contact=$contactName)';
}

// ---------------------------------------------------------------------------
// RealMessagingService
// ---------------------------------------------------------------------------

/// Production [MessagingServiceProtocol] for SMS, WhatsApp, Telegram, and
/// phone-call channel dispatch.
///
/// Channel dispatch per spec 05 §Channel Dispatch:
/// - **SMS / Android:** MethodChannel `com.guardianangela.app/sms`.
///   Returns the WorkManager [MessageWorkId] for later cancellation.
///   Native code (Phase 7) handles persistent retry queue.
/// - **SMS / iOS:** `url_launcher` with `sms:` URI (pre-fills Messages app).
///   User must press Send. Returns `null`.
/// - **WhatsApp:** `url_launcher` with `wa.me` deep link. Returns `null`.
/// - **Telegram:** `url_launcher` with `tg://` deep link, falls back to
///   `https://t.me/`. Returns `null`.
/// - **PhoneCall:** delegates to the injected [PhoneCallDispatcher] callback.
///   Returns `null`.
///
/// **Retry-exhaustion flow (spec 05:289):** listens to native
/// `smsRetryExhausted` calls from the channel and broadcasts on
/// [smsRetryExhausted]. Subscribes to [notification.actionTaps] and
/// re-enqueues exhausted SMS when the "Retry" action tap is received.
///
/// **Layer 3 simulation guard:** [sendMessage] with `isSimulation: true`
/// logs `sim_blocked` and returns `null` without dispatching.
///
/// **Single constructor location rule:** no `RealMessagingService()` call
/// may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealMessagingService implements MessagingServiceProtocol {
  /// Creates a [RealMessagingService].
  ///
  /// [notification] is used to show SMS-retry-exhausted notifications and to
  /// listen for retry-action taps. [phoneCallDispatcher] is called for the
  /// [MessageChannel.phoneCall] channel; defaults to a no-op.
  RealMessagingService({
    required NotificationServiceProtocol notification,
    Future<bool> Function(String phoneNumber)? phoneCallDispatcher,
  }) : _notification = notification,
       _phoneCallDispatcher = phoneCallDispatcher {
    _initChannel();
    _subscribeActionTaps();
  }

  final NotificationServiceProtocol _notification;
  final Future<bool> Function(String phoneNumber)? _phoneCallDispatcher;

  final StreamController<SmsRetryExhaustedEvent> _exhaustedController =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  /// Cache of exhausted events keyed by action payload (= workId).
  final Map<String, SmsRetryExhaustedEvent> _exhaustedCache = {};

  StreamSubscription<String>? _actionTapsSub;

  // -------------------------------------------------------------------------
  // MessagingServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<MessageWorkId?> sendMessage({
    required EmergencyContact contact,
    required String message,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] sendMessage(${contact.name}) — sim_blocked at Layer 3',
        name: 'MessagingService',
      );
      return null;
    }

    // Dispatch to the single channel this contact is configured with.
    for (final channel in contact.channels) {
      final workId = await _dispatch(
        channel: channel,
        contact: contact,
        message: message,
      );
      // Return first (and only) work-id; Single-Channel Dispatch means at
      // most one channel in the list.
      return workId;
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Extended API (beyond protocol minimum)
  // -------------------------------------------------------------------------

  /// Returns `true` only for SMS on Android — the only channel that auto-sends
  /// without user interaction (spec 05:329).
  bool canAutoSend(MessageChannel channel) =>
      channel == MessageChannel.sms && Platform.isAndroid;

  /// Cancels all queued WorkManager SMS jobs by their work IDs (spec 05:253).
  ///
  /// iOS no-op. Called by the session orchestrator on disarm (A5) to prevent
  /// delayed messages arriving after the user has confirmed safety.
  Future<void> cancelPending(List<MessageWorkId> workIds) async {
    if (!Platform.isAndroid) return;
    if (workIds.isEmpty) return;
    log(
      'cancelPending: ${workIds.length} jobs',
      name: 'MessagingService',
    );
    try {
      await _smsChannel.invokeMethod<void>(
        'cancelWork',
        {'workIds': workIds},
      );
    } catch (e) {
      log('cancelPending error: $e', name: 'MessagingService');
    }
  }

  /// Broadcast stream of SMS retry-exhaustion events (spec 05:291).
  ///
  /// Fired when Android WorkManager exhausts all 10 retry attempts for an
  /// SMS job. The Dart side receives this via the `smsRetryExhausted` method
  /// call from the native channel.
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted =>
      _exhaustedController.stream;

  /// Re-enqueues a failed SMS, returning the new [MessageWorkId] (spec
  /// 05:292).
  ///
  /// Internally calls [sendMessage] with a single-SMS-channel contact copy
  /// so the retry follows the standard enqueue path with exponential backoff.
  Future<MessageWorkId?> retryExhaustedSms(
    SmsRetryExhaustedEvent event,
  ) async {
    log(
      'retryExhaustedSms workId=${event.workId} contact=${event.contactName}',
      name: 'MessagingService',
    );
    final contact = EmergencyContact(
      id: 'retry_${event.workId}',
      name: event.contactName,
      phoneNumber: event.phoneNumber,
      sortOrder: 0,
    );
    return sendMessage(contact: contact, message: event.message);
  }

  /// Disposes stream resources.
  Future<void> dispose() async {
    await _actionTapsSub?.cancel();
    await _exhaustedController.close();
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  void _initChannel() {
    _smsChannel.setMethodCallHandler(_onChannelCall);
  }

  void _subscribeActionTaps() {
    _actionTapsSub = _notification.actionTaps.listen(_onActionTap);
  }

  Future<dynamic> _onChannelCall(MethodCall call) async {
    if (call.method == 'smsRetryExhausted') {
      final args = call.arguments as Map<Object?, Object?>;
      final event = SmsRetryExhaustedEvent(
        workId: args['workId'] as String,
        phoneNumber: args['phoneNumber'] as String,
        contactName: args['contactName'] as String,
        message: args['message'] as String,
        error: args['error'] as String?,
      );
      log(
        'smsRetryExhausted workId=${event.workId}',
        name: 'MessagingService',
      );
      _exhaustedCache[event.workId] = event;
      _exhaustedController.add(event);

      // Show the system retry-exhausted notification (spec 05:293).
      await _notification.showSmsRetryExhaustedNotification(
        contactName: event.contactName,
        actionPayload: event.workId,
      );
    }
    return null;
  }

  void _onActionTap(String actionId) {
    if (!actionId.startsWith(kActionRetrySmsPrefix)) return;
    final payload = actionId.substring(kActionRetrySmsPrefix.length);
    final event = _exhaustedCache[payload];
    if (event == null) {
      log(
        'Retry tap for unknown payload: $payload',
        name: 'MessagingService',
      );
      return;
    }
    retryExhaustedSms(event).then(
      (workId) => log(
        'Retry re-enqueued as $workId',
        name: 'MessagingService',
      ),
    );
  }

  Future<MessageWorkId?> _dispatch({
    required MessageChannel channel,
    required EmergencyContact contact,
    required String message,
  }) async {
    final rawNumber = contact.phoneNumber;

    switch (channel) {
      case MessageChannel.sms:
        return _dispatchSms(contact: contact, message: message);
      case MessageChannel.whatsapp:
        await _dispatchWhatsApp(rawNumber, message);
        return null;
      case MessageChannel.telegram:
        await _dispatchTelegram(rawNumber, message);
        return null;
      case MessageChannel.phoneCall:
        await _dispatchPhoneCall(rawNumber);
        return null;
    }
  }

  Future<MessageWorkId?> _dispatchSms({
    required EmergencyContact contact,
    required String message,
  }) async {
    final number = sanitizePhoneNumber(contact.phoneNumber);
    if (Platform.isAndroid) {
      log('SMS Android enqueue → $number', name: 'MessagingService');
      try {
        final workId = await _smsChannel.invokeMethod<String>(
          'enqueueSms',
          {
            'phoneNumber': number,
            'message': message,
            'contactName': contact.name,
          },
        );
        return workId;
      } catch (e) {
        log('enqueueSms error: $e', name: 'MessagingService');
        return null;
      }
    } else {
      // iOS: sms: URI — user must tap Send.
      final encoded = Uri.encodeComponent(message);
      final uri = Uri.parse('sms:$number?body=$encoded');
      log('SMS iOS url_launcher → $number', name: 'MessagingService');
      await _launchUrl(uri);
      return null;
    }
  }

  Future<void> _dispatchWhatsApp(String rawNumber, String message) async {
    final number = sanitizePhoneNumber(rawNumber);
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$number?text=$encoded');
    log('WhatsApp → $number', name: 'MessagingService');
    await _launchUrl(uri);
  }

  Future<void> _dispatchTelegram(String rawNumber, String message) async {
    final number = sanitizePhoneNumber(rawNumber);
    final encoded = Uri.encodeComponent(message);
    final tgUri = Uri.parse('tg://msg?to=$number&text=$encoded');
    final fallbackUri = Uri.parse('https://t.me/$number');
    log('Telegram → $number', name: 'MessagingService');
    final launched = await _launchUrl(tgUri);
    if (!launched) {
      await _launchUrl(fallbackUri);
    }
  }

  Future<void> _dispatchPhoneCall(String rawNumber) async {
    final number = sanitizePhoneNumber(rawNumber);
    log('PhoneCall channel → $number', name: 'MessagingService');
    final dispatcher = _phoneCallDispatcher;
    if (dispatcher != null) {
      await dispatcher(number);
    }
  }

  Future<bool> _launchUrl(Uri uri) async {
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('launchUrl error for $uri: $e', name: 'MessagingService');
      return false;
    }
  }
}
