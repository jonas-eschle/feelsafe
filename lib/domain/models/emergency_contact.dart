/// `EmergencyContact` — a single emergency contact with messaging
/// channels and an optional per-contact SMS language.
library;

import 'package:guardianangela/data/models/enums.dart';

/// One of the user's emergency contacts.
final class EmergencyContact {
  /// Creates an emergency contact.
  ///
  /// [id] — stable UUID.
  /// [name] — human-readable name, non-empty.
  /// [phoneNumber] — E.164-preferred phone number.
  /// [relationship] — optional informational label (e.g., "Mom").
  /// [sortOrder] — manual ordering key; lower = earlier.
  /// [channels] — messaging channels enabled for this contact;
  /// defaults to ALL channels enabled
  /// (sms + whatsapp + telegram + phoneCall).
  /// [languageCode] — optional per-contact SMS language override;
  /// null = use app language.
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.sortOrder,
    this.relationship,
    this.channels = const [
      MessageChannel.sms,
      MessageChannel.whatsapp,
      MessageChannel.telegram,
      MessageChannel.phoneCall,
    ],
    this.languageCode,
  });

  /// Deserializes an `EmergencyContact` from JSON.
  factory EmergencyContact.fromJson(Map<String, Object?> json) {
    final rawChannels = json['channels'];
    return EmergencyContact(
      id: json['id']! as String,
      name: json['name']! as String,
      phoneNumber: json['phoneNumber']! as String,
      relationship: json['relationship'] as String?,
      sortOrder: (json['sortOrder']! as num).toInt(),
      channels: rawChannels is List
          ? List<MessageChannel>.unmodifiable(
              rawChannels.map((e) => _channelFromJson(e)),
            )
          : const [MessageChannel.sms],
      languageCode: json['languageCode'] as String?,
    );
  }

  /// Stable identifier (UUID).
  final String id;

  /// Display name.
  final String name;

  /// Phone number (E.164 preferred).
  final String phoneNumber;

  /// Optional relationship label. Defaults to null.
  final String? relationship;

  /// Zero-based sort order; lower appears first.
  final int sortOrder;

  /// Messaging channels enabled for this contact. Defaults to
  /// `[MessageChannel.sms]`.
  final List<MessageChannel> channels;

  /// Optional SMS language override; null = use app language.
  final String? languageCode;

  /// Returns a new contact with the given fields replaced.
  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    int? sortOrder,
    List<MessageChannel>? channels,
    String? languageCode,
  }) => EmergencyContact(
    id: id ?? this.id,
    name: name ?? this.name,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    relationship: relationship ?? this.relationship,
    sortOrder: sortOrder ?? this.sortOrder,
    channels: channels ?? this.channels,
    languageCode: languageCode ?? this.languageCode,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'relationship': relationship,
    'sortOrder': sortOrder,
    'channels': channels.map((c) => c.name).toList(growable: false),
    'languageCode': languageCode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.relationship == relationship &&
        other.sortOrder == sortOrder &&
        _channelsEqual(other.channels, channels) &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phoneNumber,
    relationship,
    sortOrder,
    Object.hashAll(channels),
    languageCode,
  );

  @override
  String toString() =>
      'EmergencyContact(id: $id, name: $name, '
      'phoneNumber: $phoneNumber, channels: $channels)';
}

MessageChannel _channelFromJson(Object? raw) => switch (raw) {
  'sms' => MessageChannel.sms,
  'whatsapp' => MessageChannel.whatsapp,
  'telegram' => MessageChannel.telegram,
  'phoneCall' => MessageChannel.phoneCall,
  _ => throw ArgumentError.value(raw, 'channel', 'unknown MessageChannel'),
};

bool _channelsEqual(List<MessageChannel> a, List<MessageChannel> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
