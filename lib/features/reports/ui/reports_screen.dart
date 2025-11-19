// lib/features/reports/ui/reports_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
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

  ReportTimeFilter _currentFilter = ReportTimeFilter.week;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _timeEntryService = context.read<TimeEntryService>();
    _projectService = context.read<ProjectService>();
    _updateDateRange();
  }

  // --- LÓGICA DE DATAS CORRIGIDA E SIMPLIFICADA ---
  void _updateDateRange() {
    final now = DateTime.now();
    setState(() {
      switch (_currentFilter) {
        case ReportTimeFilter.week:
          // Volta para a última segunda-feira
          _startDate = DateUtils.dateOnly(
            now.subtract(Duration(days: now.weekday - 1)),
          );
          break;
        case ReportTimeFilter.month:
          _startDate = DateTime(now.year, now.month, 1);
          break;
        case ReportTimeFilter.year:
          _startDate = DateTime(now.year, 1, 1);
          break;
        case ReportTimeFilter.custom:
          // Temporariamente, define como a semana atual
          _startDate = DateUtils.dateOnly(
            now.subtract(Duration(days: now.weekday - 1)),
          );
          break;
      }
    });
  }

  // Calcula o fim do range dinamicamente
  DateTime get _endDate {
    switch (_currentFilter) {
      case ReportTimeFilter.week:
        return _startDate.add(const Duration(days: 7));
      case ReportTimeFilter.month:
        return DateTime(_startDate.year, _startDate.month + 1, 1);
      case ReportTimeFilter.year:
        return DateTime(_startDate.year + 1, 1, 1);
      case ReportTimeFilter.custom:
        return _startDate.add(const Duration(days: 7));
    }
  }

  // Calcula o número de dias no range dinamicamente
  int get _dayCount {
    return _endDate.difference(_startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    // A busca de dados agora usa o getter _endDate
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

    // O cálculo da média agora usa o getter _dayCount
    final double averageHours = totalDuration.inMinutes / 60 / _dayCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatórios',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

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
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
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
              child: BarChart(_buildChartData(aggregatedData, allProjects)),
            ),

            const SizedBox(height: 32),

            Text('Resumo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
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

    // O loop agora usa o getter _dayCount
    for (int i = 0; i < _dayCount; i++) {
      final day = _startDate.add(Duration(days: i));
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
    return '$hours:$minutes'; // Mostra apenas horas e minutos nos totais
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
