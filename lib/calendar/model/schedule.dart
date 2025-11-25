import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 3)
class Schedule extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  // Color Hive tarafından desteklenmediği için int olarak saklıyoruz
  @HiveField(2)
  int colorValue;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  bool isAllDay;

  @HiveField(6)
  String? description;

  Schedule({
    required this.id,
    required this.name,
    Color? color,
    required this.startDate,
    required this.endDate,
    required this.isAllDay,
    this.description,
  }) : 
       colorValue = (color ?? Colors.blue).value;

  Color get color => Color(colorValue);
}
