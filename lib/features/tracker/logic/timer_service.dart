import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

class TimerService extends ChangeNotifier {
  final TimeEntryService _timeEntryService = TimeEntryService();
  Timer? _timer;

  bool get isRunning => _timer?.isActive ?? false;
  Duration _elapsedDuration = Duration.zero;
  Duration get elapsedDuration => _elapsedDuration;

  Task? _activeTask;
  Task? get activeTask => _activeTask;

  TimeEntry? _activeTimeEntry;

  Future<void> startTimer(Task task) async {
    if (isRunning) {
      return;
    }

    _activeTask = task;
    _activeTimeEntry = await _timeEntryService.createEntry(task.id);

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);

    notifyListeners();
  }

  Future<void> stopTimer() async {
    if (!isRunning || _activeTimeEntry == null) {
      return;
    }

    _timer?.cancel();

    _activeTimeEntry!.endTime = DateTime.now();
    await _timeEntryService.updateEntry(_activeTimeEntry!);

    _elapsedDuration = Duration.zero;
    _activeTask = null;
    _activeTimeEntry = null;

    notifyListeners();
  }

  void _tick(Timer timer) {
    _elapsedDuration = DateTime.now().difference(_activeTimeEntry!.startTime);

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
