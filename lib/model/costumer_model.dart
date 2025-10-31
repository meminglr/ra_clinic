import 'package:ra_clinic/model/seans_model.dart';

class CostumerModel {
  final String id;
  final String profileImage;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final String startDateString;
  final String endDateString;
  final SeansModel? seans;
  final int? seansCount;
  bool isOptionsActive;
  final DateTime? modifiedDate;
  final List<SeansModel>? seansList;

  CostumerModel({
    this.modifiedDate,
    this.isOptionsActive = false,
    this.startDateString = "",
    this.endDateString = "",
    this.profileImage = "assets/avatar.png",
    this.seansCount,
    this.notes,
    this.seans,
    this.endDate,
    this.seansList,
    required this.id,
    required this.name,
    this.phone,
    required this.startDate,
  });
}
