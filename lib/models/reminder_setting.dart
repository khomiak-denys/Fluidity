import 'package:equatable/equatable.dart';

class ReminderSetting extends Equatable {
  final String id;
  final DateTime scheduledTime;
  final String comment; // Коментар до нагадування (Вимога 4.5)
  final bool isActive;

  const ReminderSetting({
    required this.id,
    required this.scheduledTime,
    required this.comment,
    required this.isActive,
  });
  
  factory ReminderSetting.fromMap(Map<String, dynamic> map, String id) {
    return ReminderSetting(
      id: id,
      // Зберігаємо як ISO 8601 String; конвертуємо назад у DateTime
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      comment: map['comment'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Зберігаємо час як String, щоб уникнути проблем з часовими поясами при повторі
      'scheduledTime': scheduledTime.toIso8601String(), 
      'comment': comment,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, scheduledTime, comment, isActive];
}
