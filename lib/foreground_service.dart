import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// class MyForegroundService {
//   static Future<void> startService(int remainingTime) async {
//     await FlutterForegroundTask.startService(
//       notificationTitle: "Timer Running",
//       notificationText: "Your timer is counting down.",
//     );
//     FlutterForegroundTask.setData({
//       'remainingTime': remainingTime,
//     });
//   }

//   static Future<void> stopService() async {
//     await FlutterForegroundTask.stopService();
//   }

//   static Future<void> updateTime(int remainingTime) async {
//     FlutterForegroundTask.setData({
//       'remainingTime': remainingTime,
//     });
//   }
// }

// // The callback function should always be a top-level or static function.
// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }
}



// // import 'package:flutter_background_service/flutter_background_service.dart';
// // import 'package:flutter_foreground_service/flutter_foreground_service.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// // class ForegroundServiceManager {
// //   static void initializeForegroundService() {
// //     FlutterForegroundService.initialize(
// //       notificationTitle: "Timer Running",
// //       notificationText: "Your timer is counting down in the background.",
// //     );
// //   }
// // class MyForegroundService {
// //   static Future<void> init() async {
// //     final service = FlutterBackgroundService();
// //     await service.configure(
// //       androidConfiguration: AndroidConfiguration(
// //         onStart: _onStart,
// //         isForegroundMode: true,
// //         autoStart:
// //             false,
// //       ),
// //       iosConfiguration: IosConfiguration(
// //         onForeground: _onStart,
// //         autoStart: false,
// //       ),
// //     );
// //   }

// class MyForegroundService {
//   static Future<void> init() async {
//     final service = ForegroundService();
//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: _onStart,
//         isForegroundMode: true,
//         autoStart: false,
//       ),
//       iosConfiguration: IosConfiguration(
//         onForeground: _onStart,
//         autoStart: false,
//       ),
//     );
//   }

//   static void _onStart(ServiceInstance service) async {
//     service.on('stopService').listen((event) async {
//       await service.stopSelf();
//     });
//   }

// //   static Future<void> startService(int remainingTime) async {
// //     await FlutterForegroundService.startForegroundServiceWithNotification();
// //     FlutterForegroundService.invoke(
// //       "updateTime",
// //       {"remainingTime": remainingTime},
// //     );
// //   }
//   static Future<void> startService(int remainingTime) async {
//     final service = FlutterBackgroundService();
//     service.startService();
//     await ForegroundService.startForegroundServiceWithNotification();
//     ForegroundService.invoke(
//       "updateTime",
//       {"remainingTime": remainingTime},
//     );
//   }

// //   static Future<void> stopService() async {
// //     await FlutterForegroundService.stopForegroundService();
// //   }
//   static Future<void> stopService() async {
//     final service = FlutterBackgroundService();
//     service.invoke("stopService");
//   }

//   static Future<void> updateTime(int remainingTime) async {
//     FlutterForegroundService.invoke(
//         "updateTime", {"remainingTime": remainingTime});
//   }
// }
