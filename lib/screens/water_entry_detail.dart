import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/water_intake.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/ui/button.dart';

// Local color tokens (kept small to avoid circular imports)
const Color _sky50 = Color(0xFFF0F9FF);
const Color _sky200 = Color(0xFFBAE6FD);
const Color _sky600 = Color(0xFF0284C7);
const Color _mutedForeground = Color(0xFF6B7280);

class WaterEntryDetailScreen extends StatelessWidget {
  final WaterIntakeEntry entry;

  const WaterEntryDetailScreen({super.key, required this.entry});

  static const Map<String, String> _typeIcons = {
    'glass': '🥛',
    'bottle': '🍼',
    'cup': '☕',
  };

  static const Map<String, String> _typeLabels = {
    'glass': 'Glass',
    'bottle': 'Bottle',
    'cup': 'Cup',
  };

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
              // Header
              Text(
                AppLocalizations.of(context)!.addEntry,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _sky600),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.addEntry,
                style: const TextStyle(fontSize: 13, color: _mutedForeground),
              ),
              const SizedBox(height: 16),

              // Detail Card
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
                            child: Text(_typeIcons[entry.type] ?? '💧', style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.amount} ml', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _sky600)),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(entry.time, style: const TextStyle(color: Colors.grey))]),
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
                            child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_typeLabels[entry.type] ?? entry.type), const SizedBox(width: 6), Text('•', style: TextStyle(color: Colors.grey.shade400)), const SizedBox(width: 6), Text('${entry.amount} ml', style: const TextStyle(fontWeight: FontWeight.w600))]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.comment, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(entry.comment.isNotEmpty ? entry.comment : '-', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: AppLocalizations.of(context)!.entryDeleted, // reuse localization for destructive label
                              onPressed: () {
                                // For now just pop and let parent handle deletion; could wire a callback later
                                Navigator.of(context).pop();
                              },
                              variant: ButtonVariant.destructive,
                              size: ButtonSize.medium,
                              icon: Icons.delete,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: AppLocalizations.of(context)!.cancel,
                              onPressed: () => Navigator.of(context).pop(),
                              variant: ButtonVariant.outline,
                              size: ButtonSize.medium,
                            ),
                          ),
                        ],
                      ),
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
