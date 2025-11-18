import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_time/core/database/database_service.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

class TaskService {
  final Box<Task> _tasksBox = Hive.box(tasksBoxName);
  final TimeEntryService _timeEntryService = TimeEntryService();
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
      lastUsed: DateTime.now(),
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
    final entriesToDelete = _timeEntryService.getEntriesForTask(
      id,
    ); // Precisamos criar este método
    for (final entry in entriesToDelete) {
      await _timeEntryService.deleteEntry(entry.id);
    }
    await _tasksBox.delete(id);
  }
}
