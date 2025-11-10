import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/tracker/logic/timer_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final TextEditingController _taskNameController = TextEditingController();

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, timerService, child) {
        return Scaffold(
          body: Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionToolbar(timerService),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'lista e relatorios aqui',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 80,
      color: const Color(0xFF1e1e1e),
      child: const Column(
        children: [
          SizedBox(height: 24),
          Icon(Icons.timer_outlined, color: Colors.white, size: 32),
          SizedBox(height: 24),
          Icon(Icons.folder_outlined, color: Colors.grey, size: 32),
        ],
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

        Text(
          _formatDuration(timerService.elapsedDuration),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: 16),

        IconButton(
          icon: Icon(
            timerService.isRunning ? Icons.stop_circle : Icons.play_circle,
            size: 36,
          ),
          onPressed: () {
            if (timerService.isRunning) {
              timerService.stopTimer();
              _taskNameController.clear();
            } else {
              if (_taskNameController.text.isNotEmpty) {
                final dummyTask = Task(
                  id: 'dummy-task-id',
                  name: _taskNameController.text,
                  projectId: 'dummy-project-id',
                  createdAt: DateTime.now(),
                );
                timerService.startTimer(dummyTask);
              }
            }
          },
          color: timerService.isRunning
              ? AppTheme.adwaitaTextColor
              : AppTheme.adwaitaBlue,
        ),
      ],
    );
  }
}
