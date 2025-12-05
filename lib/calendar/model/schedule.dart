import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp için

part 'schedule.g.dart';

@HiveType(typeId: 3)
class Schedule extends HiveObject {
  @HiveField(0)
  String id; // DEĞİŞTİ: int -> String (UUID için)

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  @HiveField(5)
  bool isAllDay;

  @HiveField(6)
  String? description;

  // --- YENİ EKLENEN SYNC ALANLARI ---
  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  bool isDeleted;

  @HiveField(9)
  DateTime? lastUpdated;

  Schedule({
    required this.id,
    required this.name,
    Color? color,
    required this.startDate,
    required this.endDate,
    required this.isAllDay,
    this.description,
    this.isSynced = false,
    this.isDeleted = false,
    this.lastUpdated,
  }) : colorValue = (color ?? Colors.blue).value;

  // Renk almak için yardımcı metod
  Color get color => Color(colorValue);

  // --- COPYWITH (GÜNCELLEME İÇİN GEREKLİ) ---
  Schedule copyWith({
    String? id,
    String? name,
    Color? color,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    String? description,
    bool? isSynced,
    bool? isDeleted,
    DateTime? lastUpdated,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? Color(this.colorValue),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAllDay: isAllDay ?? this.isAllDay,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // --- FIREBASE'E GÖNDERME (SERIALIZATION) ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue, // Rengi int olarak saklamak en kolayıdır
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isAllDay': isAllDay,
      'description': description,
      'isDeleted': isDeleted,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
      // isSynced alanını Firebase'e göndermeyiz
    };
  }

  // --- FIREBASE'DEN ALMA (DESERIALIZATION) ---
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      name: map['name'],
      color: Color(map['colorValue'] ?? 0xFF2196F3),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isAllDay: map['isAllDay'] ?? false,
      description: map['description'],
      isDeleted: map['isDeleted'] ?? false,
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      isSynced: true, // Firebase'den geldiyse zaten sync olmuştur
    );
  }
}
