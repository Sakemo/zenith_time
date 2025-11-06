import 'package:hive/hive.dart';

part 'time_entry_model.g.dart';

@HiveType(typeId: 2)
class TimeEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  String? description;

  TimeEntry({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    this.description,
  });
}
