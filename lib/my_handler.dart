import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Called when startService-->callback
class MyTaskHandler extends TaskHandler {
  late SharedPreferences prefs;
  int remainingTime = 0;

  // @override
  // void onReceiveData(Object? data) {
  //   if (data is Map<String, dynamic> && data.containsKey('remainingTime')) {
  //     remainingTime = data['remainingTime'] as int;
  //     // this is ok, printed
  //     print('Received remainingTime: $remainingTime');
  //   }
  // }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    prefs = await SharedPreferences.getInstance();
    remainingTime = await prefs.getInt('remainingTime') ?? 0;
  }

  // Called by eventAction in [ForegroundTaskOptions]. - nothing() , - once() , - repeat(interval) :
  @override
  void onRepeatEvent(DateTime timestamp) {
    if (remainingTime > 0) {
      print("test_remaining: $remainingTime");
      remainingTime--;
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String minutes = twoDigits(remainingTime ~/ 60);
      String seconds = twoDigits(remainingTime % 60);
      FlutterForegroundTask.updateService(
        notificationTitle: 'Good Luck!',
        notificationText: '$minutes:$seconds',
      );
    }
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('remainingTime', remainingTime);
    remainingTime = 0;
    print('onDestroy');
  }
}
