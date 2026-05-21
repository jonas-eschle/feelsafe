import 'package:guardianangela/domain/enums/message_channel.dart';

/// An emergency contact who receives notifications during a safety session.
///
/// Persisted as one row in the Drift `contacts` table. See spec 03
/// §EmergencyContact.
///
/// All enabled channels are used for every step that contacts this person
/// unless the [ChainStep]'s [SmsContactConfig.channel] specifies a single
/// channel (decision 15/15b).
final class EmergencyContact {
  /// Creates an emergency contact.
  ///
  /// [id] must be non-empty. [name] must be non-empty and at most 255
  /// characters. [sortOrder] must be ≥ 0.
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    required this.sortOrder,
    this.channels = const <MessageChannel>[MessageChannel.sms],
    this.languageCode,
  }) : assert(id.isNotEmpty, 'EmergencyContact.id must be non-empty'),
       assert(
         name.isNotEmpty && name.length <= 255,
         'EmergencyContact.name must be 1–255 characters',
       ),
       assert(sortOrder >= 0, 'EmergencyContact.sortOrder must be >= 0');

  /// Deserialises an [EmergencyContact] from [json].
  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phoneNumber: json['phoneNumber'] as String,
        relationship: json['relationship'] as String?,
        sortOrder: (json['sortOrder'] as num).toInt(),
        channels: (json['channels'] as List<dynamic>)
            .map((e) => MessageChannel.values.byName(e as String))
            .toList(),
        languageCode: json['languageCode'] as String?,
      );

  /// UUID — primary key.
  final String id;

  /// Display name shown in the UI and SMS templates.
  final String name;

  /// Phone number in E.164 format (e.g., `+15551234567`).
  final String phoneNumber;

  /// Optional human relationship label (e.g., "Mom", "Friend").
  final String? relationship;

  /// 0-based position in the contacts list (for display and
  /// [SmsContactSelection.firstContact] resolution).
  final int sortOrder;

  /// Active messaging channels for this contact.
  ///
  /// Defaults to `[MessageChannel.sms]`. Non-nullable.
  final List<MessageChannel> channels;

  /// Per-contact SMS language override.
  ///
  /// Null = use the app language ([AppSettings.languageCode]).
  final String? languageCode;

  /// Returns a copy with the specified fields replaced.
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

  /// Serialises this contact to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    if (relationship != null) 'relationship': relationship,
    'sortOrder': sortOrder,
    'channels': channels.map((c) => c.name).toList(),
    if (languageCode != null) 'languageCode': languageCode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! EmergencyContact) {
      return false;
    }
    if (channels.length != other.channels.length) {
      return false;
    }
    for (var i = 0; i < channels.length; i++) {
      if (channels[i] != other.channels[i]) {
        return false;
      }
    }
    return id == other.id &&
        name == other.name &&
        phoneNumber == other.phoneNumber &&
        relationship == other.relationship &&
        sortOrder == other.sortOrder &&
        languageCode == other.languageCode;
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
}
