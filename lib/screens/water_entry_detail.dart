import 'package:flutter/material.dart';
import '../models/water_intake.dart';
import 'package:fluidity/l10n/app_localizations.dart';

class WaterEntryDetailScreen extends StatelessWidget {
  final WaterIntakeEntry entry;

  const WaterEntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addEntry)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.amount}: ${entry.amount} ml', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.access_time), const SizedBox(width: 8), Text(entry.time)]),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.category), const SizedBox(width: 8), Text(entry.type)]),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.comment, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(entry.comment.isNotEmpty ? entry.comment : '-', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
