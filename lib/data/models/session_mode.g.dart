// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModeAdapter extends TypeAdapter<SessionMode> {
  @override
  final int typeId = 8;

  @override
  SessionMode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionMode(
      id: fields[0] as String,
      name: fields[1] as String,
      iconName: fields[2] as String?,
      checkInMechanism: fields[3] as CheckInMechanism,
      checkInIntervalSeconds: fields[4] as int,
      missedTolerance: fields[5] as int,
      escalationSteps: (fields[6] as List).cast<EscalationStep>(),
      reminderTemplateIds: (fields[7] as List).cast<String>(),
      isBuiltIn: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionMode obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconName)
      ..writeByte(3)
      ..write(obj.checkInMechanism)
      ..writeByte(4)
      ..write(obj.checkInIntervalSeconds)
      ..writeByte(5)
      ..write(obj.missedTolerance)
      ..writeByte(6)
      ..write(obj.escalationSteps)
      ..writeByte(7)
      ..write(obj.reminderTemplateIds)
      ..writeByte(8)
      ..write(obj.isBuiltIn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CheckInMechanismAdapter extends TypeAdapter<CheckInMechanism> {
  @override
  final int typeId = 7;

  @override
  CheckInMechanism read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CheckInMechanism.holdButton;
      case 1:
        return CheckInMechanism.disguisedReminder;
      default:
        return CheckInMechanism.holdButton;
    }
  }

  @override
  void write(BinaryWriter writer, CheckInMechanism obj) {
    switch (obj) {
      case CheckInMechanism.holdButton:
        writer.writeByte(0);
        break;
      case CheckInMechanism.disguisedReminder:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInMechanismAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
