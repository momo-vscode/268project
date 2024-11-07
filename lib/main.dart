import 'package:counttimer/my_foreground_service.dart';
import 'package:counttimer/my_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MyForegroundService.requestAditionalPermissions();
      MyForegroundService.initForegroundService();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MyForegroundService.stopForegroundService();
    super.dispose();
  }

//再详细，特别是stop service 检查notice
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      //  data --> startForegroundService()--> call handler onRepeatEvent(updateservice)
      //sendDataToTask() parameter is an object
      //the handker use onReceiveData(Object data) to access it
      int remainingTime =
          Provider.of<TimeProvider>(context, listen: false).remainingTime;
      // FlutterForegroundTask.sendDataToTask({'remainingTime': remainingTime});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('remainingTime', remainingTime);

      await MyForegroundService.startForegroundService();
    } else if (state == AppLifecycleState.resumed) {
      await MyForegroundService.stopForegroundService();
    } else if (state == AppLifecycleState.detached) {
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
