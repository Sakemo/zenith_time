import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/tracker/logic/timer_service.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final TextEditingController _taskNameController = TextEditingController();

  late final ProjectService _projectService;
  late final TaskService _taskService;

  List<Project> _projects = [];
  Map<String, List<Task>> _tasksByProject = {};
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
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
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionToolbar(timerService),
              const SizedBox(height: 24),
              Expanded(child: _buildProjectList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return const Center(child: Text('Create your first project'));
    }
    return ListView.builder(
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
              selected: _selectedTask?.id == task.id,
              selectedTileColor: AppTheme.adwaitaHeaderBar,
              onTap: () {
                setState(() {
                  _selectedTask = task;
                  _taskNameController.text = task.name;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  Widget _buildActionToolbar(TimerService timerService) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskNameController,
            decoration: const InputDecoration(
              hintText: 'What are you doing?',
              border: OutlineInputBorder(),
            ),
            enabled: !timerService.isRunning,
          ),
        ),
        const SizedBox(width: 16),

        Text(
          _formatDuration(timerService.elapsedDuration),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 16),

        IconButton(
          icon: Icon(
            timerService.isRunning ? Icons.stop_circle : Icons.play_circle,
            size: 36,
          ),
          onPressed: () async {
            if (timerService.isRunning) {
              timerService.stopTimer();
              _taskNameController.clear();
            } else {
              final taskName = _taskNameController.text;
              if (taskName.isEmpty) return;
              if (_selectedTask != null) {
                if (_selectedTask!.name != taskName) {
                  _selectedTask!.name = taskName;
                  await _taskService.updateTask(_selectedTask!);
                }
                await timerService.startTimer(_selectedTask!);
              } else {
                if (_projects.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create a project first')),
                  );
                  return;
                }

                final projectId = _projects.first.id;
                final newTask = await _taskService.addTask(taskName, projectId);
                _loadData();
                setState(() {
                  _selectedTask = newTask;
                });
              }
            }
          },
          color: timerService.isRunning
              ? AppTheme.adwaitaTextColor
              : AppTheme.adwaitaBlue,
        ),
      ],
    );
  }
}
