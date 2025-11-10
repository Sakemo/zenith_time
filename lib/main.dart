import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

//database
import 'package:zenith_time/core/database/database_service.dart';

//models
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  //adapters generators or something like that
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TimeEntryAdapter());

  await DatabaseService.openBoxes();

  runApp(const ZenithTimeApp());
}

class ZenithTimeApp extends StatelessWidget {
  const ZenithTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zenith Time',
      theme: AppTheme.themeData,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zenith Time'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: Text('Olá, Zenith Time!')),
      ),
    );
  }
}
