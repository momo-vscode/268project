import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
// }

class FirstTaskHandler extends TaskHandler {
  int _count = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // some code
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _count++;

    if (_count == 10) {
      FlutterForegroundTask.updateService(
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(1000),
        ),
        callback: updateCallback,
      );
    } else {
      FlutterForegroundTask.updateService(
        notificationTitle: 'Hello FirstTaskHandler :)',
        notificationText: timestamp.toString(),
      );

      // Send data to main isolate.
      final Map<String, dynamic> data = {
        "timestampMillis": timestamp.millisecondsSinceEpoch,
      };
      FlutterForegroundTask.sendDataToMain(data);
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // some code
  }
}

@pragma('vm:entry-point')
void updateCallback() {
  FlutterForegroundTask.setTaskHandler(SecondTaskHandler());
}

class SecondTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // some code
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Hello SecondTaskHandler :)',
      notificationText: timestamp.toString(),
    );

    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // some code
  }
}
