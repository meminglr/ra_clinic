import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'media_model.dart';
import 'seans_model.dart'; // Dosya yolunu kendine göre ayarla

part 'costumer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel {
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
  DateTime? lastUpdated;
  @HiveField(8)
  final List<SeansModel> seansList;
  @HiveField(9) // Yeni alan
  bool isSynced;
  @HiveField(10)
  bool isDeleted;
  @HiveField(11)
  final List<CostumerMedia> mediaList;
  @HiveField(12)
  String? profileImageUrl;

  CustomerModel({
    required this.customerId,
    this.lastUpdated,
    this.seansCount,
    this.notes,
    this.endDate,
    this.seansList = const [],
    required this.name,
    this.phone,
    required this.startDate,
    this.isSynced = false,
    this.isDeleted = false,
    this.mediaList = const [],
    this.profileImageUrl,
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
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      'seansCount': seansCount,
      // Listeyi de map listesine çevirmeliyiz:
      'seansList': seansList.map((x) => x.toMap()).toList(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'mediaList': mediaList.map((x) => x.toMap()).toList(),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Firebase'den çekerken
  factory CustomerModel.fromMap(Map<String, dynamic> data, String docId) {
    return CustomerModel(
      customerId:
          docId, // Firebase'in kendi ID'sini kullanmak genelde daha güvenlidir
      name: data['name'] ?? '',
      phone: data['phone'],
      notes: data['notes'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
      seansCount: data['seansCount'],
      // Map listesini geri nesne listesine çeviriyoruz:
      seansList: data['seansList'] != null
          ? List<SeansModel>.from(
              (data['seansList'] as List).map(
                (x) => SeansModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      isSynced: true, // Firebase'den gelen veriler senkronizedir
      isDeleted: data['isDeleted'] ?? false,
      mediaList: data['mediaList'] != null
          ? List<CostumerMedia>.from(
              (data['mediaList'] as List).map(
                (x) => CostumerMedia.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  // CostumerModel sınıfının içine ekle:
  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? phone,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    int? seansCount,
    DateTime? lastUpdated,
    List<SeansModel>? seansList,
    bool? isSynced,
    bool? isDeleted,
    List<CostumerMedia>? mediaList,
    String? profileImageUrl,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      seansCount: seansCount ?? this.seansCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      seansList: seansList ?? this.seansList,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaList: mediaList ?? this.mediaList,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
