// lib/features/projects/ui/projects_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';

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
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late List<Project> _projects;
  late final ProjectService _projectService;

  @override
  void initState() {
    super.initState();
    _projectService = context.read<ProjectService>();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projects = _projectService.getAllProjects();
    });
  }

  Future<void> _showAddProjectDialog() async {
    final TextEditingController dialogTextController = TextEditingController();
    IconData selectedIcon = projectIcons.first;
    Color selectedColor = projectColors.first;

    return showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder para gerenciar o estado *dentro* do dialog
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
                    // Seletor de Cores
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
                    // Seletor de Ícones
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
                  child: const Text('CANCELAR'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('CRIAR'),
                  onPressed: () async {
                    if (dialogTextController.text.isNotEmpty) {
                      await _projectService.addProject(
                        dialogTextController.text,
                        selectedIcon.codePoint, // Salva o código do ícone
                        selectedColor.value, // Salva o valor da cor
                      );
                      _loadProjects();
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
            Text('Projetos', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Expanded(
              child: _projects.isEmpty
                  ? const Center(
                      child: Text('Crie seu primeiro projeto no botão +'),
                    )
                  : ListView.builder(
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
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
                            ),
                          ),
                          title: Text(project.name),
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
