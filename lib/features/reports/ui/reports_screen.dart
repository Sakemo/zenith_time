import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final TimeEntryService _timeEntryService;
  late final ProjectService _projectService;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timeEntryService = context.read<TimeEntryService>();
    _projectService = context.read<ProjectService>();
  }

  @override
  Widget build(BuildContext context) {
    final aggregatedData = _timeEntryService.getAggregatedData(
      start: _startDate,
      end: _endDate,
    );
    final allProjects = _projectService.getAllProjects();

    Duration totalDuration = Duration.zero;
    aggregatedData.values.forEach((dailyMap) {
      dailyMap.values.forEach((duration) {
        totalDuration += duration;
      });
    });

    final double averageHours =
        totalDuration.inMinutes /
        60 /
        (_endDate.difference(_startDate).inDays + 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: BarChart(_buildChartData(aggregatedData, allProjects)),
            ),

            const SizedBox(height: 32),
            Text('Resume', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Total Time',
                  _formatDuration(totalDuration),
                  Icons.timer_outlined,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active Projects',
                  allProjects.length.toString(),
                  Icons.folder_outlined,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Daily Average',
                  '${averageHours.toStringAsFixed(1)}h',
                  Icons.show_chart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppTheme.adwaitaTextColor),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  BarChartData _buildChartData(
    Map<DateTime, Map<String, Duration>> data,
    List<Project> projects,
  ) {
    final List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i <= _endDate.difference(_startDate).inDays; i++) {
      final day = DateUtils.dateOnly(_startDate.add(Duration(days: i)));
      final dailyData = data[day];

      final List<BarChartRodStackItem> rodStackItems = [];
      double dailyTotalMinutes = 0;

      if (dailyData != null) {
        dailyData.forEach((projectId, duration) {
          final project = projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => projects.first,
          );
          final minutes = duration.inMinutes.toDouble();
          rodStackItems.add(
            BarChartRodStackItem(
              dailyTotalMinutes,
              dailyTotalMinutes + minutes,
              Color(project.colorValue),
            ),
          );
          dailyTotalMinutes += minutes;
        });
      }

      if (dailyTotalMinutes > maxY) {
        maxY = dailyTotalMinutes;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotalMinutes,
              rodStackItems: rodStackItems,
              width: 16,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      barGroups: barGroups,

      gridData: const FlGridData(show: false),

      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          left: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),

      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final hours = rod.toY / 60;
            return BarTooltipItem(
              '${hours.toStringAsFixed(1)}h',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value > maxY) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '${(value / 60).round()}h',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          ),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final day = _startDate.add(Duration(days: value.toInt()));

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${day.day}/${day.month}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          ),
        ),

        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }
}
