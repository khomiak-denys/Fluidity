import 'package:fluidity/models/water_entry.dart';

class HomeSummary {
  final List<WaterEntry> todayEntries;
  final int totalIntake;
  final bool isGoalAchieved;

  const HomeSummary({
    required this.todayEntries,
    required this.totalIntake,
    required this.isGoalAchieved,
  });
}

class HomeSelector {
  static HomeSummary buildSummary({
    required List<WaterEntry> entries,
    required int dailyGoal,
    required DateTime now,
  }) {
    final todayEntries =
        entries.where((e) => _isSameDay(e.timestamp, now)).toList();
    final totalIntake = todayEntries.fold<int>(0, (sum, e) => sum + e.amountMl);
    final isGoalAchieved = totalIntake >= dailyGoal;
    return HomeSummary(
      todayEntries: todayEntries,
      totalIntake: totalIntake,
      isGoalAchieved: isGoalAchieved,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
