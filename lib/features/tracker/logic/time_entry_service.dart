import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_time/core/database/database_service.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';

class TimeEntryService {
  final Box<TimeEntry> _entriesBox = Hive.box<TimeEntry>(timeEntriesBoxName);
  final _uuid = const Uuid();

  Future<TimeEntry> createEntry(String taskId) async {
    final newEntry = TimeEntry(
      id: _uuid.v4(),
      taskId: taskId,
      startTime: DateTime.now(),
    );

    await _entriesBox.put(newEntry.id, newEntry);
    return newEntry;
  }

  List<TimeEntry> getTodayEntries() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _entriesBox.values
        .where((entry) => entry.startTime.isAfter(startOfDay))
        .toList();
  }

  Future<void> updateEntry(TimeEntry entry) async {
    await _entriesBox.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _entriesBox.delete(id);
  }
}
