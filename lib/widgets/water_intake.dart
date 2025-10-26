import 'package:flutter/material.dart';
import '../models/water_intake.dart';

class WaterIntakeCard extends StatelessWidget {
  final WaterIntakeEntry entry;
  final void Function(String) onDelete;
  final String unit;

  const WaterIntakeCard({
    super.key,
    required this.entry,
    required this.onDelete,
    this.unit = 'ml',
  });

  static const Map<String, String> typeIcons = {
    'glass': '🥛',
    'bottle': '🍼',
    'cup': '☕',
  };

  static const Map<String, String> typeLabels = {
    'glass': 'Glass',
    'bottle': 'Bottle',
    'cup': 'Cup',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.cyan.shade100),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        typeIcons[entry.type]!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.opacity, size: 16, color: Colors.cyan[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.amount}$unit',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.cyan[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              entry.time,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                typeLabels[entry.type]!,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => onDelete(entry.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
