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
      seansNote: fields[4] as String?,
      isDeleted: fields[5] as bool,
      seansId: fields[0] as String,
      seansCount: fields[3] as int,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime?,
      imageUrls: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeansModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.seansId)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.seansCount)
      ..writeByte(4)
      ..write(obj.seansNote)
      ..writeByte(5)
      ..write(obj.isDeleted)
      ..writeByte(6)
      ..write(obj.imageUrls);
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
