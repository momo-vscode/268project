import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'main.dart';

class MyForegroundService {
  static void initForegroundService() {
    FlutterForegroundTask.init(
      //some default set in the package alrealy, such as NotificationVisibility default `NotificationVisibility.VISIBILITY_PUBLIC`.
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
        //TaskEvent interval 1000ms
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<ServiceRequestResult> startForegroundService() async {
    //check if there is a service alrealy
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return await FlutterForegroundTask.startService(
        //define an id, make sure unique
        serviceId: 256,
        notificationTitle: 'CountTimer',
        notificationText: 'App is in the background.',
        notificationIcon: null,
        // notificationButtons:...
        // top level method, defined in main
        callback: setHandler,
      );
    }
  }

  static Future<ServiceRequestResult> stopForegroundService() async {
    return await FlutterForegroundTask.stopService();
  }

// Android 12+, there are restrictions on starting a foreground service.
// Android 13+(API level 33),need notification permission to display foreground service notification.
//the below permissions are restricted and require the user to explicitly grant them at runtime, not only in manifest
  static Future<void> requestAditionalPermissions() async {
    // set permission for notice
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    // requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
    // Note: Exact alarms permission is limited due to Google Play policies, so check that your app complies with Google’s guidelines if you intend to publish it on the Play Store.
    // When you call this function, will be gone to the settings page.
    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }
  }

  static Future<void> updateForegroundService(int remainingTime) async {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(remainingTime ~/ 60);
    String seconds = twoDigits(remainingTime % 60);
    await FlutterForegroundTask.updateService(
      notificationTitle: 'Good Luck!',
      notificationText: '$minutes:$seconds',
    );
  }
}

  
  // void _onReceiveTaskData(Object data) {
  //   if (data is Map<String, dynamic>) {
  //     final dynamic timestampMillis = data["timestampMillis"];
  //     if (timestampMillis != null) {
  //       final DateTime timestamp =
  //           DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
  //       print('timestamp: ${timestamp.toString()}');
  //     }
  //   }
  // }