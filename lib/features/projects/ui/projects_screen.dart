// lib/features/projects/ui/projects_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late List<Project> _projects;
  late final ProjectService _projectService;
  final TextEditingController _dialogTextController = TextEditingController();

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
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Projeto'),
          content: TextField(
            controller: _dialogTextController,
            decoration: const InputDecoration(hintText: "Nome do projeto"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
                _dialogTextController.clear();
              },
            ),
            TextButton(
              child: const Text('CRIAR'),
              onPressed: () async {
                if (_dialogTextController.text.isNotEmpty) {
                  await _projectService.addProject(_dialogTextController.text);
                  _loadProjects(); // Recarrega a lista
                  Navigator.pop(context);
                  _dialogTextController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _dialogTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.builder(
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return ListTile(title: Text(project.name), onTap: () {});
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
