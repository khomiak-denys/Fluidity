import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/water_entry.dart';
import 'package:fluidity/l10n/app_localizations.dart';
// import 'package:fluidity/ui/button.dart'; // not needed anymore

// Local color tokens (kept small to avoid circular imports)
const Color _sky50 = Color(0xFFF0F9FF);
const Color _sky200 = Color(0xFFBAE6FD);
const Color _sky600 = Color(0xFF0284C7);
// muted foreground color removed (not used in this file)

class WaterEntryDetailScreen extends StatelessWidget {
  final WaterEntry entry;

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
    String _formatTime(DateTime dt) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
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
                      AppLocalizations.of(context)!.addEntry,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _sky600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                            child: Text(_typeIcons[entry.drinkType] ?? '💧', style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.amountMl} ml', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _sky600)),
                              const SizedBox(height: 6),
                              Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(_formatTime(entry.timestamp), style: const TextStyle(color: Colors.grey))]),
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
                            child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_typeLabels[entry.drinkType] ?? entry.drinkType), const SizedBox(width: 6), Text('•', style: TextStyle(color: Colors.grey.shade400)), const SizedBox(width: 6), Text('${entry.amountMl} ml', style: const TextStyle(fontWeight: FontWeight.w600))]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.comment, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(entry.comment?.isNotEmpty == true ? entry.comment! : '-', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 16),

                      // No action buttons here — details are read-only in this view
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
