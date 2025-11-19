import 'package:zenith_time/core/models/time_entry_model.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

enum ReportTimeFilter { week, month, year, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final TimeEntryService _timeEntryService;
  late final ProjectService _projectService;
  late final TaskService _taskService;

  ReportTimeFilter _currentFilter = ReportTimeFilter.week;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _timeEntryService = context.read<TimeEntryService>();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
    _updateDateRange();
  }

  void _updateDateRange() {
    final now = DateTime.now();
    setState(() {
      switch (_currentFilter) {
        case ReportTimeFilter.week:
          _startDate = DateUtils.dateOnly(
            now.subtract(Duration(days: now.weekday % 7)),
          );
          _endDate = _startDate.add(const Duration(days: 7));
          break;
        case ReportTimeFilter.month:
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 1);
          break;
        case ReportTimeFilter.year:
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year + 1, 1, 1);
          break;
        case ReportTimeFilter.custom:
          _startDate = DateUtils.dateOnly(
            now.subtract(const Duration(days: 6)),
          );
          _endDate = now.add(const Duration(days: 1));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entriesInRange = _timeEntryService.getEntriesInRange(
      start: _startDate,
      end: _endDate,
    );
    final allProjects = _projectService.getAllProjects();

    final totalDuration = entriesInRange.isEmpty
        ? Duration.zero
        : entriesInRange
              .map((e) => e.endTime!.difference(e.startTime))
              .reduce((a, b) => a + b);

    final dayCount = _endDate.difference(_startDate).inDays;
    final double averageHours = dayCount > 0
        ? totalDuration.inMinutes / 60 / dayCount
        : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: ReportTimeFilter.values.map((filter) {
                if (filter == ReportTimeFilter.custom)
                  return const SizedBox.shrink();
                final isSelected = _currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentFilter = filter;
                        _updateDateRange();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      elevation: 0,
                      backgroundColor: isSelected
                          ? AppTheme.adwaitaBlue
                          : AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                      foregroundColor: isSelected
                          ? Colors.white
                          : AppTheme.adwaitaTextColor,
                    ),
                    child: Text(filter.name.capitalize()),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 200,
              child: _buildChart(entriesInRange, allProjects),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                _buildStatCard(
                  'Tempo Total',
                  _formatDuration(totalDuration),
                  Icons.timer_outlined,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Projetos Ativos',
                  allProjects.length.toString(),
                  Icons.folder_outlined,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Média Diária',
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

  Widget _buildChart(List<TimeEntry> entries, List<Project> projects) {
    switch (_currentFilter) {
      case ReportTimeFilter.week:
        return BarChart(_buildWeekChartData(entries, projects));
      case ReportTimeFilter.month:
        return BarChart(_buildMonthChartData(entries, projects));
      case ReportTimeFilter.year:
        return BarChart(_buildYearChartData(entries, projects));
      case ReportTimeFilter.custom:
        return const Center(child: Text("Filtro customizado em breve."));
    }
  }

  BarChartData _buildWeekChartData(
    List<TimeEntry> entries,
    List<Project> projects,
  ) {
    final dailyTotals = List.generate(7, (_) => <String, Duration>{});
    const weekDayLabels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

    for (final entry in entries) {
      final dayIndex = entry.startTime.weekday % 7;
      final task = _taskService.getTask(entry.taskId);
      if (task == null) continue;

      dailyTotals[dayIndex].update(
        task.projectId,
        (value) => value + entry.endTime!.difference(entry.startTime),
        ifAbsent: () => entry.endTime!.difference(entry.startTime),
      );
    }

    return _buildBarChartData(
      groupTotals: dailyTotals,
      projects: projects,
      bottomTitleBuilder: (value, meta) => weekDayLabels[value.toInt()],
    );
  }

  BarChartData _buildMonthChartData(
    List<TimeEntry> entries,
    List<Project> projects,
  ) {
    final weeklyTotals = List.generate(4, (_) => <String, Duration>{});

    for (final entry in entries) {
      final weekIndex = min((entry.startTime.day - 1) ~/ 7, 3);
      final task = _taskService.getTask(entry.taskId);
      if (task == null) continue;

      weeklyTotals[weekIndex].update(
        task.projectId,
        (value) => value + entry.endTime!.difference(entry.startTime),
        ifAbsent: () => entry.endTime!.difference(entry.startTime),
      );
    }

    return _buildBarChartData(
      groupTotals: weeklyTotals,
      projects: projects,
      bottomTitleBuilder: (value, meta) => 'Sem ${value.toInt() + 1}',
    );
  }

  BarChartData _buildYearChartData(
    List<TimeEntry> entries,
    List<Project> projects,
  ) {
    final monthlyTotals = List.generate(12, (_) => <String, Duration>{});
    const monthLabels = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    for (final entry in entries) {
      final monthIndex = entry.startTime.month - 1;
      final task = _taskService.getTask(entry.taskId);
      if (task == null) continue;

      monthlyTotals[monthIndex].update(
        task.projectId,
        (value) => value + entry.endTime!.difference(entry.startTime),
        ifAbsent: () => entry.endTime!.difference(entry.startTime),
      );
    }

    return _buildBarChartData(
      groupTotals: monthlyTotals,
      projects: projects,
      bottomTitleBuilder: (value, meta) => monthLabels[value.toInt()],
    );
  }

  BarChartData _buildBarChartData({
    required List<Map<String, Duration>> groupTotals,
    required List<Project> projects,
    required String Function(double, TitleMeta) bottomTitleBuilder,
  }) {
    final List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < groupTotals.length; i++) {
      final groupData = groupTotals[i];
      final List<BarChartRodStackItem> rodStackItems = [];
      double groupTotalMinutes = 0;

      groupData.forEach((projectId, duration) {
        final project = projects.firstWhere(
          (p) => p.id == projectId,
          orElse: () => projects.first,
        );
        final minutes = duration.inMinutes.toDouble();
        rodStackItems.add(
          BarChartRodStackItem(
            groupTotalMinutes,
            groupTotalMinutes + minutes,
            Color(project.colorValue),
          ),
        );
        groupTotalMinutes += minutes;
      });

      if (groupTotalMinutes > maxY) {
        maxY = groupTotalMinutes;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: groupTotalMinutes,
              rodStackItems: rodStackItems,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
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
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                bottomTitleBuilder(value, meta),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: AppTheme.adwaitaHeaderBar.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: AppTheme.adwaitaTextColor),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
