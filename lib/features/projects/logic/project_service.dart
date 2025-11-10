import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_time/core/database/database_service.dart';
import 'package:zenith_time/core/models/project_model.dart';

class ProjectService {
  final Box<Project> _projectsBox = Hive.box<Project>(projectsBoxName);

  final _uuid = const Uuid();

  Future<void> addProject(String name) async {
    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );

    await _projectsBox.put(newProject.id, newProject);
  }

  Project? getProject(String id) {
    return _projectsBox.get(id);
  }

  List<Project> getAllProjects() {
    return _projectsBox.values.toList();
  }

  Future<void> updateProject(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    await _projectsBox.delete(id);
  }
}
