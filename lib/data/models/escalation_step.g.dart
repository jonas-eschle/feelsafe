// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'escalation_step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EscalationStepAdapter extends TypeAdapter<EscalationStep> {
  @override
  final int typeId = 3;

  @override
  EscalationStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EscalationStep(
      type: fields[0] as EscalationStepType,
      timeoutSeconds: fields[1] as int,
      enabled: fields[2] as bool,
      order: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EscalationStep obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.timeoutSeconds)
      ..writeByte(2)
      ..write(obj.enabled)
      ..writeByte(3)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscalationStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EscalationStepTypeAdapter extends TypeAdapter<EscalationStepType> {
  @override
  final int typeId = 2;

  @override
  EscalationStepType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EscalationStepType.countdownWarning;
      case 1:
        return EscalationStepType.disguisedReminder;
      case 2:
        return EscalationStepType.fakeCall;
      case 3:
        return EscalationStepType.smsContacts;
      case 4:
        return EscalationStepType.loudAlarm;
      case 5:
        return EscalationStepType.callEmergencyServices;
      default:
        return EscalationStepType.countdownWarning;
    }
  }

  @override
  void write(BinaryWriter writer, EscalationStepType obj) {
    switch (obj) {
      case EscalationStepType.countdownWarning:
        writer.writeByte(0);
        break;
      case EscalationStepType.disguisedReminder:
        writer.writeByte(1);
        break;
      case EscalationStepType.fakeCall:
        writer.writeByte(2);
        break;
      case EscalationStepType.smsContacts:
        writer.writeByte(3);
        break;
      case EscalationStepType.loudAlarm:
        writer.writeByte(4);
        break;
      case EscalationStepType.callEmergencyServices:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscalationStepTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
