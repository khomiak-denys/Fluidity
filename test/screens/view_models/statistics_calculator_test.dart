import 'package:fluidity/models/water_entry.dart';
import 'package:fluidity/screens/view_models/statistics_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  WaterEntry entry(String id, int amount, DateTime ts) {
    return WaterEntry(
      id: id,
      amountMl: amount,
      timestamp: ts,
      drinkType: 'glass',
      comment: '',
    );
  }

  group('StatisticsCalculator', () {
    test('calculates day summary', () {
      final now = DateTime(2026, 5, 12, 10, 0);
      final entries = [
        entry('1', 200, DateTime(2026, 5, 12, 9, 0)),
        entry('2', 300, DateTime(2026, 5, 12, 14, 0)),
        entry('3', 500, DateTime(2026, 5, 11, 18, 0)),
      ];

      final summary = StatisticsCalculator.calculate(
        entries: entries,
        period: StatsPeriod.day,
        now: now,
        weekdayLabels: weekdayLabels,
      );

      expect(summary.bars, isEmpty);
      expect(summary.filteredEntries.length, 2);
      expect(summary.todayIntake, 500);
      expect(summary.periodTotal, 500);
      expect(summary.periodAverage, 500);
    });

    test('calculates week summary with bars', () {
      final now = DateTime(2026, 5, 13, 10, 0); // Wednesday
      final entries = [
        entry('1', 200, DateTime(2026, 5, 11, 9, 0)), // Mon
        entry('2', 300, DateTime(2026, 5, 12, 9, 0)), // Tue
        entry('3', 400, DateTime(2026, 5, 13, 9, 0)), // Wed
        entry('4', 1000, DateTime(2026, 5, 9, 9, 0)), // prev week
      ];

      final summary = StatisticsCalculator.calculate(
        entries: entries,
        period: StatsPeriod.week,
        now: now,
        weekdayLabels: weekdayLabels,
      );

      expect(summary.bars.length, 7);
      expect(summary.bars[0].label, 'Mon');
      expect(summary.bars[0].intake, 200);
      expect(summary.bars[1].intake, 300);
      expect(summary.bars[2].intake, 400);
      expect(summary.periodTotal, 900);
      expect(summary.periodAverage, 129); // 900 / 7 rounded
      expect(summary.weekTotal, 900);
    });

    test('calculates month summary and handles empty input', () {
      final now = DateTime(2026, 2, 10, 12, 0);
      final summary = StatisticsCalculator.calculate(
        entries: const [],
        period: StatsPeriod.month,
        now: now,
        weekdayLabels: weekdayLabels,
      );

      expect(summary.filteredEntries, isEmpty);
      expect(summary.bars.length, 28);
      expect(summary.periodTotal, 0);
      expect(summary.periodAverage, 0);
      expect(summary.todayIntake, 0);
      expect(summary.monthTotal, 0);
    });

    test('includes boundary timestamps correctly', () {
      final now = DateTime(2026, 5, 12, 10, 0);
      final entries = [
        entry('1', 100, DateTime(2026, 5, 12, 0, 0, 0)), // day start included
        entry('2', 200, DateTime(2026, 5, 12, 23, 59, 59)), // day end included
        entry('3', 300, DateTime(2026, 5, 13, 0, 0, 0)), // next day excluded
      ];

      final summary = StatisticsCalculator.calculate(
        entries: entries,
        period: StatsPeriod.day,
        now: now,
        weekdayLabels: weekdayLabels,
      );

      expect(summary.filteredEntries.length, 2);
      expect(summary.periodTotal, 300);
    });
  });
}
