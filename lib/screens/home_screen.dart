import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:flutter/services.dart'; // Для TextInputType.number
import 'package:fluidity/widgets/water_progress.dart';
import '../models/water_entry.dart';
import '../widgets/water_intake.dart';
import 'package:fluidity/ui/button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/water/water_bloc.dart';
import '../bloc/water/water_event.dart';
import '../bloc/water/water_state.dart';
import 'water_entry_detail.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  // Data is managed by WaterBloc; local entries list removed

  void handleQuickAdd(int amount, String type) {
    final now = DateTime.now();
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: now,
      drinkType: type,
      comment: '$amount ml $type',
    );
    context.read<WaterBloc>().add(AddWaterEntryEvent(entry));
    // Імітація sonner toast.success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.waterAdded(amount)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void handleCustomAdd(int amount, String type, String? comment) {
    final now = DateTime.now();
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: now,
      drinkType: type,
      comment: comment ?? '',
    );
    context.read<WaterBloc>().add(AddWaterEntryEvent(entry));
    // Закриття діалогу
    Navigator.of(context).pop();
    
    // Імітація sonner toast.success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.waterAdded(amount)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void handleDelete(String id) {
    context.read<WaterBloc>().add(DeleteWaterEntryEvent(id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.entryDeleted),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _sumIntake(List<WaterEntry> entries) => entries.fold(0, (sum, e) => sum + e.amountMl);

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
    // Read current water state from bloc
    final waterState = context.watch<WaterBloc>().state;
  final List<WaterEntry> entries =
    waterState is WaterLoaded ? waterState.data : (waterState is WaterLoading ? waterState.data : (waterState is WaterError ? waterState.data : <WaterEntry>[]));
    final int totalIntake = _sumIntake(entries);

    // Determine whether goal is achieved (no animations)
    final bool isGoalAchieved = totalIntake >= widget.dailyGoal;

    return BlocListener<WaterBloc, WaterState>(
      listener: (context, state) {}, // keep listener for future hooks; inline error UI shows the error
      child: Scaffold(
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
            // --- Header ---
            _HomeHeader(totalIntake: totalIntake),
            
            const SizedBox(height: 16), // space-y-4/6

            // --- Goal Achievement Celebration ---
            if (isGoalAchieved) const _GoalCard(),
            
            if (isGoalAchieved) const SizedBox(height: 16),
            
            // --- Progress Ring ---
            WaterProgress(current: totalIntake.toDouble(), goal: widget.dailyGoal.toDouble()),
            
            const SizedBox(height: 16),
            
            // --- Quick Add Section ---
            _QuickAddSection(onAdd: handleQuickAdd),

            const SizedBox(height: 16),
            
            // --- Today's Entries / Empty State / Error State ---
            if (waterState is WaterError)
              _ErrorStateCard(message: waterState.error.toString())
            else if (entries.isNotEmpty)
              _EntriesListCard(entries: entries, onDelete: handleDelete)
            else
              const _EmptyStateCard(),
          ],
        ),
      ),
      
      // Floating Action Button
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FloatingActionButton(
            onPressed: () => _showCustomAddDialog(context),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// =========================================================================
// ДОПОМІЖНІ ВІДЖЕТИ
// =========================================================================

// Static Header (no animations)
class _HomeHeader extends StatelessWidget {
  final int totalIntake;

  const _HomeHeader({required this.totalIntake});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          '${AppLocalizations.of(context)!.statsTodayTitle}: $totalIntake ml',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}

// Static Goal Card (no animations)
class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: green200, width: 1),
      ),
      color: green50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.congratulations, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: green700)),
            Text(AppLocalizations.of(context)!.goalReached, style: const TextStyle(fontSize: 13, color: green600)),
          ],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), // Емуляція CardHeader з pb-3
            child: Text(
              AppLocalizations.of(context)!.quickAddTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sky700), // CardTitle text-sky-700 text-base sm:text-lg
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
  final List<WaterEntry> entries;
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
              // CardContent (use ListView.builder so it's a proper list)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WaterEntryDetailScreen(entry: entry))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: WaterIntakeCard(
                          entry: entry,
                          onDelete: onDelete,
                        ),
                      ),
                    );
                  },
                ),
              ),
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
      child: Padding(
        padding: const EdgeInsets.all(32.0), 
        child: Column(
          children: [
            const Text('💧', style: TextStyle(fontSize: 40)), 
            const SizedBox(height: 16), // mb-2
            Text(AppLocalizations.of(context)!.startTrackingTitle, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: sky700)), // font-medium text-sky-700
            const SizedBox(height: 8), 
            Text(
              AppLocalizations.of(context)!.startTrackingBody, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 14, color: Colors.grey), // text-sm text-muted-foreground
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
  title: Text(AppLocalizations.of(context)!.addWater, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // text-base sm:text-lg
      
      // DialogContent
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input
            Text('${AppLocalizations.of(context)!.amount} (ml)', style: const TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: null,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              // onChanged: (_) => setState(() {}), // Оновлюється через addListener
            ),
            const SizedBox(height: 16), // space-y-4
            
            // Type Select
            Text(AppLocalizations.of(context)!.typeLabel, style: const TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
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
            Text(AppLocalizations.of(context)!.comment, style: const TextStyle(fontSize: 14, color: Colors.black54)), // Label text-sm
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
                    text: AppLocalizations.of(context)!.cancel,
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
                    text: AppLocalizations.of(context)!.save,
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

// Error State Card (shows inline where the list would be)
class _ErrorStateCard extends StatelessWidget {
  final String message;

  const _ErrorStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: sky200, style: BorderStyle.solid, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text('Error loading entries', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            AppButton(
              text: 'Retry',
              onPressed: () => context.read<WaterBloc>().add(RefreshWaterEvent()),
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}