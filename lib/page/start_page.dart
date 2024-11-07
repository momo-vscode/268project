import 'package:counttimer/page/count_page.dart';
import 'package:counttimer/time_provider.dart';
import 'package:counttimer/widget/duration_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  late Duration timerDuration;

  @override
  void initState() {
    super.initState();
    timerDuration = const Duration(minutes: 25);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetDuration() {
    setState(() {
      // Reset duration
      timerDuration += 1 as Duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Countdown Timer"),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.share),
      //       onPressed: () {
      //         // Handle share functionality
      //         print('Share button pressed');
      //       },
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.brightness_auto),
      //       onPressed: () {
      //         // Toggle theme mode
      //         print('Theme toggle button pressed');
      //       },
      //     ),
      //   ],
      // ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: resetDuration,
              child: DurationWidget(duration: timerDuration), //dispaly
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Start'),
              onPressed: () {
                Provider.of<TimeProvider>(context, listen: false)
                    .updateTimer(timerDuration.inSeconds);
                // Navigate to CountPage
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => CountPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
