import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/ui/theme_tokens.dart';

import '../bloc/water/water_bloc.dart';
import '../bloc/water/water_state.dart';
import '../models/water_entry.dart';
import '../widgets/monthly_bar_chart_scrollable.dart';
import 'view_models/statistics_view_models.dart';

const Color sky50 = AppColors.sky50;
const Color sky100 = AppColors.sky100;
const Color sky200 = AppColors.sky200;
const Color sky600 = AppColors.sky600;
const Color sky700 = AppColors.sky700;
const Color green100 = Color(0xFFDCFCE7);
const Color green600 = Color(0xFF059669);
const Color orange100 = Color(0xFFFFEDD5);
const Color orange600 = Color(0XFFEA580C);
const Color mutedForeground = AppColors.mutedForeground;
const Color borderGray = AppColors.gray200;

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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WaterBloc>().state;
    final List<WaterEntry> entries = state is WaterLoaded
        ? state.data
        : state is WaterLoading
            ? state.data
            : state is WaterError
                ? state.data
                : const <WaterEntry>[];

    final summary = StatisticsCalculator.calculate(
      entries: entries,
      period: _period,
      now: DateTime.now(),
      weekdayLabels: [
        AppLocalizations.of(context)!.weekdayMonShort,
        AppLocalizations.of(context)!.weekdayTueShort,
        AppLocalizations.of(context)!.weekdayWedShort,
        AppLocalizations.of(context)!.weekdayThuShort,
        AppLocalizations.of(context)!.weekdayFriShort,
        AppLocalizations.of(context)!.weekdaySatShort,
        AppLocalizations.of(context)!.weekdaySunShort,
      ],
    );

    final List<StatsCardItem> stats = [];

    if (_period == StatsPeriod.day) {
      stats.add(StatsCardItem(
        title: AppLocalizations.of(context)!.statsTodayTitle,
        value: '${summary.todayIntake}ml',
        icon: Icons.opacity_rounded,
        color: sky600,
        bgColor: sky100,
      ));
    } else if (_period == StatsPeriod.week) {
      stats.add(StatsCardItem(
        title: AppLocalizations.of(context)!.statsAverageTitle,
        value: '${summary.periodAverage}ml',
        icon: Icons.trending_up_rounded,
        color: green600,
        bgColor: green100,
      ));
      stats.add(StatsCardItem(
        title: AppLocalizations.of(context)!.statsWeekTotalTitle,
        value: '${(summary.periodTotal / 1000).toStringAsFixed(1)}L',
        icon: Icons.calendar_month_rounded,
        color: orange600,
        bgColor: orange100,
      ));
    } else {
      stats.add(StatsCardItem(
        title: AppLocalizations.of(context)!.statsAverageTitle,
        value: '${summary.periodAverage}ml',
        icon: Icons.trending_up_rounded,
        color: green600,
        bgColor: green100,
      ));
      stats.add(StatsCardItem(
        title: AppLocalizations.of(context)!.statsMonthTotalTitle,
        value: '${(summary.periodTotal / 1000).toStringAsFixed(1)}L',
        icon: Icons.calendar_month_rounded,
        color: orange600,
        bgColor: orange100,
      ));
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, headerText)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
              const SizedBox(height: 20),
              _buildPeriodSelector(),
              const SizedBox(height: 12),
              _buildStatsCards(stats)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 20),
              if (_period != StatsPeriod.day)
                _buildPeriodChartCard(
                        context, summary.bars, summary.filteredEntries)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
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
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: selected ? sky700 : mutedForeground),
          ),
        ),
      );
    }

    return Row(
      children: [
        buildButton(AppLocalizations.of(context)!.periodDay, StatsPeriod.day),
        const SizedBox(width: 8),
        buildButton(AppLocalizations.of(context)!.periodWeek, StatsPeriod.week),
        const SizedBox(width: 8),
        buildButton(
            AppLocalizations.of(context)!.periodMonth, StatsPeriod.month),
      ],
    );
  }

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

  Widget _buildStatsCards(List<StatsCardItem> stats) {
    return Column(
      children: stats.map((stat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            color: sky50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: sky200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.title,
                        style: const TextStyle(
                            color: mutedForeground, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: sky700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stat.bgColor,
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 24),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodChartCard(
    BuildContext context,
    List<StatsBarItem> data,
    List<WaterEntry> filteredEntries,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _period == StatsPeriod.week
                  ? AppLocalizations.of(context)!.statisticsWeekly
                  : AppLocalizations.of(context)!.statisticsMonthly,
              style: const TextStyle(
                color: sky700,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (_period == StatsPeriod.month)
            MonthlyBarChartScrollable(
              entries: filteredEntries,
              month: DateTime.now(),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: widget.dailyGoal * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final value = rod.toY.toInt();
                          return BarTooltipItem(
                            '${value}ml',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const Text(
                                '0',
                                style: TextStyle(
                                    fontSize: 10, color: mutedForeground),
                              );
                            }
                            if (value == widget.dailyGoal.toDouble()) {
                              return Text(
                                '${widget.dailyGoal}ml',
                                style: const TextStyle(
                                    fontSize: 10, color: green600),
                              );
                            }
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
                              child: Text(
                                data[index].label,
                                style: const TextStyle(
                                    fontSize: 10, color: mutedForeground),
                              ),
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
                          return FlLine(
                            color: green600.withAlpha((0.7 * 255).round()),
                            strokeWidth: 1.5,
                          );
                        }
                        return FlLine(
                          color: borderGray.withAlpha((0.5 * 255).round()),
                          strokeWidth: 0.5,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: item.intake.toDouble(),
                            gradient: LinearGradient(
                              colors: [
                                sky600.withAlpha((0.8 * 255).round()),
                                sky600.withAlpha((0.6 * 255).round()),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            width: 16,
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

  Widget _buildHourlyDistributionCard(
      BuildContext context, List<WaterEntry> entries) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppLocalizations.of(context)!.hourlyDistribution,
              style: const TextStyle(
                color: sky700,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: entries.where((e) {
                final n = DateTime.now();
                return e.timestamp.year == n.year &&
                    e.timestamp.month == n.month &&
                    e.timestamp.day == n.day;
              }).map((entry) {
                String fmt(DateTime dt) {
                  final hh = dt.hour.toString().padLeft(2, '0');
                  final mm = dt.minute.toString().padLeft(2, '0');
                  return '$hh:$mm';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
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
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fmt(entry.timestamp),
                              style: const TextStyle(
                                  fontSize: 13, color: mutedForeground),
                            ),
                          ],
                        ),
                        Text(
                          '${entry.amountMl}ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: sky700,
                            fontSize: 15,
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
