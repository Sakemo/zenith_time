import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/app/ui/custom_title_bar.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/projects/ui/projects_screen.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';
import 'package:zenith_time/features/tracker/logic/timer_service.dart';
import 'package:zenith_time/features/tracker/ui/tracker_screen.dart';

enum AppScreen { tracker, projects }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final TextEditingController _taskNameController = TextEditingController();
  final CustomPopupMenuController _popupController =
      CustomPopupMenuController();

  late final ProjectService _projectService;
  late final TaskService _taskService;

  List<Project> _projects = [];
  Task? _selectedTask;
  Project? _selectedProject;

  AppScreen _currentScreen = AppScreen.tracker;

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
      if (_selectedProject == null && _projects.isNotEmpty) {
        _selectedProject = _projects.first;
      }
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.tracker:
        return TrackerScreen(
          onDataChanged: _loadData,
          selectedTask: _selectedTask,
          onTaskSelected: (task) {
            setState(() {
              _selectedTask = task;
              _taskNameController.text = task.name;
            });
          },
        );
      case AppScreen.projects:
        return ProjectsScreen(onDataChanged: _loadData);
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: AppTheme.adwaitaTextColor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.timer_outlined,
              color: _currentScreen == AppScreen.tracker
                  ? Colors.white
                  : Colors.grey,
              size: 32,
            ),
            onPressed: () => setState(() => _currentScreen = AppScreen.tracker),
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(
              Icons.folder_outlined,
              color: _currentScreen == AppScreen.projects
                  ? Colors.white
                  : Colors.grey,
              size: 32,
            ),
            onPressed: () =>
                setState(() => _currentScreen = AppScreen.projects),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = context.watch<TimerService>();

    return Scaffold(
      backgroundColor: AppTheme.adwaitaHeaderBar,
      body: Column(
        children: [
          const CustomTitleBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildSidebar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.adwaitaBackground,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildActionToolbar(timerService),
                          ),
                          const Divider(height: 1, color: Colors.black12),
                          Expanded(child: _buildCurrentScreen()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // tracker screen moved logic
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

        CustomPopupMenu(
          controller: _popupController,
          menuBuilder: _buildProjectSelectorMenu,
          pressType: PressType.singleClick,
          child: _selectedProject == null
              ? const Icon(Icons.folder_outlined, color: Colors.grey)
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(_selectedProject!.colorValue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconData(
                      _selectedProject!.iconCodePoint,
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Color(_selectedProject!.colorValue),
                  ),
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

        _buildSoftSquareButton(
          icon: timerService.isRunning ? Icons.stop : Icons.play_arrow,
          color: timerService.isRunning
              ? AppTheme.adwaitaTextColor
              : AppTheme.adwaitaBlue,
          onPressed: () async {
            if (timerService.isRunning) {
              await timerService.stopTimer();
              setState(() {
                _selectedTask = null;
                _taskNameController.clear();
                _loadData();
              });
            } else {
              final taskName = _taskNameController.text;
              if (taskName.isEmpty) return;

              Task taskToStart;

              if (_selectedTask != null && _selectedTask!.name == taskName) {
                taskToStart = _selectedTask!;
              } else {
                if (_selectedProject == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create and select a project first'),
                    ),
                  );
                  return;
                }

                taskToStart = await _taskService.addTask(
                  taskName,
                  _selectedProject!.id,
                );
                _loadData();
              }
              setState(() {
                _selectedTask = taskToStart;
              });
              await timerService.startTimer(taskToStart);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSoftSquareButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Icon(icon, color: Colors.white),
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

  Widget _buildProjectSelectorMenu() {
    String searchQuery = '';

    return StatefulBuilder(
      builder: (context, setMenuState) {
        final filteredProjects = _projects
            .where(
              (p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

        return Container(
          width: 280,
          padding: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.adwaitaBackground,
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: [
              BoxShadow(
                color: AppTheme.adwaitaTextColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) => setMenuState(() => searchQuery = value),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search Projects...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.adwaitaHeaderBar.withOpacity(0.1),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return ListTile(
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
                          size: 20,
                        ),
                      ),
                      title: Text(project.name),
                      trailing: _selectedProject?.id == project.id
                          ? const Icon(Icons.check, color: AppTheme.adwaitaBlue)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedProject = project;
                        });
                        _popupController.hideMenu();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
