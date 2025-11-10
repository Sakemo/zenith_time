import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_time/core/database/database_service.dart';
import 'package:zenith_time/core/models/task_model.dart';

class TaskService {
  final Box<Task> _tasksBox = Hive.box(tasksBoxName);

  final _uuid = const Uuid();

  Future<Task> addTask(String name, String projectId) async {
    if (projectId.isEmpty) {
      throw Exception('Needs a project');
    }

    final newTask = Task(
      id: _uuid.v4(),
      name: name,
      projectId: projectId,
      createdAt: DateTime.now(),
    );

    await _tasksBox.put(newTask.id, newTask);

    return newTask;
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasksBox.values
        .where((task) => task.projectId == projectId)
        .toList();
  }

  List<Task> getAllTasks() {
    return _tasksBox.values.toList();
  }

  Future<void> updateTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }
}
