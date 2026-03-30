import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../data/models/emergency_contact.dart';

class MessagingService {
  /// Send a message to a contact using their preferred channel.
  /// Returns true if the message was sent/launched successfully.
  Future<bool> sendMessage({
    required EmergencyContact contact,
    required String message,
  }) async {
    return switch (contact.preferredChannel) {
      MessageChannel.sms => _sendSms(contact.phoneNumber, message),
      MessageChannel.whatsapp => _sendWhatsApp(contact.phoneNumber, message),
      MessageChannel.telegram => _sendTelegram(contact.phoneNumber, message),
      MessageChannel.phoneCall => _callContact(contact.phoneNumber),
    };
  }

  /// Send messages to all contacts.
  /// Returns the number of contacts successfully messaged.
  Future<int> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
  }) async {
    var successCount = 0;
    for (final contact in contacts) {
      final sent = await sendMessage(contact: contact, message: message);
      if (sent) successCount++;
    }
    return successCount;
  }

  Future<bool> _sendSms(String phoneNumber, String message) async {
    if (Platform.isAndroid) {
      // On Android, use programmatic SMS via the sms: URI with body.
      // The telephony package would be needed for truly background SMS,
      // but url_launcher with sms: opens the messaging app pre-filled.
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      return _launch(uri);
    } else {
      // iOS: Open Messages app pre-filled
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );
      return _launch(uri);
    }
  }

  Future<bool> _sendWhatsApp(String phoneNumber, String message) async {
    // Clean phone number: remove spaces, dashes, etc. Keep + prefix.
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    // Remove leading + for wa.me format
    final waNumber = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;

    final uri = Uri.parse(
      'https://wa.me/$waNumber?text=${Uri.encodeComponent(message)}',
    );
    return _launch(uri);
  }

  Future<bool> _sendTelegram(String phoneNumber, String message) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedMessage = Uri.encodeComponent(message);

    // Try Telegram app deep link first
    final tgUri = Uri.parse('tg://msg?to=$cleaned&text=$encodedMessage');
    if (await canLaunchUrl(tgUri)) {
      return launchUrl(tgUri, mode: LaunchMode.externalApplication);
    }

    // Fallback to web deep link
    final tgNumber = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;
    final webUri = Uri.parse('https://t.me/$tgNumber');
    return _launch(webUri);
  }

  Future<bool> _callContact(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    return _launch(uri);
  }

  Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
