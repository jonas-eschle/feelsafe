// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = 1;

  @override
  EmergencyContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyContact(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      relationship: fields[3] as String?,
      sortOrder: fields[4] as int,
      preferredChannel: fields[5] as MessageChannel,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.relationship)
      ..writeByte(4)
      ..write(obj.sortOrder)
      ..writeByte(5)
      ..write(obj.preferredChannel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageChannelAdapter extends TypeAdapter<MessageChannel> {
  @override
  final int typeId = 0;

  @override
  MessageChannel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageChannel.sms;
      case 1:
        return MessageChannel.whatsapp;
      case 2:
        return MessageChannel.telegram;
      case 3:
        return MessageChannel.phoneCall;
      default:
        return MessageChannel.sms;
    }
  }

  @override
  void write(BinaryWriter writer, MessageChannel obj) {
    switch (obj) {
      case MessageChannel.sms:
        writer.writeByte(0);
        break;
      case MessageChannel.whatsapp:
        writer.writeByte(1);
        break;
      case MessageChannel.telegram:
        writer.writeByte(2);
        break;
      case MessageChannel.phoneCall:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
