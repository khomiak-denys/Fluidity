import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart'; // needed for SystemUiOverlayStyle
import 'package:fluidity/l10n/app_localizations.dart';
import '../models/reminder.dart';
import 'reminder_detail.dart';
import '../models/reminder_setting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../bloc/reminder/reminder_event.dart';
import '../bloc/reminder/reminder_state.dart';

// --- Custom Colors (Derived from Tailwind classes) ---
const Color sky50 = Color(0xFFF0F9FF);
const Color cyan50 = Color(0xFFECFEFF);
const Color sky200 = Color(0xFFBAE6FD);
const Color sky500 = Color(0xFF0EA5E9); // from-sky-500
const Color cyan500 = Color(0xFF06B6D4); // to-cyan-500
const Color sky600 = Color(0xFF0284C7);
const Color sky700 = Color(0xFF0369A1);
const Color gray50 = Color(0xFFF9FAFB);
const Color gray200 = Color(0xFFE5E7EB);
const Color gray400 = Color(0xFF9CA3AF);
const Color mutedForeground = Color(0xFF6B7280); // text-muted-foreground
const Color red500 = Color(0xFFEF4444);

// =========================================================================
// ЕКРАН НАГАДУВАНЬ
// =========================================================================

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  void _addReminder(String time, String label) {
    DateTime _parseHHmmToToday(String hhmm) {
      final parts = hhmm.split(':');
      final now = DateTime.now();
      if (parts.length == 2) {
        final h = int.tryParse(parts[0]) ?? now.hour;
        final m = int.tryParse(parts[1]) ?? now.minute;
        return DateTime(now.year, now.month, now.day, h, m);
      }
      return now;
    }
    final rs = ReminderSetting(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scheduledTime: _parseHHmmToToday(time),
      comment: label,
      isActive: true,
    );
    context.read<ReminderBloc>().add(AddReminderEvent(rs));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.reminderAdded), behavior: SnackBarBehavior.floating));
  }

  void _toggleReminder(String id) {
    context.read<ReminderBloc>().add(ToggleReminderEvent(id));
  }

  void _deleteReminder(String id) {
    context.read<ReminderBloc>().add(DeleteReminderEvent(id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.reminderDeleted), behavior: SnackBarBehavior.floating));
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _AddReminderDialog(
          onAdd: _addReminder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // p-3 pb-20 space-y-4
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header ---
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              // --- Add Button ---
              _buildAddButton()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20),

              // --- Reminders List ---
              _buildReminderList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.reminders,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: sky700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.remindersSubtitle,
          style: const TextStyle(color: mutedForeground, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    // Button className="w-full h-12 bg-gradient-to-r from-sky-500 to-cyan-500"
    return ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 20, color: Colors.white),
  label: Text(AppLocalizations.of(context)!.addReminder, style: const TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 48), // h-12
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Емуляція градієнта
        backgroundColor: sky500, // Використовуємо один колір, оскільки градієнт на кнопці складніше
        elevation: 3,
      ),
      onPressed: _showAddReminderDialog,
    );
  }

  Widget _buildReminderList() {
    String _fmt(DateTime dt) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    final state = context.watch<ReminderBloc>().state;
    final items = state is ReminderLoaded
        ? state.data
        : state is ReminderLoading
            ? state.data
            : state is ReminderError
                ? state.data
                : <ReminderSetting>[];

    if (state is ReminderLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.remindersEmpty));
    }
    // Map domain items to UI reminders for display
    final ui = items
        .map((r) => Reminder(id: r.id, time: _fmt(r.scheduledTime), label: r.comment, enabled: r.isActive))
        .toList();

    return Column(
      children: ui.asMap().entries.map((e) {
        final i = e.key;
        final reminder = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final found = items.firstWhere((r) => r.id == reminder.id, orElse: () => ReminderSetting(
                id: reminder.id,
                scheduledTime: DateTime.now(),
                comment: reminder.label,
                isActive: reminder.enabled,
              ));
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReminderDetailScreen(reminder: found)));
            },
            child: _ReminderCard(
              reminder: reminder,
              onToggle: _toggleReminder,
              onDelete: _deleteReminder,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: (300 + i * 100).ms).slideX(begin: -0.1, end: 0),
        );
      }).toList(),
    );
  }
}

// =========================================================================
// ДОПОМІЖНІ ВІДЖЕТИ
// =========================================================================

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = reminder.enabled;

    // bg-gradient-to-r from-sky-50 to-cyan-50 border-sky-200 : bg-gray-50 border-gray-200
    final Color bgColor = enabled ? sky50 : gray50;
    final Color borderColor = enabled ? sky200 : gray200;
    final Color timeColor = enabled ? sky700 : Colors.grey.shade600;
    final Color labelColor = enabled ? sky600 : gray400;
    final Color avatarBgColor = enabled ? sky500 : Colors.grey.shade400;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16), // p-4
        child: Row(
          children: [
            // Left flexible content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarBgColor,
                    ),
                    child: const Icon(Icons.access_time, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.time,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: timeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.label,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            color: labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Fixed trailing actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: enabled,
                  onChanged: (_) => onToggle(reminder.id),
                  activeThumbColor: sky500,
                  activeTrackColor: sky500.withAlpha((0.24 * 255).round()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: red500,
                  onPressed: () => onDelete(reminder.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddReminderDialog extends StatefulWidget {
  final Function(String time, String label) onAdd;

  const _AddReminderDialog({required this.onAdd});

  @override
  __AddReminderDialogState createState() => __AddReminderDialogState();
}

class __AddReminderDialogState extends State<_AddReminderDialog> {
  TimeOfDay? _selectedTime;
  final TextEditingController _labelController = TextEditingController();

  // Форматуємо TimeOfDay у рядок "HH:mm" для відображення та збереження
  String get _formattedTime {
    if (_selectedTime == null) return AppLocalizations.of(context)!.selectTime;
    final now = DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
  // Avoid intl dependency issues in some environments — format manually
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleSave() {
    if (_selectedTime != null && _labelController.text.trim().isNotEmpty) {
      widget.onAdd(_formattedTime, _labelController.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaveDisabled = _selectedTime == null || _labelController.text.trim().isEmpty;

    return AlertDialog(
      // Імітація w-[90vw] max-w-sm
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      
      // DialogHeader
  title: Text(AppLocalizations.of(context)!.addReminder, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
      
      // DialogContent
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Picker Button
            Text(AppLocalizations.of(context)!.selectTime, style: const TextStyle(fontSize: 14, color: mutedForeground)),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_formattedTime, style: const TextStyle(fontSize: 16)),
              onPressed: _pickTime,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Label Input
            Text(AppLocalizations.of(context)!.comment, style: const TextStyle(fontSize: 14, color: mutedForeground)),
            const SizedBox(height: 4),
            TextField(
              controller: _labelController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: null,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons (flex gap-2)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(minimumSize: const Size(0, 44)), // min-h-[44px]
                    child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8), 
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaveDisabled ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44), 
                      backgroundColor: sky500,
                      foregroundColor: Colors.white,
                    ),
                      child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}