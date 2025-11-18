import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';
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
  late final TimeEntryService _timeEntryService;

  List<Task> _allTasks = [];
  List<Project> _projects = [];

  String _taskSearchQuery = '';
  TimeFilter _currentTimeFilter = TimeFilter.week;

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
    _timeEntryService = context.read<TimeEntryService>();
    _loadData();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void didUpdateWidget(covariant TrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _projects = _projectService.getAllProjects();
      _allTasks = _taskService.getAllTasks();
      _allTasks.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedTasks = _filterTasks();

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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        bottomLeft: Radius.circular(6.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                  ),
                ),
              ),
              const SizedBox(width: 0),
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
                    color: AppTheme.adwaitaHeaderBar.withOpacity(0.16),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6.0),
                      bottomRight: Radius.circular(6.0),
                    ),
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
          child: displayedTasks.isEmpty
              ? const Center(child: Text('No tasks found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displayedTasks.length,
                  itemBuilder: (context, index) {
                    final task = displayedTasks[index];
                    final project = _projects.firstWhere(
                      (p) => p.id == task.projectId,
                      orElse: () => _projects.isNotEmpty
                          ? _projects.first
                          : Project(
                              id: '',
                              name: 'Default',
                              createdAt: DateTime.now(),
                              iconCodePoint: Icons.folder.codePoint,
                              colorValue: Colors.grey.value,
                            ),
                    );

                    final taskDuration = _timeEntryService.getDurationForTask(
                      task.id,
                    );

                    return InkWell(
                      onLongPress: () => _showTaskContextMenu(context, task),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(project.colorValue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            IconData(
                              project.iconCodePoint,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: AppTheme.adwaitaBackground,
                          ),
                        ),
                        title: Text(task.name),
                        subtitle: Text(project.name),
                        trailing: Text(
                          _formatDuration(taskDuration),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey,
                          ),
                        ),
                        selected: widget.selectedTask?.id == task.id,
                        selectedTileColor: AppTheme.adwaitaHeaderBar
                            .withOpacity(0.1),
                        onTap: () => widget.onTaskSelected(task),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showTaskContextMenu(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Nome'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para editar a tarefa
                // Um dialog simples para editar o nome é suficiente
                // (similar ao _showProjectDialog, mas mais simples)
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Deletar',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('Are you sure?'),
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_rounded),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (confirm ?? false) {
                  await _taskService.deleteTask(task.id);
                  _loadData(); // Recarrega os dados na TrackerScreen
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<Task> _filterTasks() {
    if (_taskSearchQuery.isEmpty) {
      return _allTasks;
    }

    return _allTasks.where((task) {
      final project = _projects.firstWhere((p) => p.id == task.projectId);
      return task.name.toLowerCase().contains(_taskSearchQuery.toLowerCase()) ||
          project.name.toLowerCase().contains(_taskSearchQuery.toLowerCase());
    }).toList();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
