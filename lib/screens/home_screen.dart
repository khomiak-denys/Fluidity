import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для TextInputType.number
import 'package:fluidity/widgets/water_progress.dart';
import '../models/water_intake.dart';
import '../widgets/water_intake.dart';
import 'package:fluidity/ui/button.dart';

const Color sky50 = Color(0xFFF0F9FF);
const Color cyan50 = Color(0xFFECFEFF);
const Color sky200 = Color(0xFFBAE6FD);
const Color sky600 = Color(0xFF0284C7); // from-sky-600
const Color cyan600 = Color(0xFF06B6D4); // to-cyan-600
const Color sky700 = Color(0xFF0369A1);
const Color green700 = Color(0xFF047857);
const Color green600 = Color(0xFF059669);
const Color green50 = Color(0xFFF0FDF4); // from-green-50
const Color emerald50 = Color(0xFFF0FDF8); // to-emerald-50, використаємо F0FDF4 для емуляції градієнта
const Color green200 = Color(0xFFBBF7D0);
const Color primaryColor = Color(0xFF0EA5E9); // Для FAB

// =========================================================================
// ОСНОВНИЙ ВІДЖЕТ
// =========================================================================

class HomeScreen extends StatefulWidget {
  final int dailyGoal;

  const HomeScreen({super.key, required this.dailyGoal});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Припускаємо, що WaterIntakeEntry - це клас, визначений у water_intake.dart
  List<WaterIntakeEntry> entries = [];

  // Анімаційні контролери для імітації motion.div
  late AnimationController _headerController;
  late AnimationController _goalController;
  late AnimationController _progressController;
  late AnimationController _quickAddController;
  late AnimationController _entriesController;

  @override
  void initState() {
    super.initState();
    // Налаштування контролерів для послідовних анімацій (delay 0.0, 0.2, 0.4, 0.6)
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _goalController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _quickAddController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entriesController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  // Запуск анімацій з затримкою — перевіряємо `mounted` перед forward(),
  // бо delayed callbacks можуть виконатись після dispose.
  if (mounted) _headerController.forward();
  Future.delayed(const Duration(milliseconds: 200), () { if (!mounted) return; _progressController.forward(); });
  Future.delayed(const Duration(milliseconds: 400), () { if (!mounted) return; _quickAddController.forward(); });
  Future.delayed(const Duration(milliseconds: 600), () { if (!mounted) return; _entriesController.forward(); });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _goalController.dispose();
    _progressController.dispose();
    _quickAddController.dispose();
    _entriesController.dispose();
    super.dispose();
  }

  void handleQuickAdd(int amount, String type) {
    final now = TimeOfDay.now();
    setState(() {
      entries.add(WaterIntakeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        time: now.format(context),
        type: type,
        comment: '$amount ml $type'
      ));
    });
    // Імітація sonner toast.success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Додано $amount ml води! 💧'), 
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
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
        comment: comment ?? '',
      ));
    });
  // Закриття діалогу
  Navigator.of(context).pop(); 
  // Оновлення UI
  setState(() {});
    
    // Імітація sonner toast.success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Додано $amount ml води! 💧'), 
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void handleDelete(String id) {
    setState(() {
      entries.removeWhere((e) => e.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Запис видалено'), 
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int get totalIntake => entries.fold(0, (sum, e) => sum + e.amount);

  void _showCustomAddDialog(BuildContext context) {
  setState(() {});
    showDialog(
      context: context,
      builder: (context) {
        return _CustomAddDialog(
          onAdd: handleCustomAdd,
          onClose: () => setState(() {}),
        );
      },
  ).then((_) => setState(() {})); // На випадок закриття через backdrop
  }

  @override
  Widget build(BuildContext context) {
    final bool isGoalAchieved = totalIntake >= widget.dailyGoal;
    
    // Запуск анімації досягнення цілі
    if (isGoalAchieved) {
      if (mounted) _goalController.forward();
    } else {
      if (mounted) _goalController.reverse();
    }

    return Scaffold(
      // AppBar приховано, оскільки Header тепер є частиною скролінгу, як у React
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, 
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // Обгортка для скролінгу та padding
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 96), // p-3 pb-20 space-y-4
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header (motion.div) ---
            _AnimatedHomeHeader(controller: _headerController, totalIntake: totalIntake),
            
            const SizedBox(height: 16), // space-y-4/6

            // --- Goal Achievement Celebration ---
            if (isGoalAchieved)
              _AnimatedGoalCard(controller: _goalController),
            
            if (isGoalAchieved) const SizedBox(height: 16),
            
            // --- Progress Ring (motion.div) ---
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut)),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut)),
                child: WaterProgress(current: totalIntake.toDouble(), goal: widget.dailyGoal.toDouble()),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- Quick Add Section (motion.div) ---
            _AnimatedSection(
              controller: _quickAddController,
              delay: 0.4,
              child: _QuickAddSection(onAdd: handleQuickAdd),
            ),

            const SizedBox(height: 16),
            
            // --- Today's Entries / Empty State (motion.div) ---
            if (entries.isNotEmpty)
              _AnimatedSection(
                controller: _entriesController,
                delay: 0.6,
                child: _EntriesListCard(entries: entries, onDelete: handleDelete),
              )
            else
              _AnimatedSection(
                controller: _entriesController,
                delay: 0.6,
                child: const _EmptyStateCard(),
              ),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: _FloatingActionButton(
        onPressed: () => _showCustomAddDialog(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// =========================================================================
// ДОПОМІЖНІ ВІДЖЕТИ
// =========================================================================

// Загальний віджет для імітації motion.div (fade + slide up)
class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final double delay; // Не використовується для запуску, але для структури
  final Widget child;

  const _AnimatedSection({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}

// Header (імітує Header motion.div)
class _AnimatedHomeHeader extends StatelessWidget {
  final AnimationController controller;
  final int totalIntake;

  const _AnimatedHomeHeader({required this.controller, required this.totalIntake});

  @override
  Widget build(BuildContext context) {
    // Емулюємо Fade + Slide Down (y: -20)
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // h1 (bg-clip-text text-transparent)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [sky600, cyan600],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds);
              },
              child: const Text(
                'Fluidity',
                style: TextStyle(
                  fontSize: 22, // text-xl sm:text-2xl
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Потрібен для ShaderMask
                ),
              ),
            ),
            // p (text-muted-foreground)
            Text(
              'Сьогодні випито: $totalIntake мл',
              style: const TextStyle(fontSize: 14, color: Colors.grey), // text-sm text-muted-foreground
            ),
          ],
        ),
      ),
    );
  }
}

// Goal Achievement Card (імітує motion.div)
class _AnimatedGoalCard extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedGoalCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Емулюємо Fade + Scale (scale: 0.9)
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: green200, width: 1), // border-green-200
          ),
          // bg-gradient-to-r from-green-50 to-emerald-50
          color: green50, // Використовуємо один колір для простоти емуляції градієнта
          child: const Padding(
            padding: EdgeInsets.all(16.0), // p-4
            child: Column(
              children: [
                Text('🎉', style: TextStyle(fontSize: 24)), // text-2xl mb-2
                SizedBox(height: 4), // mb-1
                Text('Вітаємо!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: green700)), // font-semibold text-green-700
                Text('Ви досягли своєї денної цілі!', style: TextStyle(fontSize: 13, color: green600)), // text-sm text-green-600
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Add Section
class _QuickAddSection extends StatelessWidget {
  final void Function(int amount, String type) onAdd;

  const _QuickAddSection({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    // Card className="bg-gradient-to-r from-sky-50 to-cyan-50 border-sky-200"
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: sky200, width: 1), 
      ),
      color: sky50, // Використовуємо один колір для простоти емуляції градієнта
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CardHeader className="pb-3"
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12), // Емуляція CardHeader з pb-3
            child: Text(
              'Додати',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sky700), // CardTitle text-sky-700 text-base sm:text-lg
            ),
          ),
          // CardContent className="pt-0"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-between
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  text: '🥛 200ml',
                  onPressed: () => onAdd(200, 'glass'),
                  variant: ButtonVariant.outline,
                  size: ButtonSize.medium,
                  textColor: Colors.blue,
                  borderColor: Colors.blue,
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: '🍼 500ml',
                  onPressed: () => onAdd(500, 'bottle'),
                  variant: ButtonVariant.outline,
                  size: ButtonSize.medium,
                  textColor: Colors.blue,
                  borderColor: Colors.blue,
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: '☕ 300ml',
                  onPressed: () => onAdd(300, 'cup'),
                  variant: ButtonVariant.outline,
                  size: ButtonSize.medium,
                  textColor: Colors.blue,
                  borderColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Entries List Card (містить CardHeader та CardContent з WaterIntakeCard)
class _EntriesListCard extends StatelessWidget {
  final List<WaterIntakeEntry> entries;
  final void Function(String id) onDelete;

  const _EntriesListCard({required this.entries, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CardHeader
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), // pb-3
            child: Text(
              'Сьогоднішні записи (${entries.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sky700),
            ),
          ),
          // CardContent (space-y-2)
          ...entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WaterIntakeCard( // Припускаємо, що WaterIntakeCard обробляє свій Divider
              entry: entry,
              onDelete: onDelete,
            ),
          )).toList(),
          const SizedBox(height: 16), // Додаємо відступ знизу, як space-y-
        ],
      ),
    );
  }
}


// Empty State Card
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // border-dashed border-2 border-sky-200
        side: const BorderSide(color: sky200, style: BorderStyle.solid, width: 2), 
      ),
      child: const Padding(
        padding: EdgeInsets.all(32.0), 
        child: Column(
          children: [
            Text('💧', style: TextStyle(fontSize: 40)), 
            SizedBox(height: 16), // mb-2
            Text('Почніть відстеження!', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: sky700)), // font-medium text-sky-700
            SizedBox(height: 8), 
            Text(
              'Додайте свій перший запис води, натиснувши на кнопки вище або FAB кнопку', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 14, color: Colors.grey), // text-sm text-muted-foreground
            ),
          ],
        ),
      ),
    );
  }
}

// Floating Action Button
class _FloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FloatingActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const Icon(Icons.add),
    );
}
}

// Custom Add Dialog
class _CustomAddDialog extends StatefulWidget {
  final void Function(int amount, String type, String? comment) onAdd;
  final VoidCallback onClose;

  const _CustomAddDialog({required this.onAdd, required this.onClose});

  @override
  __CustomAddDialogState createState() => __CustomAddDialogState();
}

class __CustomAddDialogState extends State<_CustomAddDialog> {
  final _amountController = TextEditingController();
  String _selectedType = 'glass';
  String _comment = '';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  // Додано для ініціалізації
  @override
  void initState() {
    super.initState();
    // Слухаємо зміни для оновлення стану та перевірки на валідність
    _amountController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final int amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final bool isDisabled = amount <= 0;

    return AlertDialog(
      // Імітація w-[90vw] max-w-sm
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      
      // DialogHeader
      title: const Text('Додати води', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // text-base sm:text-lg
      
      // DialogContent
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input
            const Text('Кількість (мл)', style: TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: 'Введіть кількість в мл',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              // onChanged: (_) => setState(() {}), // Оновлюється через addListener
            ),
            const SizedBox(height: 16), // space-y-4
            
            // Type Select
            const Text('Тип посуду', style: TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'glass', child: Text('🥛 Glass', style: TextStyle(fontSize: 16))),
                DropdownMenuItem(value: 'bottle', child: Text('🍼 Bottle', style: TextStyle(fontSize: 16))),
                DropdownMenuItem(value: 'cup', child: Text('☕ Cup', style: TextStyle(fontSize: 16))),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
            ),
            const SizedBox(height: 16),
            
            // Comment Textarea
            const Text('Коментар (опціонально)', style: TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
            const SizedBox(height: 4),
            TextField(
              maxLines: 2, // rows={2}
              onChanged: (v) => _comment = v,
              decoration: const InputDecoration(
                hintText: 'Додайте коментар...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons (flex gap-2)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Скасувати',
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onClose(); // Повідомити, що діалог закрито
                    },
                    variant: ButtonVariant.outline,
                    size: ButtonSize.medium, // min-h-[44px]
                  ),
                ),
                const SizedBox(width: 8), // gap-2
                Expanded(
                  child: AppButton(
                    text: 'Зберегти',
                    onPressed: isDisabled ? null : () => widget.onAdd(amount, _selectedType, _comment.isEmpty ? null : _comment),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium, // min-h-[44px]
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