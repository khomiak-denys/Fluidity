import 'package:flutter/material.dart';
import 'package:fluidity/models/water_entry.dart';

enum StatsPeriod { day, week, month }

class StatsBarItem {
  final String label;
  final int intake;

  const StatsBarItem({
    required this.label,
    required this.intake,
  });
}

class StatsSummary {
  final List<StatsBarItem> bars;
  final List<WaterEntry> filteredEntries;
  final int todayIntake;
  final int periodAverage;
  final int periodTotal;
  final int weekTotal;
  final int monthTotal;

  const StatsSummary({
    required this.bars,
    required this.filteredEntries,
    required this.todayIntake,
    required this.periodAverage,
    required this.periodTotal,
    required this.weekTotal,
    required this.monthTotal,
  });
}

class StatsCardItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const StatsCardItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class StatisticsCalculator {
  static StatsSummary calculate({
    required List<WaterEntry> entries,
    required StatsPeriod period,
    required DateTime now,
    required List<String> weekdayLabels,
  }) {
    DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final startOfWeek = dayStart(now).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    late final List<WaterEntry> filtered;
    late final List<StatsBarItem> bars;

    switch (period) {
      case StatsPeriod.day:
        final start = dayStart(now);
        final end = start.add(const Duration(days: 1));
        filtered = entries
            .where((e) =>
                !e.timestamp.isBefore(start) && e.timestamp.isBefore(end))
            .toList();
        bars = const <StatsBarItem>[];
        break;
      case StatsPeriod.week:
        filtered = entries
            .where((e) =>
                !e.timestamp.isBefore(startOfWeek) &&
                e.timestamp.isBefore(endOfWeek))
            .toList();
        bars = List.generate(7, (i) {
          final day = startOfWeek.add(Duration(days: i));
          final total = filtered
              .where((e) => isSameDay(e.timestamp, day))
              .fold<int>(0, (s, e) => s + e.amountMl);
          return StatsBarItem(label: weekdayLabels[i], intake: total);
        });
        break;
      case StatsPeriod.month:
        filtered = entries
            .where((e) =>
                !e.timestamp.isBefore(startOfMonth) &&
                e.timestamp.isBefore(endOfMonth))
            .toList();
        final daysInMonth = endOfMonth.difference(startOfMonth).inDays;
        bars = List.generate(daysInMonth, (i) {
          final day = startOfMonth.add(Duration(days: i));
          final total = filtered
              .where((e) => isSameDay(e.timestamp, day))
              .fold<int>(0, (s, e) => s + e.amountMl);
          return StatsBarItem(label: '${i + 1}', intake: total);
        });
        break;
    }

    final periodTotal = filtered.fold<int>(0, (sum, e) => sum + e.amountMl);
    final periodLen = period == StatsPeriod.day
        ? 1
        : (period == StatsPeriod.week ? 7 : bars.length);
    final periodAverage = (periodTotal / periodLen).round();
    final todayTotal = entries
        .where((e) => isSameDay(e.timestamp, now))
        .fold<int>(0, (sum, e) => sum + e.amountMl);

    final weekTotal = entries
        .where((e) =>
            !e.timestamp.isBefore(startOfWeek) &&
            e.timestamp.isBefore(endOfWeek))
        .fold<int>(0, (s, e) => s + e.amountMl);
    final monthTotal = entries
        .where((e) =>
            !e.timestamp.isBefore(startOfMonth) &&
            e.timestamp.isBefore(endOfMonth))
        .fold<int>(0, (s, e) => s + e.amountMl);

    return StatsSummary(
      bars: bars,
      filteredEntries: filtered,
      todayIntake: todayTotal,
      periodAverage: periodAverage,
      periodTotal: periodTotal,
      weekTotal: weekTotal,
      monthTotal: monthTotal,
    );
  }
}
