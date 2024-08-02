import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: const Text(
        'Upload files to PC',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
      ),
    );
  }
}
