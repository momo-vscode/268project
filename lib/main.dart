import 'package:counttimer/my_foreground_service.dart';
import 'package:counttimer/my_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import 'page/start_page.dart';
import 'time_provider.dart';

//top-level or static function.
@pragma('vm:entry-point')
void setHandler() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

void main() {
  // Initialize port for communication between TaskHandler and UI.
  FlutterForegroundTask.initCommunicationPort();
  runApp(ChangeNotifierProvider(
    create: (context) => TimeProvider(),
    child: const TimerApp(),
  ));
}

class TimerApp extends StatefulWidget {
  const TimerApp({Key? key}) : super(key: key);

  @override
  State<TimerApp> createState() => TimerAppState();
}

class TimerAppState extends State<TimerApp> with WidgetsBindingObserver {
  //late final for the context
  late final TimeProvider _timeProvider =
      Provider.of<TimeProvider>(context, listen: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MyForegroundService.requestAditionalPermissions();
      MyForegroundService.initForegroundService();
    });
  }

  @override
  void dispose() {
    // FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.removeObserver(this);
    _timeProvider.removeListener(() {
      MyForegroundService.updateForegroundService(_timeProvider.remainingTime);
    });
    MyForegroundService.stopForegroundService();
    super.dispose();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await MyForegroundService.startForegroundService();
      //addlistener related to the ChangeNotifier notifyListeners() for dynamic noticefycation when at the background
      _timeProvider.addListener(() {
        MyForegroundService.updateForegroundService(
            _timeProvider.remainingTime);
      });
    } else if (state == AppLifecycleState.resumed) {
      await MyForegroundService.stopForegroundService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      //****change to the cubit one
      themeMode: ThemeMode.system,
      home: const StartPage(),
    );
  }
}
