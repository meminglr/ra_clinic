// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'costumer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CostumerModelAdapter extends TypeAdapter<CostumerModel> {
  @override
  final int typeId = 1;

  @override
  CostumerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CostumerModel(
      id: fields[0] as String,
      modifiedDate: fields[10] as DateTime?,
      startDateString: fields[6] as String,
      endDateString: fields[7] as String,
      seansCount: fields[9] as int?,
      notes: fields[3] as String?,
      seans: fields[8] as SeansModel?,
      endDate: fields[5] as DateTime?,
      seansList: (fields[11] as List).cast<SeansModel>(),
      name: fields[1] as String,
      phone: fields[2] as String?,
      startDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CostumerModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.startDateString)
      ..writeByte(7)
      ..write(obj.endDateString)
      ..writeByte(8)
      ..write(obj.seans)
      ..writeByte(9)
      ..write(obj.seansCount)
      ..writeByte(10)
      ..write(obj.modifiedDate)
      ..writeByte(11)
      ..write(obj.seansList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CostumerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
