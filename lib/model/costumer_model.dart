import 'package:ra_clinic/model/seans_model.dart';

class CostumerModel {
  final String id;
  final String name;
  final String phone;
  final String? notes;
  final String startDate;
  final DateTime? endDate;
  final SeansModel? seans;
  final int? seansCount;
  final List<SeansModel>? seansList;

  CostumerModel({
    this.seansCount,
    this.notes,
    this.seans,
    this.endDate,
    this.seansList,
    required this.id,
    required this.name,
    required this.phone,
    required this.startDate,
  });
}
