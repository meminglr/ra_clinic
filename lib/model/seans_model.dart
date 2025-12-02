// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

part 'seans_model.g.dart';

@HiveType(typeId: 2)
class SeansModel {
  @HiveField(0)
  final String id;
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'startDate': startDate.millisecondsSinceEpoch,
      'startDateString': startDateString,
      'endDate': endDate?.millisecondsSinceEpoch,
      'seansCount': seansCount,
      'seansNote': seansNote,
      'isDeleted': isDeleted,
    };
  }

  factory SeansModel.fromMap(Map<String, dynamic> map) {
    return SeansModel(
      id: map['id'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      startDateString: map['startDateString'] as String,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
          : null,
      seansCount: map['seansCount'] as int,
      seansNote: map['seansNote'] != null ? map['seansNote'] as String : null,
      isDeleted: map['isDeleted'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory SeansModel.fromJson(String source) =>
      SeansModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
