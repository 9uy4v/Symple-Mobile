import 'package:flutter/material.dart';

class CircularUploadIndicator extends StatelessWidget {
  const CircularUploadIndicator({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress == 1) {
      return const Icon(
        Icons.check,
        color: Colors.green,
        size: 27.5,
      );
    } else if (progress == -1) {
      // ERROR uploading
      return const Icon(
        Icons.error_outline,
        color: Color.fromARGB(255, 175, 76, 76),
        size: 27.5,
      );
    } else {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 27.5, maxWidth: 27.5),
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).disabledColor,
          value: progress == 0 ? null : progress,
          strokeCap: StrokeCap.round,
        ),
      );
    }
  }
}
