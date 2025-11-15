import 'package:flutter/material.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/water_entry.dart'; // WaterEntry model
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/water/water_bloc.dart';
import '../bloc/water/water_state.dart';

// --- Custom Colors (Derived from Tailwind classes) ---
const Color sky50 = Color(0xFFF0F9FF);
const Color sky100 = Color(0xFFE0F2FE);
const Color sky200 = Color(0xFFBAE6FD);
const Color sky600 = Color(0xFF0284C7);
const Color sky700 = Color(0xFF0369A1);
const Color green100 = Color(0xFFDCFCE7);
const Color green600 = Color(0xFF059669);
const Color orange100 = Color(0xFFFFEDD5);
const Color orange600 = Color(0XFFEA580C);
const Color mutedForeground = Color(0xFF6B7280); // text-muted-foreground
const Color borderGray = Color(0xFFE5E7EB); // border-gray-200 / border-sky-200

// WaterIntakeEntry is provided by ../widgets/water_intake.dart

// =========================================================================
// ОСНОВНИЙ ВІДЖЕТ
// =========================================================================

enum StatsPeriod { day, week, month }

class StatisticsScreen extends StatefulWidget {
  final int dailyGoal;

  const StatisticsScreen({
    super.key,
    required this.dailyGoal,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.week;

  // Логіка для розрахунку статистики
  Map<String, dynamic> _calculateStats(List<WaterEntry> allEntries) {
    final now = DateTime.now();
    DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
    bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

    // Filter entries by selected period
    List<WaterEntry> filtered;
    List<Map<String, dynamic>> bars = [];

    // Pre-calc week and month ranges for cross-period summaries
    final startOfWeek = dayStart(now).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    switch (_period) {
      case StatsPeriod.day:
        final start = dayStart(now);
        final end = start.add(const Duration(days: 1));
        filtered = allEntries.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(end)).toList();
        // For chart we can show last 7 hours distribution or skip; keep weekly chart area hidden for day
        // We'll use hourly distribution card below.
        bars = [];
        break;
      case StatsPeriod.week:
        // Use pre-calculated Monday-start week
        filtered = allEntries.where((e) => e.timestamp.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(endOfWeek)).toList();
        // Build 7-day bars Mon..Sun with localized labels
        final labels = [
          AppLocalizations.of(context)!.weekdayMonShort,
          AppLocalizations.of(context)!.weekdayTueShort,
          AppLocalizations.of(context)!.weekdayWedShort,
          AppLocalizations.of(context)!.weekdayThuShort,
          AppLocalizations.of(context)!.weekdayFriShort,
          AppLocalizations.of(context)!.weekdaySatShort,
          AppLocalizations.of(context)!.weekdaySunShort,
        ];
        bars = List.generate(7, (i) {
          final day = startOfWeek.add(Duration(days: i));
          final total = filtered.where((e) => isSameDay(e.timestamp, day)).fold<int>(0, (s, e) => s + e.amountMl);
          return {'label': labels[i], 'intake': total};
        });
        break;
      case StatsPeriod.month:
        filtered = allEntries.where((e) => e.timestamp.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(endOfMonth)).toList();
        final daysInMonth = endOfMonth.difference(startOfMonth).inDays;
        bars = List.generate(daysInMonth, (i) {
          final day = startOfMonth.add(Duration(days: i));
          final total = filtered.where((e) => isSameDay(e.timestamp, day)).fold<int>(0, (s, e) => s + e.amountMl);
          return {'label': '${i + 1}', 'intake': total};
        });
        break;
    }

    final periodTotal = filtered.fold<int>(0, (sum, e) => sum + e.amountMl);
    final periodLen = _period == StatsPeriod.day ? 1 : (_period == StatsPeriod.week ? 7 : bars.length);
    final periodAverage = (periodTotal / periodLen).round();
    final todayTotal = allEntries
        .where((e) => isSameDay(e.timestamp, now))
        .fold<int>(0, (sum, e) => sum + e.amountMl);

    // Cross-period totals for cards (always Monday-start week, current month)
    final weekTotal = allEntries
        .where((e) => e.timestamp.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(endOfWeek))
        .fold<int>(0, (s, e) => s + e.amountMl);
    final monthTotal = allEntries
        .where((e) => e.timestamp.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(endOfMonth))
        .fold<int>(0, (s, e) => s + e.amountMl);

    return {
      'bars': bars,
      'filtered': filtered,
      'todayIntake': todayTotal,
      'periodAverage': periodAverage,
      'periodTotal': periodTotal,
      'weekTotal': weekTotal,
      'monthTotal': monthTotal,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Read entries from WaterBloc state
  final state = context.watch<WaterBloc>().state;
    final List<WaterEntry> entries = state is WaterLoaded
        ? state.data
        : state is WaterLoading
            ? state.data
            : state is WaterError
                ? state.data
                : const <WaterEntry>[];

  final data = _calculateStats(entries);
  final bars = data['bars'] as List<Map<String, dynamic>>;
  final todayIntake = data['todayIntake'] as int;
  final periodAverage = data['periodAverage'] as int;
  final periodTotal = data['periodTotal'] as int;
  // final weekTotal = data['weekTotal'] as int; // no longer used directly
  // final monthTotal = data['monthTotal'] as int; // not directly used; periodTotal covers month when selected

  final List<Map<String, dynamic>> stats = [];

  if (_period == StatsPeriod.day) {
    // Day: show only today's intake
    stats.add({
      'title': AppLocalizations.of(context)!.statsTodayTitle,
      'value': '${todayIntake}ml',
      'icon': Icons.opacity_rounded,
      'color': sky600,
      'bgColor': sky100,
    });
  } else if (_period == StatsPeriod.week) {
    // Week: average + weekly total (no today's intake)
    stats.add({
      'title': AppLocalizations.of(context)!.statsAverageTitle,
      'value': '${periodAverage}ml',
      'icon': Icons.trending_up_rounded,
      'color': green600,
      'bgColor': green100,
    });
    stats.add({
      'title': AppLocalizations.of(context)!.statsWeekTotalTitle,
      'value': '${(periodTotal / 1000).toStringAsFixed(1)}L',
      'icon': Icons.calendar_month_rounded,
      'color': orange600,
      'bgColor': orange100,
    });
  } else {
    // Month: average + monthly total (no today's intake)
    stats.add({
      'title': AppLocalizations.of(context)!.statsAverageTitle,
      'value': '${periodAverage}ml',
      'icon': Icons.trending_up_rounded,
      'color': green600,
      'bgColor': green100,
    });
    stats.add({
      'title': AppLocalizations.of(context)!.statsMonthTotalTitle,
      'value': '${(periodTotal / 1000).toStringAsFixed(1)}L',
      'icon': Icons.calendar_month_rounded,
      'color': orange600,
      'bgColor': orange100,
    });
  }

  final headerText = _period == StatsPeriod.day
    ? AppLocalizations.of(context)!.statisticsDaily
    : _period == StatsPeriod.week
      ? AppLocalizations.of(context)!.statisticsWeekly
      : AppLocalizations.of(context)!.statisticsMonthly;

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
  _buildHeader(context, headerText)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Period Selector ---
              _buildPeriodSelector(),

              const SizedBox(height: 12),

              // --- Stats Cards ---
              _buildStatsCards(stats)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Progress Chart (Week/Month) ---
  if (_period != StatsPeriod.day) _buildPeriodChartCard(context, bars)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Hourly Distribution (Today) ---
              if (_period == StatsPeriod.day && entries.isNotEmpty)
                _buildHourlyDistributionCard(context, entries)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    Widget buildButton(String label, StatsPeriod p) {
      final selected = _period == p;
      return Expanded(
        child: OutlinedButton(
          onPressed: () => setState(() => _period = p),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: selected ? sky600 : borderGray),
            backgroundColor: selected ? sky50 : Colors.white,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? sky700 : mutedForeground)),
        ),
      );
    }

    return Row(
      children: [
  buildButton(AppLocalizations.of(context)!.periodDay, StatsPeriod.day),
        const SizedBox(width: 8),
  buildButton(AppLocalizations.of(context)!.periodWeek, StatsPeriod.week),
        const SizedBox(width: 8),
  buildButton(AppLocalizations.of(context)!.periodMonth, StatsPeriod.month),
      ],
    );
  }

  // --- Header Widget ---
  Widget _buildHeader(BuildContext context, String headerText) {
    return Column(
      children: [
        Text(
          headerText,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: sky700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.statisticsSubtitle,
          style: const TextStyle(color: mutedForeground, fontSize: 13),
        ),
      ],
    );
  }

  // --- Stats Cards Widget ---
  Widget _buildStatsCards(List<Map<String, dynamic>> stats) {
    // grid grid-cols-1 gap-3 sm:gap-4
    return Column(
      children: stats.map((stat) {
        final Color iconColor = stat['color'] as Color;
        final Color bgColor = stat['bgColor'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            // bg-gradient-to-r from-white to-sky-50 border-sky-200
            color: sky50, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: sky200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0), // p-3 sm:p-4
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: const TextStyle(color: mutedForeground, fontSize: 13), // text-xs sm:text-sm
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 22, // text-lg sm:text-2xl
                          fontWeight: FontWeight.bold,
                          color: sky700,
                        ),
                      ),
                    ],
                  ),
                  // Icon wrapper (p-2 sm:p-3 rounded-full)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                    ),
                    child: Icon(stat['icon'] as IconData, color: iconColor, size: 24), // w-4 h-4 sm:w-6 sm:h-6
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Weekly Chart Card Widget ---
  Widget _buildPeriodChartCard(BuildContext context, List<Map<String, dynamic>> data) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CardHeader
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // pb-3
            child: Text(
              _period == StatsPeriod.week
                  ? AppLocalizations.of(context)!.statisticsWeekly
                  : AppLocalizations.of(context)!.statisticsMonthly,
              style: const TextStyle(
                color: sky700,
                fontWeight: FontWeight.bold,
                fontSize: 18, // text-base sm:text-lg
              ),
            ),
          ),
          // CardContent
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // pt-0
            child: SizedBox(
              height: 220, // h-48 sm:h-64
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: widget.dailyGoal * 1.2, // Максимальне значення на осі Y
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = rod.toY.toInt();
                        return BarTooltipItem(
                          '${value}ml',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0', style: TextStyle(fontSize: 10, color: mutedForeground));
                          if (value == widget.dailyGoal.toDouble()) return Text('${widget.dailyGoal}ml', style: const TextStyle(fontSize: 10, color: green600));
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final raw = value.toInt();
                          if (data.isEmpty) return const SizedBox.shrink();
                          final index = raw.clamp(0, data.length - 1);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data[index]['label'] as String,
                                style: const TextStyle(fontSize: 10, color: mutedForeground)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      if (value == widget.dailyGoal) {
                        // Імітація лінії цілі (goal)
                        return FlLine(
                          color: green600.withAlpha((0.7 * 255).round()),
                          strokeWidth: 1.5,
                          // FlChart не підтримує пунктирну лінію Goal Line безпосередньо,
                          // але ми можемо імітувати її товстою лінією.
                        );
                      }
                      return FlLine(
                        color: borderGray.withAlpha((0.5 * 255).round()), // CartesianGrid stroke="#e0f7ff"
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (data['intake'] as int).toDouble(),
                          // Використовуємо LinearGradient для імітації градієнта
                          gradient: LinearGradient(
                            colors: [sky600.withAlpha((0.8 * 255).round()), sky600.withAlpha((0.6 * 255).round())],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                          width: 16, // Зменшення ширини для кращого вигляду
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Hourly Distribution Card Widget ---
  Widget _buildHourlyDistributionCard(BuildContext context, List<WaterEntry> entries) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CardHeader
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // pb-3
            child: Text(
              AppLocalizations.of(context)!.hourlyDistribution,
              style: const TextStyle(
                color: sky700,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          // CardContent
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // pt-0
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries
                    .where((e) {
                      final n = DateTime.now();
                      return e.timestamp.year == n.year && e.timestamp.month == n.month && e.timestamp.day == n.day;
                    })
                    .map((entry) {
                  String _fmt(DateTime dt) {
                    final hh = dt.hour.toString().padLeft(2, '0');
                    final mm = dt.minute.toString().padLeft(2, '0');
                    return '$hh:$mm';
                  }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8), // space-y-2
                  child: Container(
                    // p-2 bg-sky-50 rounded-lg
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sky50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Dot (w-2 h-2 bg-sky-500 rounded-full)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8), // gap-2
                            Text(
                              _fmt(entry.timestamp),
                              style: const TextStyle(fontSize: 13, color: mutedForeground), // text-xs sm:text-sm text-muted-foreground
                            ),
                          ],
                        ),
                        Text(
                          '${entry.amountMl}ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500, // font-medium
                            color: sky700,
                            fontSize: 15, // text-sm sm:text-base
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}