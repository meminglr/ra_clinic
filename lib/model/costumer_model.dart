import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'seans_model.dart'; // Dosya yolunu kendine göre ayarla

part 'costumer_model.g.dart';

@HiveType(typeId: 1)
class CostumerModel {
  @HiveField(0)
  final String customerId;
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
  final int? seansCount;
  @HiveField(7)
   DateTime? modifiedDate;
  @HiveField(8)
  final List<SeansModel> seansList;
  @HiveField(9) // Yeni alan
  bool isSynced;

  CostumerModel({
    required this.customerId,
    this.modifiedDate,
    this.seansCount,
    this.notes,
    this.endDate,
    this.seansList = const [],
    required this.name,
    this.phone,
    required this.startDate,
    this.isSynced = false,
  });

  // Firebase'e gönderirken
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'name': name,
      'phone': phone,
      'notes': notes,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'modifiedDate': modifiedDate != null ? Timestamp.fromDate(modifiedDate!) : null,
      'seansCount': seansCount,
      // Listeyi de map listesine çevirmeliyiz:
      'seansList': seansList.map((x) => x.toMap()).toList(),
    };
  }

  // Firebase'den çekerken
  factory CostumerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CostumerModel(
      customerId: docId, // Firebase'in kendi ID'sini kullanmak genelde daha güvenlidir
      name: map['name'] ?? '',
      phone: map['phone'],
      notes: map['notes'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null ? (map['endDate'] as Timestamp).toDate() : null,
      modifiedDate: map['modifiedDate'] != null ? (map['modifiedDate'] as Timestamp).toDate() : null,
      seansCount: map['seansCount'],
      // Map listesini geri nesne listesine çeviriyoruz:
      seansList: map['seansList'] != null
          ? List<SeansModel>.from(
              (map['seansList'] as List).map((x) => SeansModel.fromMap(x as Map<String, dynamic>)),
            )
          : [],
    );
  }
}