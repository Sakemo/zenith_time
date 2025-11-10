import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

//database
import 'package:zenith_time/core/database/database_service.dart';

//models
import 'package:zenith_time/core/models/project_model.dart';
import 'package:zenith_time/core/models/task_model.dart';
import 'package:zenith_time/core/models/time_entry_model.dart';

//logic
import 'package:zenith_time/features/tracker/logic/time_entry_service.dart';
import 'package:zenith_time/features/tracker/logic/timer_service.dart';
import 'package:zenith_time/features/tracker/ui/tracker_screen.dart';

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
    return ChangeNotifierProvider(
      create: (context) => TimerService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zenith Time',
        theme: AppTheme.themeData,
        home: const TrackerScreen(),
      ),
    );
  }
}
