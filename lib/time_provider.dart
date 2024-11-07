import 'dart:async';

import 'package:flutter/material.dart';

class TimeProvider with ChangeNotifier {
  Timer? downTimer;
  int _remainingTime = 0; // before start countdown go to the background

  int get remainingTime => _remainingTime;

  @override
  void dispose() {
    // Cancel the countdown timer to free resources
    downTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // If there's a timer already, cancel it first
    downTimer?.cancel();
    downTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        downTimer?.cancel();
      }
    });
  }

  void updateTimer(int time) {
    _remainingTime = time;
    notifyListeners();
  }
}






  // void pauseTimer() {
  //   downTimer?.cancel(); // Cancels the timer
  // }

  // void resumeTimer() {
  //   startTimer(); // Resumes the timer
  // }

