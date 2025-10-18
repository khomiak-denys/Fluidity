class Reminder {
  final String id;
  final String time; // Format "HH:mm"
  final bool enabled;
  final String label;

  Reminder({
    required this.id,
    required this.time,
    required this.enabled,
    required this.label,
  });

  Reminder copyWith({bool? enabled}) {
    return Reminder(
      id: id,
      time: time,
      enabled: enabled ?? this.enabled,
      label: label,
    );
  }
}
