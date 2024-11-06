import 'package:flutter/material.dart';

class DurationWidget extends StatefulWidget {
  final Duration duration; // Make sure it's final for immutability
  const DurationWidget({
    super.key,
    required this.duration, // This is the named parameter
  });

  @override
  State<DurationWidget> createState() => DurationWidgetState();
}

class DurationWidgetState extends State<DurationWidget> {
  // Function to format the duration into mm:ss format
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        // Use widget.duration to refer to the duration value passed from the parent
        formatDuration(widget.duration),
        style: const TextStyle(fontSize: 32, color: Colors.black),
      ),
    );
  }
}
