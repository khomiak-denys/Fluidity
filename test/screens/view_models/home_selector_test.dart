import 'package:fluidity/models/water_entry.dart';
import 'package:fluidity/screens/view_models/home_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WaterEntry entry(String id, int amount, DateTime ts) {
    return WaterEntry(
      id: id,
      amountMl: amount,
      timestamp: ts,
      drinkType: 'glass',
      comment: '',
    );
  }

  group('HomeSelector', () {
    test('filters same-day entries and sums intake', () {
      final now = DateTime(2026, 5, 12, 10, 0);
      final entries = [
        entry('1', 200, DateTime(2026, 5, 12, 8, 0)),
        entry('2', 300, DateTime(2026, 5, 12, 9, 0)),
        entry('3', 500, DateTime(2026, 5, 11, 9, 0)),
      ];

      final summary = HomeSelector.buildSummary(
        entries: entries,
        dailyGoal: 1000,
        now: now,
      );

      expect(summary.todayEntries.length, 2);
      expect(summary.totalIntake, 500);
      expect(summary.isGoalAchieved, false);
    });

    test('marks goal as achieved when intake reaches goal', () {
      final now = DateTime(2026, 5, 12, 10, 0);
      final summary = HomeSelector.buildSummary(
        entries: [
          entry('1', 400, DateTime(2026, 5, 12, 8, 0)),
          entry('2', 600, DateTime(2026, 5, 12, 9, 0)),
        ],
        dailyGoal: 1000,
        now: now,
      );

      expect(summary.totalIntake, 1000);
      expect(summary.isGoalAchieved, true);
    });
  });
}
