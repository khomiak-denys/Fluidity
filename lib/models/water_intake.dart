class WaterIntakeEntry {
  final String id;
  final int amount;
  final String time;
  final String type; // 'glass', 'bottle', 'cup'
  final String comment;

  WaterIntakeEntry({
    required this.id,
    required this.amount,
    required this.time,
    required this.type,
    required this.comment,
  });
}
