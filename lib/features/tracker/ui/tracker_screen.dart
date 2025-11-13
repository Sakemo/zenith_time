import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';

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
    if (_projects.isEmpty) {
      return const Center(child: Text('Crie seu primeiro projeto'));
    }
    return ListView.builder(
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
              selectedTileColor: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
              onTap: () => widget.onTaskSelected(task),
            );
          }).toList(),
        );
      },
    );
  }
}
