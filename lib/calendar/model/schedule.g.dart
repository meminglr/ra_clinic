// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 3;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as int,
      name: fields[1] as String,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      isAllDay: fields[5] as bool,
      description: fields[6] as String?,
    )..colorValue = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.isAllDay)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
