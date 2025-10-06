import 'package:flutter/material.dart';
import 'widgets/water_progress.dart';
import 'widgets/water_intake.dart';
import 'ui/button.dart';

class HomeScreen extends StatefulWidget {
  final int dailyGoal;

  const HomeScreen({super.key, required this.dailyGoal});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WaterIntakeEntry> entries = [];

  void handleQuickAdd(int amount, String type) {
    final now = TimeOfDay.now();
    setState(() {
      entries.add(WaterIntakeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        time: now.format(context),
        type: type,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Додано $amount ml води! 💧')),
    );
  }

  void handleCustomAdd(int amount, String type, String? comment) {
    final now = TimeOfDay.now();
    setState(() {
      entries.add(WaterIntakeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        time: now.format(context),
        type: type,
      ));
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Додано $amount ml води! 💧')),
    );
  }

  void handleDelete(String id) {
    setState(() {
      entries.removeWhere((e) => e.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запис видалено')),
    );
  }

  int get totalIntake => entries.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    final bool isGoalAchieved = totalIntake >= widget.dailyGoal;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluidity'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView(
          children: [
            // Goal Achievement Celebration
            if (isGoalAchieved)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: const [
                      Text('🎉', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text('Вітаємо!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text('Ви досягли своєї денної цілі!', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Progress Ring
            WaterProgress(current: totalIntake.toDouble(), goal: widget.dailyGoal.toDouble()),
            const SizedBox(height: 16),
            // Quick Add Buttons з AppButton
            Card(
              color: Colors.cyan.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppButton(
                      text: '🥛 200ml',
                      onPressed: () => handleQuickAdd(200, 'glass'),
                      variant: ButtonVariant.primary,
                      size: ButtonSize.medium,
                    ),
                    AppButton(
                      text: '🍼 500ml',
                      onPressed: () => handleQuickAdd(500, 'bottle'),
                      variant: ButtonVariant.primary,
                      size: ButtonSize.medium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Entries List
            if (entries.isNotEmpty)
              Column(
                children: entries
                    .map((entry) => WaterIntakeCard(
                          entry: entry,
                          onDelete: handleDelete,
                        ))
                    .toList(),
              )
            else
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.cyan.shade200, style: BorderStyle.solid, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: const [
                      Text('💧', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 8),
                      Text('Почніть відстеження!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text('Додайте свій перший запис води, натиснувши на кнопки вище або FAB кнопку', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add custom water intake
          showDialog(
            context: context,
            builder: (context) {
              final amountController = TextEditingController();
              String type = 'glass';
              String? comment;
              return AlertDialog(
                title: const Text('Додати води'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Кількість (мл)'),
                    ),
                    DropdownButton<String>(
                      value: type,
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('🥛 Glass')),
                        DropdownMenuItem(value: 'bottle', child: Text('🍼 Bottle')),
                        DropdownMenuItem(value: 'cup', child: Text('☕ Cup')),
                      ],
                      onChanged: (v) {
                        if (v != null) type = v;
                      },
                    ),
                    TextField(
                      onChanged: (v) => comment = v,
                      decoration: const InputDecoration(labelText: 'Коментар (опціонально)'),
                    ),
                  ],
                ),
                actions: [
                  AppButton(
                    text: 'Скасувати',
                    onPressed: () => Navigator.of(context).pop(),
                    variant: ButtonVariant.outline,
                    size: ButtonSize.medium,
                  ),
                  AppButton(
                    text: 'Додати',
                    onPressed: () {
                      final value = int.tryParse(amountController.text) ?? 0;
                      if (value > 0) handleCustomAdd(value, type, comment);
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}