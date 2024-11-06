import 'package:counttimer/foreground_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';

import 'page/start_page.dart';
import 'time_provider.dart';

void main() {
  // Initialize port for communication between TaskHandler and UI.
  FlutterForegroundTask.initCommunicationPort();
  runApp(ChangeNotifierProvider(
    create: (context) => TimeProvider(),
    child: const TimerApp(),
  ));
}

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
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
    // Add a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request permissions and initialize the service.
      await _requestPermissions();
      _initService();
    });
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartPage(),
    );
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('timestamp: ${timestamp.toString()}');
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (true) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        // When you call this function, will be gone to the settings page.
        // So you need to explain to the user why set it.
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // Future<ServiceRequestResult> _startService() async {
  //   if (await FlutterForegroundTask.isRunningService) {
  //     return FlutterForegroundTask.restartService();
  //   } else {
  //     return FlutterForegroundTask.startService(
  //       serviceId: 256,
  //       notificationTitle: 'Foreground Service is running',
  //       notificationText: 'Tap to return to the app',
  //       notificationIcon: null,
  //       notificationButtons: [
  //         const NotificationButton(id: 'btn_hello', text: 'hello'),
  //       ],
  //       callback: startCallback,
  //     );
  //   }
  // }

  Future<ServiceRequestResult> _stopService() async {
    return FlutterForegroundTask.stopService();
  }
}


/*
//   @override
//   // 初始化，
//   void initState() {
//     super.initState();
//     // 初始化增加一个观查器，实时跟踪app前后台的变化
//     WidgetsBinding.instance.addObserver(this);
//     //此为函数调用，看后面。主要目的初始化后台服务：app转去后台的时候不被kill， 但是取名一般叫foreground task。
//     initForegroundTask();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     FlutterForegroundTask.stopService();
//     super.dispose();
//   }

// //定义上面initState里面后台服务
//   void initForegroundTask() {
//     //查看FlutterForegroundTask package pub.dev 怎样初始化，需要约定什么。可能需要交流通道，通道上的handler。
//     FlutterForegroundTask.initForegroundTask(
//       notificationTitle: 'Timer App',
//       notificationText: 'Timer is running in the background.',
//       //调整地方，不是初始化启动时钟。
//       callback: updateRemainingTimeInBackground,
//     );
//   }

//   @override
//   //观察前后台状态部分，paused为app转到后台，这个时候原来在前台app上跑的时钟暂停。启动后台服务（如上面所说，后台服务应该有通道和具体handler 启动后台时钟，实时展示）
//   //resumed为切回前台，恢复前台时钟
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       Provider.of<TimeProvider>(context, listen: false).pauseTimer();
//       startForegroundService();
//     } else if (state == AppLifecycleState.resumed) {
//       Provider.of<TimeProvider>(context, listen: false).resumeTimer();
//     }
//   }

//   void startForegroundService() {
//     FlutterForegroundTask.startService(
//       notificationTitle: 'Countdown Timer',
//       notificationText: 'The timer is running in the background.',
//     );
//   }

//   static void updateRemainingTimeInBackground() {
//     // Define how the time should be updated when the app is in the background
//   }





// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_service/flutter_foreground_service.dart';
// import 'package:mylearning/page/start_page.dart';
// import 'package:mylearning/time_provider.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(ChangeNotifierProvider(
//     create: (context) => TimeProvider(),
//     child: const TimerApp(),
//   ));
// }

// class TimerApp extends StatefulWidget {
//   const TimerApp({Key? key}) : super(key: key);

//   @override
//   State<TimerApp> createState() => TimerAppState();
// }

// class TimerAppState extends State<TimerApp> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     initForegroundService();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     FlutterForegroundService.stopForegroundService();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print('App lifecycle state changed to: $state');
//     if (state == AppLifecycleState.paused) {
//       Provider.of<TimeProvider>(context, listen: false).pauseTimer();
//       startForegroundService();
//     } else if (state == AppLifecycleState.resumed) {
//       updateRemainingTime();
//       Provider.of<TimeProvider>(context, listen: false).resumeTimer();
//     }
//   }

//   Future<void> initForegroundService() async {
//     await FlutterForegroundService.initialize(
//       notificationTitle: "Timer App",
//       notificationText: "Your countdown timer is running in the background.",
//     );
//   }

//   Future<void> startForegroundService() async {
//     int remainingTime =
//         Provider.of<TimeProvider>(context, listen: false).remainingTime;
//     FlutterForegroundService.startForegroundServiceWithNotification();
//     FlutterForegroundService.invoke(
//       "updateTime",
//       {"remainingTime": remainingTime},
//     );
//   }

//   Future<void> updateRemainingTime() async {
//     FlutterForegroundService.invoke("updateTime");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Timer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.grey,
//       ),
//       home: const StartPage(),
//     );
//   }
// }
*/
