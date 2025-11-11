import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  // custom
  @HiveField(3)
  int iconCodePoint;

  @HiveField(4)
  int colorValue;

  Project({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.iconCodePoint,
    required this.colorValue,
  });
}
