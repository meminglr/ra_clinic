// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seans_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeansModelAdapter extends TypeAdapter<SeansModel> {
  @override
  final int typeId = 2;

  @override
  SeansModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeansModel(
      startDateString: fields[2] as String,
      seansNote: fields[5] as String?,
      isDeleted: fields[6] as bool,
      id: fields[0] as String,
      seansCount: fields[4] as int,
      startDate: fields[1] as DateTime,
      endDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SeansModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.startDateString)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.seansCount)
      ..writeByte(5)
      ..write(obj.seansNote)
      ..writeByte(6)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeansModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
