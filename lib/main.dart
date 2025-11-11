import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

// services
import 'package:zenith_time/features/projects/logic/project_service.dart';
import 'package:zenith_time/features/tracker/logic/task_service.dart';

//database
import 'package:zenith_time/core/database/database_service.dart';

//models
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';

//logic
import 'package:zenith_time/features/tracker/logic/timer_service.dart';
import 'package:zenith_time/app/ui/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appSupportDir = await getApplicationSupportDirectory();

  await Hive.initFlutter();
  final dir = await getApplicationDocumentsDirectory();
  print('Hive path: ${dir.path}');

  // Se houver um arquivo .lock, delete também
  final lockFile = File('${appSupportDir.path}/projects.lock');
  if (await lockFile.exists()) {
    await lockFile.delete();
  }

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerService()),
        Provider(create: (context) => ProjectService()),
        Provider(create: (context) => TaskService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zenith Time',
        theme: AppTheme.themeData,
        home: const MainShell(),
      ),
    );
  }
}
