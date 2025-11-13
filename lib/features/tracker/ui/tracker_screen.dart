import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';

enum TimeFilter { today, week, month, year, all }

class TrackerScreen extends StatefulWidget {
  final VoidCallback onDataChanged;
  final Task? selectedTask;
  final Function(Task) onTaskSelected;

  const TrackerScreen({
    super.key,
    required this.onDataChanged,
    required this.selectedTask,
    required this.onTaskSelected,
  });

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  late final ProjectService _projectService;
  late final TaskService _taskService;
  List<Project> _projects = [];
  Map<String, List<Task>> _tasksByProject = {};

  String _taskSearchQuery = '';
  TimeFilter _currentTimeFilter = TimeFilter.week;

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _projects = _projectService.getAllProjects();
      final allTasks = _taskService.getAllTasks();
      _tasksByProject = {};
      for (final project in _projects) {
        _tasksByProject[project.id] = allTasks
            .where((task) => task.projectId == project.id)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Task>> displayedTasks = _filterTasks();

    if (_projects.isEmpty) {
      return const Center(child: Text('Crie seu primeiro projeto'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _taskSearchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<TimeFilter>(
                onSelected: (filter) =>
                    setState(() => _currentTimeFilter = filter),
                itemBuilder: (context) => TimeFilter.values.map((filter) {
                  return PopupMenuItem(
                    value: filter,

                    child: Text(filter.name.capitalize()),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Text(_currentTimeFilter.name.capitalize()),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _projects.isEmpty
              ? const Center(child: Text('Create the first project'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final tasks = _tasksByProject[project.id] ?? [];

                    return ExpansionTile(
                      title: Text(
                        project.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: tasks.map((task) {
                        return ListTile(
                          title: Text(task.name),
                          selected: widget.selectedTask?.id == task.id,
                          selectedTileColor: AppTheme.adwaitaHeaderBar
                              .withOpacity(0.1),
                          onTap: () => widget.onTaskSelected(task),
                        );
                      }).toList(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Map<String, List<Task>> _filterTasks() {
    final Map<String, List<Task>> filteredMap = {};

    if (_taskSearchQuery.isEmpty) {
      return _tasksByProject;
    }

    for (var entry in _tasksByProject.entries) {
      final projectId = entry.key;
      final tasks = entry.value;

      final matchingTasks = tasks.where((task) {
        final project = _projects.firstWhere((p) => p.id == task.projectId);
        return task.name.toLowerCase().contains(
              _taskSearchQuery.toLowerCase(),
            ) ||
            project.name.toLowerCase().contains(_taskSearchQuery.toLowerCase());
      }).toList();

      if (matchingTasks.isNotEmpty) {
        filteredMap[projectId] = matchingTasks;
      }
    }
    return filteredMap;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
