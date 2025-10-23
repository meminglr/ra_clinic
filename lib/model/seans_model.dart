import 'package:flutter/widgets.dart';

class SeansModel {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final int seansCount;
  final TextEditingController noteController = TextEditingController();
  String? seansNote;
  bool isDeleted;

  SeansModel(
    this.description, {
    this.seansNote,
    this.isDeleted = false,
    required this.seansCount,
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
  });
}
