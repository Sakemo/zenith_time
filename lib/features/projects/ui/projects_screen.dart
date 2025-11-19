import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

const List<IconData> projectIcons = [
  Icons.work,
  Icons.school,
  Icons.book,
  Icons.code,
  Icons.home,
  Icons.star,
  Icons.favorite,
  Icons.lightbulb,
];
const List<Color> projectColors = [
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.amber,
];

class ProjectsScreen extends StatefulWidget {
  final VoidCallback onDataChanged;
  const ProjectsScreen({super.key, required this.onDataChanged});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final TaskService _taskService;
  late final ProjectService _projectService;
  late final TimeEntryService _timeEntryService;
  String? _expandedProjectId;
  String? _contextMenuProjectId;

  late List<Project> _allProjects;
  List<Project> _filteredProjects = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
    _timeEntryService = context.read<TimeEntryService>();
    _loadProjects();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _loadProjects() {
    setState(() {
      _allProjects = _projectService.getAllProjects();
      _filterProjects();
    });
  }

  void _filterProjects() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredProjects = _allProjects;
      } else {
        _filteredProjects = _allProjects
            .where(
              (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _showProjectDialog({Project? project}) async {
    final isEditing = project != null;
    final TextEditingController dialogTextController = TextEditingController(
      text: project?.name ?? '',
    );
    IconData selectedIcon = projectIcons.first;
    Color selectedColor = projectColors.first;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit' : 'New'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: dialogTextController,
                      decoration: const InputDecoration(hintText: "Name"),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: projectColors.map((color) {
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? AppTheme.adwaitaBlue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ícone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: projectIcons.map((icon) {
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? AppTheme.adwaitaBlue.withOpacity(0.2)
                                  : AppTheme.adwaitaBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: selectedIcon == icon
                                  ? AppTheme.adwaitaTextColor
                                  : AppTheme.adwaitaBackground,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(isEditing ? 'SAVE' : 'CREATE'),
                  onPressed: () async {
                    if (dialogTextController.text.isNotEmpty) {
                      if (isEditing) {
                        project.name = dialogTextController.text;
                        project.iconCodePoint = selectedIcon.codePoint;
                        project.colorValue = selectedColor.value;
                        await _projectService.updateProject(project);
                      } else {
                        await _projectService.addProject(
                          dialogTextController.text,
                          selectedIcon.codePoint,
                          selectedColor.value,
                        );
                      }
                      _loadProjects();
                      widget.onDataChanged();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _contextMenuProjectId = null),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterProjects();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
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
                  ElevatedButton.icon(
                    onPressed: _showProjectDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.adwaitaBlue,
                      foregroundColor: AppTheme.adwaitaBackground,
                      minimumSize: Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredProjects.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Create your first project +'
                              : 'No projects found',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = _filteredProjects[index];
                          final isExpanded = _expandedProjectId == project.id;
                          final isContextMenuOpen =
                              _contextMenuProjectId == project.id;

                          final tasks = isExpanded
                              ? _taskService.getTasksForProject(project.id)
                              : <Task>[];

                          final projectDuration = _timeEntryService
                              .getDurationForProject(project.id);

                          return Card(
                            elevation: 0,
                            color: AppTheme.adwaitaBackground,
                            margin: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(project.colorValue),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      IconData(
                                        project.iconCodePoint,
                                        fontFamily: 'MaterialIcons',
                                      ),
                                      color: AppTheme.adwaitaBackground,
                                    ),
                                  ),
                                  title: Text(project.name),
                                  trailing: isContextMenuOpen
                                      ? _buildContextMenuActions(project)
                                      : Text(
                                          _formatDuration(projectDuration),
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            color: Colors.grey,
                                          ),
                                        ),
                                  onTap: () {
                                    if (_contextMenuProjectId != null) {
                                      setState(
                                        () => _contextMenuProjectId = null,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedProjectId = null;
                                      } else {
                                        _expandedProjectId = project.id;
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    setState(
                                      () => _contextMenuProjectId = project.id,
                                    );
                                  },
                                ),
                                if (isExpanded)
                                  ...tasks.map((task) {
                                    final taskDuration = _timeEntryService
                                        .getDurationForTask(task.id);
                                    return ListTile(
                                      title: Text(task.name),
                                      trailing: Text(
                                        _formatDuration(taskDuration),
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          color: Colors.grey,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        left: 24,
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextMenuActions(Project project) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () {
            setState(() => _contextMenuProjectId = null);
            _showProjectDialog(project: project);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            setState(() => _contextMenuProjectId = null);
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
              await _projectService.deleteProject(project.id);
              _loadProjects();
              widget.onDataChanged();
            }
          },
        ),
      ],
    );
  }
}
