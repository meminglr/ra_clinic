import 'package:flutter/widgets.dart';

class SeansModel {
  final int id;
  final String name;
  final DateTime startDate;
  final String startDateString;
  final DateTime? endDate;
  final int seansCount;
  final TextEditingController noteController = TextEditingController();
  String? seansNote;
  bool isDeleted;

  SeansModel({
    this.startDateString = "",
    this.seansNote,
    this.isDeleted = false,
    required this.seansCount,
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
  });
}
