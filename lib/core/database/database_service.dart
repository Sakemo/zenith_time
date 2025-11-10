import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';

const String projectsBoxName = 'projects';
const String tasksBoxName = 'tasks';
const String timeEntriesBoxName = 'time_entries';

class DatabaseService {
  static Future<void> openBoxes() async {
    await Hive.openBox<Project>(projectsBoxName);
    await Hive.openBox<Task>(tasksBoxName);
    await Hive.openBox<TimeEntry>(timeEntriesBoxName);
  }
}
