import 'package:hive/hive.dart';

part 'seans_model.g.dart';

@HiveType(typeId: 2)
class SeansModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final DateTime startDate;
  @HiveField(2)
  final String startDateString;
  @HiveField(3)
  final DateTime? endDate;
  @HiveField(4)
  final int seansCount;
  @HiveField(5)
  String? seansNote;
  @HiveField(6)
  bool isDeleted;

  SeansModel({
    this.startDateString = "",
    this.seansNote,
    this.isDeleted = false,
    required this.id,
    required this.seansCount,
    required this.startDate,
    this.endDate,
  });
}
