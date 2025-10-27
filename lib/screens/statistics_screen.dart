import 'package:flutter/material.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/water_intake.dart'; // WaterIntakeEntry model

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

class StatisticsScreen extends StatelessWidget {
  final List<WaterIntakeEntry> entries;
  final int dailyGoal;

  const StatisticsScreen({
    super.key,
    required this.entries,
    required this.dailyGoal,
  });

  // Логіка для розрахунку статистики
  Map<String, dynamic> _calculateStats() {
    final todayIntake = entries.fold<int>(0, (sum, e) => sum + e.amount);

    final weeklyData = [
      {'day': 'Пн', 'intake': 1800, 'goal': dailyGoal},
      {'day': 'Вт', 'intake': 2200, 'goal': dailyGoal},
      {'day': 'Ср', 'intake': 1900, 'goal': dailyGoal},
      {'day': 'Чт', 'intake': 2400, 'goal': dailyGoal},
      {'day': 'Пт', 'intake': 2100, 'goal': dailyGoal},
      {'day': 'Сб', 'intake': 1700, 'goal': dailyGoal},
      {
        'day': 'Нд',
        'intake': todayIntake,
        'goal': dailyGoal,
      },
    ];

    final weekTotal = weeklyData.fold<int>(0, (sum, d) => sum + (d['intake'] as int));
    final weekAverage = (weekTotal / 7).round();

    return {
      'weeklyData': weeklyData,
      'todayIntake': todayIntake,
      'weekAverage': weekAverage,
      'weekTotal': weekTotal,
    };
  }

  @override
  Widget build(BuildContext context) {
  final data = _calculateStats();
  final weeklyData = data['weeklyData'] as List<Map<String, dynamic>>;
  final todayIntake = data['todayIntake'] as int;
  final weekAverage = data['weekAverage'] as int;
  final weekTotal = data['weekTotal'] as int;

  final stats = [
    {
      'title': AppLocalizations.of(context)!.statsTodayTitle,
      'value': '${todayIntake}ml',
      'icon': Icons.opacity_rounded,
      'color': sky600,
      'bgColor': sky100,
    },
    {
      'title': AppLocalizations.of(context)!.statsAverageTitle,
      'value': '${weekAverage}ml',
      'icon': Icons.trending_up_rounded,
      'color': green600,
      'bgColor': green100,
    },
    {
      'title': AppLocalizations.of(context)!.statsWeekTotalTitle,
      'value': '${(weekTotal / 1000).toStringAsFixed(1)}L',
      'icon': Icons.calendar_month_rounded,
      'color': orange600,
      'bgColor': orange100,
    },
  ];

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
        _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Stats Cards ---
              _buildStatsCards(stats)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Weekly Progress Chart ---
        _buildWeeklyChartCard(context, weeklyData)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 20), // space-y-4

              // --- Hourly Distribution (Today) ---
              if (entries.isNotEmpty)
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

  // --- Header Widget ---
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
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
  Widget _buildWeeklyChartCard(BuildContext context, List<Map<String, dynamic>> weeklyData) {
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
              AppLocalizations.of(context)!.statisticsWeekly,
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
                  maxY: dailyGoal * 1.2, // Максимальне значення на осі Y
                  barTouchData: const BarTouchData(enabled: true),
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
                          if (value == dailyGoal.toDouble()) return Text('${dailyGoal}ml', style: const TextStyle(fontSize: 10, color: green600));
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final raw = value.toInt();
                          if (weeklyData.isEmpty) return const SizedBox.shrink();
                          final index = raw.clamp(0, weeklyData.length - 1);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(weeklyData[index]['day'] as String,
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
                      if (value == dailyGoal) {
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
                  barGroups: weeklyData.asMap().entries.map((entry) {
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
  Widget _buildHourlyDistributionCard(BuildContext context, List<WaterIntakeEntry> entries) {
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
              children: entries.map((entry) {
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
                              entry.time,
                              style: const TextStyle(fontSize: 13, color: mutedForeground), // text-xs sm:text-sm text-muted-foreground
                            ),
                          ],
                        ),
                        Text(
                          '${entry.amount}ml',
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