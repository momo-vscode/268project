import 'dart:async';
import 'dart:core';

import 'package:counttimer/time_provider.dart';
import 'package:counttimer/widget/dialog_widget.dart';
import 'package:counttimer/widget/duration_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountPage extends StatefulWidget {
  const CountPage({super.key});

  @override
  State<CountPage> createState() => CountPageState();
}

class CountPageState extends State<CountPage> {
  StreamController<bool>? gyroStream;
  StreamSubscription<bool>? gyroSubscription;
  bool isGyroStopped = false;
  bool isSuccessFocus = false;

  @override
  void initState() {
    super.initState();
    Provider.of<TimeProvider>(context, listen: false).startTimer();
    // int remainingTime =
    //     Provider.of<TimeProvider>(context, listen: false).remainingTime;
    // MyForegroundService.startForegroundService();

    // Assuming you're streaming gyro events
    // gyroStream = StreamController<bool>();
    // gyroSubscription = gyroStream!.stream.listen((gyroStopped) {
    //   setState(() {
    //     isGyroStopped = gyroStopped;
    // });
    // });
  }

//when the timer change state to pause checkFocusState()
  void checkFocusState() {
    int remainingTime =
        Provider.of<TimeProvider>(context, listen: false).remainingTime;
    // Set the isSuccessFocus based on the conditions
    if (remainingTime == 0) {
      isSuccessFocus = true;
    } else if (remainingTime > 0 && isGyroStopped) {
      isSuccessFocus = false;
    }
    // Display the dialog
    showDialog(
      context: context,
      builder: (context) => DialogWidget(isSuccessFocus: isSuccessFocus),
    );
  }

  @override
  void dispose() {
    gyroSubscription?.cancel();
    gyroStream?.close();
    Provider.of<TimeProvider>(context, listen: false).downTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Consumer is a widget from the Provider package, listen changes in TimeProvider, rebuilds the UI
        child: Consumer<TimeProvider>(
          // builder: update the UI
          builder: (context, timeProvider, child) {
            int remainingTime = timeProvider.remainingTime;
            //The downTimer in TimeProvider is a Timer object,If downTimer is still running, isActive will be true
            if (!(timeProvider.downTimer!.isActive)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                checkFocusState();
              });
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the countdown timer
                DurationWidget(
                  duration: Duration(seconds: remainingTime),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
