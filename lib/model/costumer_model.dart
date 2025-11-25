import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/model/seans_model.dart';

part 'costumer_model.g.dart';

@HiveType(typeId: 1)
class CostumerModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? phone;
  @HiveField(3)
  final String? notes;
  @HiveField(4)
  final DateTime startDate;
  @HiveField(5)
  final DateTime? endDate;
  @HiveField(6)
  final String startDateString;
  @HiveField(7)
  final String endDateString;
  @HiveField(8)
  final SeansModel? seans;
  @HiveField(9)
  final int? seansCount;
  @HiveField(10)
  final DateTime? modifiedDate;
  @HiveField(11)
  final List<SeansModel> seansList;

  CostumerModel({
    required this.id,
    this.modifiedDate,
    this.startDateString = "",
    this.endDateString = "",
    this.seansCount,
    this.notes,
    this.seans,
    this.endDate,
    this.seansList = const [],
    required this.name,
    this.phone,
    required this.startDate,
  });
}
