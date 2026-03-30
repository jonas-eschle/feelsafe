// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderTemplateAdapter extends TypeAdapter<ReminderTemplate> {
  @override
  final int typeId = 5;

  @override
  ReminderTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      title: fields[2] as String,
      body: fields[3] as String,
      iconAsset: fields[4] as String?,
      confirmationType: fields[5] as ConfirmationType,
      keyword: fields[6] as String?,
      buttonLabel: fields[7] as String?,
      isCustom: fields[8] as bool,
      imagePath: fields[9] as String?,
      subtitle: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderTemplate obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.iconAsset)
      ..writeByte(5)
      ..write(obj.confirmationType)
      ..writeByte(6)
      ..write(obj.keyword)
      ..writeByte(7)
      ..write(obj.buttonLabel)
      ..writeByte(8)
      ..write(obj.isCustom)
      ..writeByte(9)
      ..write(obj.imagePath)
      ..writeByte(10)
      ..write(obj.subtitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConfirmationTypeAdapter extends TypeAdapter<ConfirmationType> {
  @override
  final int typeId = 4;

  @override
  ConfirmationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConfirmationType.tapButton;
      case 1:
        return ConfirmationType.tapWord;
      case 2:
        return ConfirmationType.swipe;
      case 3:
        return ConfirmationType.dismiss;
      default:
        return ConfirmationType.tapButton;
    }
  }

  @override
  void write(BinaryWriter writer, ConfirmationType obj) {
    switch (obj) {
      case ConfirmationType.tapButton:
        writer.writeByte(0);
        break;
      case ConfirmationType.tapWord:
        writer.writeByte(1);
        break;
      case ConfirmationType.swipe:
        writer.writeByte(2);
        break;
      case ConfirmationType.dismiss:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
