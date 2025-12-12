// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CostumerMediaAdapter extends TypeAdapter<CostumerMedia> {
  @override
  final int typeId = 4;

  @override
  CostumerMedia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CostumerMedia(
      id: fields[0] as String,
      customerId: fields[1] as String,
      filePath: fields[2] as String,
      uploadDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CostumerMedia obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.uploadDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostumerMediaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
