import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Reminder {
  final String id;
  final String time;
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

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Reminder> _reminders = [];

  String _newTime = "";
  String _newLabel = "";

  void _addReminder(String time, String label) {
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: time,
      label: label,
      enabled: true,
    );
    setState(() => _reminders.add(newReminder));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нагадування додано!")));
  }

  void _toggleReminder(String id) {
    setState(() {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] =
            _reminders[index].copyWith(enabled: !_reminders[index].enabled);
      }
    });
  }

  void _deleteReminder(String id) {
    setState(() => _reminders.removeWhere((r) => r.id == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нагадування видалено!")));
  }

  void _showAddReminderDialog() {
    _newTime = "";
    _newLabel = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Додати нагадування"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Час (наприклад, 08:30)"),
                  onChanged: (v) => _newTime = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Коментар"),
                  onChanged: (v) => _newLabel = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Скасувати"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newTime.isNotEmpty && _newLabel.isNotEmpty) {
                  _addReminder(_newTime, _newLabel);
                  Navigator.pop(context);
                }
              },
              child: const Text("Зберегти"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Header
            Column(
              children: [
                Text(
                  "Нагадування",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Встановіть нагадування випити води",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .moveY(begin: -20, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 24),

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Додати"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showAddReminderDialog,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .moveY(begin: 20, end: 0),

            const SizedBox(height: 16),

            // Reminders List
            ..._reminders.asMap().entries.map((e) {
              final i = e.key;
              final reminder = e.value;
              final color = reminder.enabled ? Colors.blue.shade50 : Colors.grey.shade200;
              return Card(
                color: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: reminder.enabled
                        ? Colors.blue.shade200
                        : Colors.grey.shade300,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: reminder.enabled
                                ? Colors.blue.shade500
                                : Colors.grey,
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.time,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: reminder.enabled
                                      ? Colors.blue.shade700
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                reminder.label,
                                style: TextStyle(
                                  color: reminder.enabled
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: reminder.enabled,
                            onChanged: (_) => _toggleReminder(reminder.id),
                            activeColor: Colors.blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red.shade400,
                            onPressed: () => _deleteReminder(reminder.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (300 + i * 100).ms)
                  .moveX(begin: -20, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}
