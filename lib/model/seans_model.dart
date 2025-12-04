import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için gerekli
import 'package:hive_flutter/hive_flutter.dart';

part 'seans_model.g.dart';

@HiveType(typeId: 2)
class SeansModel {
  @HiveField(0)
  final String seansId;
  @HiveField(1)
  final DateTime startDate;
  @HiveField(2)
  final DateTime? endDate;
  @HiveField(3)
  final int seansCount;
  @HiveField(4)
  String? seansNote;
  @HiveField(5)
  bool isDeleted;

  SeansModel({
    this.seansNote,
    this.isDeleted = false,
    required this.seansId,
    required this.seansCount,
    required this.startDate,
    this.endDate,
  });

  // Firebase'e veri gönderirken (Nesne -> Map)
  Map<String, dynamic> toMap() {
    return {
      'seansId': seansId,
      'startDate': Timestamp.fromDate(startDate), // DateTime -> Timestamp
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'seansCount': seansCount,
      'seansNote': seansNote,
      'isDeleted': isDeleted,
    };
  }

  // Firebase'den veri çekerken (Map -> Nesne)
  factory SeansModel.fromMap(Map<String, dynamic> map) {
    return SeansModel(
      seansId: map['seansId'] ?? '',
      // Timestamp -> DateTime dönüşümü çok önemlidir:
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      seansCount: map['seansCount']?.toInt() ?? 0,
      seansNote: map['seansNote'],
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  SeansModel copyWith({
    String? seansId,
    DateTime? startDate,
    DateTime? endDate,
    int? seansCount,
    String? seansNote,
    bool? isDeleted,
  }) {
    return SeansModel(
      seansId: seansId ?? this.seansId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      seansCount: seansCount ?? this.seansCount,
      seansNote: seansNote ?? this.seansNote,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}