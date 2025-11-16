class Reminder {
  final String id;
  final String time; // formatted HH:mm
  final String label;
  final bool enabled;

  const Reminder({
    required this.id,
    required this.time,
    required this.label,
    required this.enabled,
  });

  Reminder copyWith({
    String? id,
    String? time,
    String? label,
    bool? enabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
    );
  }
}
