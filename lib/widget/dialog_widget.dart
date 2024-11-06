import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  final bool isSuccessFocus;
  const DialogWidget({super.key, required this.isSuccessFocus});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isSuccessFocus == true
          ? 'Countdown Complete!'
          : 'Countdown Stopped!'),
      content: Text(isSuccessFocus == true
          ? 'The countdown has finished successfully.'
          : 'The countdown was stopped.'),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(), // Close dialog manually
        ), // Close dialog
      ],
    );
  }
}
