import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WaterEntry extends Equatable {
  final String id; // Document ID
  final int amountMl; // Кількість (Вимога 4.2)
  final DateTime timestamp; // Час запису (Вимога 4.2)
  final String drinkType; // Тип напою
  final String? comment; // Коментар (опціонально)

  const WaterEntry({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.drinkType,
    this.comment,
  });

  factory WaterEntry.fromMap(Map<String, dynamic> map, String id) {
    final rawTs = map['timestamp'];
    final ts = rawTs is Timestamp ? rawTs.toDate() : DateTime.tryParse(rawTs?.toString() ?? '') ?? DateTime.now();
    return WaterEntry(
      id: id,
      amountMl: map['amountMl'] ?? 0,
      timestamp: ts,
      drinkType: map['drinkType'] ?? 'Вода',
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amountMl': amountMl,
      'timestamp': Timestamp.fromDate(timestamp),
      'drinkType': drinkType,
      'comment': comment,
    };
  }

  @override
  List<Object?> get props => [id, amountMl, timestamp, drinkType, comment];
}
