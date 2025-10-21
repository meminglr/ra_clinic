import 'package:ra_clinic/model/seans_model.dart';

class CostumerModel {
  final String id;
  final String profileImage;
  final String name;
  final String phone;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final SeansModel? seans;
  final int? seansCount;
  final List<SeansModel>? seansList;

  CostumerModel({
    this.profileImage = "assets/avatar.png",
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
