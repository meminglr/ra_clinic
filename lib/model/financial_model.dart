import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'financial_model.g.dart';

@HiveType(typeId: 6)
enum TransactionType {
  @HiveField(0)
  debt, // Borç (Hizmet verildi, para alınacak)
  @HiveField(1)
  payment, // Ödeme (Para alındı)
}

@HiveType(typeId: 5)
class FinancialTransaction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final TransactionType type;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime date;

  FinancialTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index, // Enum index
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'] ?? const Uuid().v4(),
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values[map['type'] as int],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}
