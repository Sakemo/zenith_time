import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:zenith_time/core/database/database_service.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';

class TimeEntryService {
  final Box<TimeEntry> _entriesBox = Hive.box<TimeEntry>(timeEntriesBoxName);
  final Box<Task> _taskBox = Hive.box<Task>(tasksBoxName);
  final _uuid = const Uuid();

  List<TimeEntry> getEntriesInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final allEntries = _entriesBox.values.where((e) => e.endTime != null);

    final filteredEntries = allEntries.where((e) {
      return e.startTime.isAfter(start) && e.startTime.isBefore(end);
    });

    return filteredEntries.toList();
  }

  Map<DateTime, Map<String, Duration>> getAggregatedData({
    required DateTime start,
    required DateTime end,
  }) {
    final Map<DateTime, Map<String, Duration>> data = {};

    final allEntries = _entriesBox.values.where((e) => e.endTime != null);

    final filteredEntries = allEntries.where((e) {
      return e.startTime.isAfter(start) && e.startTime.isBefore(end);
    });

    for (final entry in filteredEntries) {
      final day = DateUtils.dateOnly(entry.startTime);
      final task = _taskBox.get(entry.taskId);
      if (task == null) continue;

      final projectId = task.projectId;
      final duration = entry.endTime!.difference(entry.startTime);

      data.putIfAbsent(day, () => {});
      data[day]!.putIfAbsent(projectId, () => Duration.zero);
      data[day]![projectId] = data[day]![projectId]! + duration;
    }

    return data;
  }

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

  Duration getDurationForTask(String taskId) {
    final entries = _entriesBox.values.where(
      (entry) => entry.taskId == taskId && entry.endTime != null,
    );

    if (entries.isEmpty) {
      return Duration.zero;
    }

    return entries
        .map((entry) => entry.endTime!.difference(entry.startTime))
        .reduce((value, element) => value + element);
  }

  Duration getDurationForProject(String projectId) {
    final tasksInProject = _taskBox.values.where(
      (task) => task.projectId == projectId,
    );

    if (tasksInProject.isEmpty) {
      return Duration.zero;
    }

    return tasksInProject
        .map((task) => getDurationForTask(task.id))
        .reduce((value, element) => value + element);
  }
}
