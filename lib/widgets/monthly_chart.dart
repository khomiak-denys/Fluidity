import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_entry.dart';

class MonthlyChart extends StatelessWidget {
  final List<WaterEntry> entries;
  final DateTime month; // будь-який день з місяця, для якого показуємо статистику
  final double dayWidth; // ширина на один день (для настройки скролу)
  final EdgeInsetsGeometry padding;

  const MonthlyChart({
    super.key,
    required this.entries,
    required this.month,
    this.dayWidth = 48.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final year = month.year;
    final monthIndex = month.month;
    final daysInMonth = DateTime(year, monthIndex + 1, 0).day;

    // Агрегація: сумарно мл за кожен день місяця
    final sums = List<double>.filled(daysInMonth + 1, 0.0); // індекс від 1..daysInMonth
    for (final e in entries) {
      if (e.timestamp.year == year && e.timestamp.month == monthIndex) {
        final day = e.timestamp.day;
        sums[day] += e.amountMl.toDouble();
      }
    }

    final spots = <FlSpot>[];
    double maxY = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      final val = sums[d];
      spots.add(FlSpot(d.toDouble(), val));
      if (val > maxY) maxY = val;
    }
    if (maxY == 0) maxY = 2000; // дефолтний максимум щоб графік не був плоским

    // Ширина графіку, щоб мати місце для скролу
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = max(screenWidth, daysInMonth * dayWidth);

    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: daysInMonth.toDouble(),
              minY: 0,
              maxY: (maxY * 1.15),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Theme.of(context).colorScheme.primary,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  ),
                ),
              ],
              gridData: FlGridData(
                show: true,
                horizontalInterval: (maxY / 4).clamp(1, maxY),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: (daysInMonth <= 14) ? 1 : (daysInMonth / 14).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      final v = value.toInt();
                      if (v < 1 || v > daysInMonth) return const SizedBox.shrink();
                      // Покazувати підписи кожні N днів (щоб не захаращувати)
                      final step = (daysInMonth <= 14) ? 1 : (daysInMonth / 14).ceil();
                      if (v % step != 0 && v != daysInMonth) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta, // fixed API
                        space: 6,
                        child: Text('$v', style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    interval: (maxY / 4).clamp(1, maxY),
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  // tooltipBgColor removed for API compatibility
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final day = spot.x.toInt();
                      final amount = spot.y.toInt();
                      return LineTooltipItem(
                        'Day $day\n$amount ml',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
            ),
          ),
        ),
      ),
    );
  }
}
