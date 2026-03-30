// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fake_call_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FakeCallConfigAdapter extends TypeAdapter<FakeCallConfig> {
  @override
  final int typeId = 6;

  @override
  FakeCallConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FakeCallConfig(
      callerName: fields[0] as String,
      photoPath: fields[1] as String?,
      voiceRecordingPath: fields[2] as String?,
      ringDurationSeconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FakeCallConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.callerName)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.voiceRecordingPath)
      ..writeByte(3)
      ..write(obj.ringDurationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeCallConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
