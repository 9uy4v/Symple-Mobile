import 'package:flutter/material.dart';
import 'package:symple_mobile/connect.dart';

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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectScreen(),
                    ));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              'Upload files to PC',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height / 2),
              child: ListView.builder(
                itemCount: 2, // TO DO : change according to file count from provider
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    child: const Row(
                      children: [
                        Icon(Icons.file_copy),
                        SizedBox(
                          width: 5,
                        ),
                        Text('filename.txt'),
                      ],
                    ),
                  );
                },
              ),
            ),
            IconButton.filled(
              onPressed: () {
                // TO DO : choose and add documents from phone
              },
              icon: const Icon(
                Icons.add,
                size: 36,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TO DO : send files to pc, clear chosen file array
          
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
