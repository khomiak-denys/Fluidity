import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WaterIntakeEntry {
  final String id;
  final int amount;
  final String time;
  final String type;

  WaterIntakeEntry({
    required this.id,
    required this.amount,
    required this.time,
    required this.type,
  });
}

class StatisticsScreen extends StatelessWidget {
  final List<WaterIntakeEntry> entries;
  final int dailyGoal;

  const StatisticsScreen({
    super.key,
    required this.entries,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
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

    final stats = [
      {
        'title': 'Сьогодні випито',
        'value': '${todayIntake}ml',
  'icon': Icons.opacity,
        'color': Colors.lightBlue,
      },
      {
        'title': 'В середньому за день',
        'value': '${weekAverage}ml',
  'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'Загалом за тиждень',
        'value': '${(weekTotal / 1000).toStringAsFixed(1)}L',
  'icon': Icons.calendar_month,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    'Статистика',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Слідкуйте за своїм прогресом',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .moveY(begin: -20, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 20),

            // Cards
            ...stats
                .map(
                  (stat) => Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: (stat['color'] as Color).withOpacity(0.2)),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat['title'] as String,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stat['value'] as String,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: stat['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: (stat['color'] as Color).withOpacity(0.15),
                            child: Icon(stat['icon'] as IconData, color: stat['color'] as Color),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: Duration(milliseconds: stats.indexOf(stat) * 150))
                      .moveX(begin: -20, end: 0),
                )
                .toList(),

            const SizedBox(height: 20),

            // Weekly Chart
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Статистика за тиждень',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < weeklyData.length) {
                                    return Text(weeklyData[index]['day'] as String,
                                        style: const TextStyle(fontSize: 12));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          barGroups: weeklyData.asMap().entries.map((entry) {
                            int index = entry.key;
                            final data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (data['intake'] as int).toDouble(),
                                  color: Colors.blue.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                  width: 18,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).moveY(begin: 20, end: 0),

            const SizedBox(height: 20),

            // Hourly list
            if (entries.isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Розподіл за сьогодні',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...entries.map((e) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade500,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.time,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                '${e.amount}ml',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).moveY(begin: 20, end: 0),
          ],
        ),
      ),
    );
  }
}
