import 'package:flutter/material.dart';

class Schedule {
  int id;
  String name;
  Color color;
  DateTime startDate, endDate;
  bool isAllDay;

  Schedule({
    required this.id,
    required this.name,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.isAllDay,
  });


}
