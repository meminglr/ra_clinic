// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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
    this.endDate,
    this.seansList = const [],
    required this.name,
    this.phone,
    required this.startDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'startDateString': startDateString,
      'endDateString': endDateString,
      'seansCount': seansCount,
      'modifiedDate': modifiedDate?.millisecondsSinceEpoch,
      'seansList': seansList.map((x) => x.toMap()).toList(),
    };
  }

  factory CostumerModel.fromMap(Map<String, dynamic> map) {
    return CostumerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] != null ? map['phone'] as String : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int) : null,
      startDateString: map['startDateString'] as String,
      endDateString: map['endDateString'] as String,
      seansCount: map['seansCount'] != null ? map['seansCount'] as int : null,
      modifiedDate: map['modifiedDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['modifiedDate'] as int) : null,
      seansList: List<SeansModel>.from((map['seansList'] as List<int>).map<SeansModel>((x) => SeansModel.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory CostumerModel.fromJson(String source) => CostumerModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
