// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

part 'media_model.g.dart';

@HiveType(typeId: 4)
class CostumerMedia extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  DateTime uploadDate;

  CostumerMedia({
    required this.id,
    required this.customerId,
    required this.filePath,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'filePath': filePath,
      'uploadDate': uploadDate.millisecondsSinceEpoch,
    };
  }

  factory CostumerMedia.fromMap(Map<String, dynamic> map) {
    return CostumerMedia(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      filePath: map['filePath'] as String,
      uploadDate: DateTime.fromMillisecondsSinceEpoch(map['uploadDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory CostumerMedia.fromJson(String source) =>
      CostumerMedia.fromMap(json.decode(source) as Map<String, dynamic>);
}
