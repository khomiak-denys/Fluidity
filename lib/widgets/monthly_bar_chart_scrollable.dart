import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/water_entry.dart'; // ВИПРАВЛЕНО: шлях до моделі

class MonthlyBarChartScrollable extends StatelessWidget {
  final List<WaterEntry> entries; // ВИПРАВЛЕНО: тип моделі
  final DateTime month;
  final double dayColumnWidth; // Ширина одного стовпця, наприклад 32.0

  const MonthlyBarChartScrollable({
    super.key,
    required this.entries,
    required this.month,
    this.dayColumnWidth = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final Map<int, double> dailyTotals = {};
    double maxY = 0;

    // Агрегуємо дані по днях
    for (final entry in entries) {
      if (entry.timestamp.month == month.month && entry.timestamp.year == month.year) {
        final day = entry.timestamp.day;
        dailyTotals.update(day, (value) => value + entry.amountMl, ifAbsent: () => entry.amountMl.toDouble());
      }
    }

    // Знаходимо максимальне значення для осі Y
    if (dailyTotals.isNotEmpty) {
      maxY = dailyTotals.values.reduce(max);
    }
    if (maxY < 2000) maxY = 2000; // Мінімальна висота осі Y

    // Створюємо дані для стовпців
    final barGroups = List.generate(daysInMonth, (index) {
      final day = index + 1;
      final total = dailyTotals[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: total,
            color: Theme.of(context).colorScheme.primary,
            width: dayColumnWidth * 0.6, // Ширина самого стовпця
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    // Загальна ширина віджета, щоб забезпечити скрол
    final chartWidth = daysInMonth * dayColumnWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        height: 250, // Висота контейнера для графіка
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.1, // Залишаємо трохи місця зверху
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1, // Показуємо кожен день
                    getTitlesWidget: (value, meta) {
                      // ВИПРАВЛЕНО: axisSide видалено
                      return SideTitleWidget(
                        meta: meta, // fixed API: pass meta
                        space: 4,
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: (value == 0 || value >= meta.max)
                            ? const SizedBox.shrink()
                            : Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.left,
                              ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor removed; not present in 1.1.1
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} ml',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
