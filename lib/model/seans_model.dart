import 'package:flutter/widgets.dart';

class SeansModel {
  final int id;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final int seansCount;
  final TextEditingController noteController = TextEditingController();

  SeansModel(
    this.description, {
    required this.seansCount,
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });
}
