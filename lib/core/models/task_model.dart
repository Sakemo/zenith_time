import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final String projectId;

  @HiveField(3)
  final DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    required this.projectId,
    required this.createdAt,
  });
}
