// lib/core/dev/data_seeder.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';

class DataSeeder {
  final ProjectService _projectService;
  final TaskService _taskService;
  final TimeEntryService _timeEntryService;

  DataSeeder(this._projectService, this._taskService, this._timeEntryService);

  Future<void> seedDatabase() async {
    print("--- INICIANDO SEEDING DE DADOS ---");
    final random = Random();
    final now = DateTime.now();

    await _clearAllData();

    await _projectService.addProject(
      'Desenvolvimento Zenith Time',
      Icons.code.codePoint,
      Colors.blue.value,
    );
    await _projectService.addProject(
      'Estudos de Flutter',
      Icons.school.codePoint,
      Colors.green.value,
    );
    await _projectService.addProject(
      'Tarefas Domésticas',
      Icons.home.codePoint,
      Colors.orange.value,
    );

    final projects = _projectService.getAllProjects();
    if (projects.isEmpty) {
      print("Falha ao criar projetos. Abortando.");
      return;
    }

    final Map<String, List<Task>> tasksByProject = {};
    for (final project in projects) {
      tasksByProject[project.id] = [
        await _taskService.addTask('Planejamento', project.id),
        await _taskService.addTask('Implementação', project.id),
        await _taskService.addTask('Revisão de Código', project.id),
      ];
    }

    for (int i = 0; i < 30; i++) {
      if (random.nextDouble() < 0.2) continue;

      final day = now.subtract(Duration(days: i));

      final entriesPerDay = random.nextInt(5) + 1;
      for (int j = 0; j < entriesPerDay; j++) {
        final randomProject = projects[random.nextInt(projects.length)];
        final projectTasks = tasksByProject[randomProject.id]!;
        final randomTask = projectTasks[random.nextInt(projectTasks.length)];

        final durationInMinutes = random.nextInt(135) + 15;
        final duration = Duration(minutes: durationInMinutes);

        final startHour = random.nextInt(10) + 8;
        final startMinute = random.nextInt(60);
        final startTime = DateTime(
          day.year,
          day.month,
          day.day,
          startHour,
          startMinute,
        );
        final endTime = startTime.add(duration);

        // --- CÓDIGO CORRIGIDO ---
        // Usa o novo método para criar a entrada de tempo diretamente
        await _timeEntryService.createSeedEntry(
          taskId: randomTask.id,
          startTime: startTime,
          endTime: endTime,
        );
      }
    }

    print("--- SEEDING DE DADOS CONCLUÍDO ---");
  }

  Future<void> _clearAllData() async {
    print("Limpando dados antigos...");
    final projects = _projectService.getAllProjects();
    for (final project in projects) {
      await _projectService.deleteProject(project.id);
    }
  }
}
