import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';

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
  String? _expandedProjectId;

  late List<Project> _allProjects;
  List<Project> _filteredProjects = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _taskService = context.read<TaskService>();
    _loadProjects();
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

  Future<void> _showAddProjectDialog() async {
    final TextEditingController dialogTextController = TextEditingController();
    IconData selectedIcon = projectIcons.first;
    Color selectedColor = projectColors.first;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo Projeto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: dialogTextController,
                      decoration: const InputDecoration(
                        hintText: "Nome do projeto",
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cor',
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
                  child: const Text('CREATE'),
                  onPressed: () async {
                    if (dialogTextController.text.isNotEmpty) {
                      await _projectService.addProject(
                        dialogTextController.text,
                        selectedIcon.codePoint,
                        selectedColor.value,
                      );
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAddProjectDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.adwaitaBlue,
                    foregroundColor: AppTheme.adwaitaBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
                            ? 'Crie seu primeiro projeto no botão +'
                            : 'No projects found',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        final isExpanded = _expandedProjectId == project.id;

                        final tasks = isExpanded
                            ? _taskService.getTasksForProject(project.id)
                            : <Task>[];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            children: [
                              ListTile(
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
                                title: Text(project.name),
                                trailing: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedProjectId = null;
                                    } else {
                                      _expandedProjectId = project.id;
                                    }
                                  });
                                },
                              ),
                              if (isExpanded)
                                ...tasks
                                    .map(
                                      (task) => ListTile(
                                        title: Text(task.name),
                                        contentPadding: const EdgeInsets.only(
                                          left: 72,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
