import 'package:hive/hive.dart';

part 'emergency_contact.g.dart';

@HiveType(typeId: 0)
enum MessageChannel {
  @HiveField(0)
  sms,

  @HiveField(1)
  whatsapp,

  @HiveField(2)
  telegram,

  @HiveField(3)
  phoneCall,
}

@HiveType(typeId: 1)
class EmergencyContact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phoneNumber;

  @HiveField(3)
  String? relationship;

  @HiveField(4)
  int sortOrder;

  @HiveField(5)
  MessageChannel preferredChannel;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    this.sortOrder = 0,
    this.preferredChannel = MessageChannel.sms,
  });

  EmergencyContact copyWith({
    String? name,
    String? phoneNumber,
    String? relationship,
    int? sortOrder,
    MessageChannel? preferredChannel,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      sortOrder: sortOrder ?? this.sortOrder,
      preferredChannel: preferredChannel ?? this.preferredChannel,
    );
  }
}
