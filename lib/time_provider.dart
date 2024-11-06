import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class TimeProvider with ChangeNotifier {
  Timer? downTimer;
  int _remainingTime = 0; // before start countdown go to the background

  int get remainingTime => _remainingTime;

  void startTimer() {
    // If there's a timer already, cancel it first
    downTimer?.cancel();
    downTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        // Update notification content.
        FlutterForegroundTask.updateService(
          notificationTitle: 'Hello MyTaskHandler :)',
          notificationText: 'count: $_remainingTime',
        );
        notifyListeners();
      } else {
        downTimer?.cancel();
      }
    });
  }

  void pauseTimer() {
    downTimer?.cancel(); // Cancels the timer
  }

  void resumeTimer() {
    startTimer(); // Resumes the timer
  }

  void updateTimer(int time) {
    _remainingTime = time;
    notifyListeners();
  }
}
