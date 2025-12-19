// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'costumer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerModelAdapter extends TypeAdapter<CustomerModel> {
  @override
  final int typeId = 1;

  @override
  CustomerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerModel(
      customerId: fields[0] as String,
      lastUpdated: fields[7] as DateTime?,
      seansCount: fields[6] as int?,
      notes: fields[3] as String?,
      endDate: fields[5] as DateTime?,
      seansList: (fields[8] as List).cast<SeansModel>(),
      name: fields[1] as String,
      phone: fields[2] as String?,
      startDate: fields[4] as DateTime,
      isSynced: fields[9] as bool,
      isDeleted: fields[10] as bool,
      mediaList: (fields[11] as List).cast<CostumerMedia>(),
      profileImageUrl: fields[12] as String?,
      transactions: (fields[13] as List).cast<FinancialTransaction>(),
      isArchived: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.customerId)
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
      ..write(obj.seansCount)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.seansList)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.isDeleted)
      ..writeByte(11)
      ..write(obj.mediaList)
      ..writeByte(12)
      ..write(obj.profileImageUrl)
      ..writeByte(13)
      ..write(obj.transactions)
      ..writeByte(14)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
