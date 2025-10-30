import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reminder.dart';
import 'package:fluidity/l10n/app_localizations.dart';

// Local color tokens to match app style
const Color _sky50 = Color(0xFFF0F9FF);
const Color _sky200 = Color(0xFFBAE6FD);
const Color _sky600 = Color(0xFF0284C7);
const Color _mutedForeground = Color(0xFF6B7280);

class ReminderDetailScreen extends StatelessWidget {
  final Reminder reminder;

  const ReminderDetailScreen({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle ?? const SystemUiOverlayStyle(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button + Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.reminders,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _sky600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reminder.label,
                style: const TextStyle(fontSize: 14, color: _mutedForeground),
              ),
              const SizedBox(height: 16),

              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: _sky200, width: 1),
                ),
                color: _sky50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.access_time, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reminder.time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _sky600)),
                              const SizedBox(height: 6),
                              Text(reminder.label, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(reminder.enabled ? 'Enabled' : 'Disabled', style: TextStyle(color: reminder.enabled ? Colors.green[700] : Colors.grey[600], fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Additional info area
                      Text(AppLocalizations.of(context)!.selectTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(reminder.time, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 16),

                      // Read-only details, no actions here
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
