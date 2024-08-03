import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isSending = false;
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
              height: 20,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height / 2),
              child: ListView.builder(
                itemCount: Provider.of<FilesProvider>(context, listen: true).files.length, // TO DO : change according to file count from provider
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        if (isSending)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
                            child: const CircularProgressIndicator(),
                          ),
                        if (!isSending)
                          const Icon(
                            Icons.file_copy,
                            size: 30,
                          ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(Provider.of<FilesProvider>(context, listen: false).files[index].path.split('/').last),
                      ],
                    ),
                  );
                },
              ),
            ),
            IconButton.filled(
              onPressed: isSending
                  ? null
                  : () {
                      Provider.of<FilesProvider>(context, listen: false).selectFiles();
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
        onPressed: Provider.of<FilesProvider>(context, listen: true).files.isEmpty
            ? () {
                print('choose files first');
                // TO DO : add snackbar alert or button not shown when no files selected (preferably the last option)
              }
            : () {
                print('pressed send');
                setState(() {
                  isSending = !isSending;
                });
                // TO DO : send files to pc, clear chosen file array
                // TO DO : when sending make sure all files are not null in case they were deleted after being selected
              },
        child: const Icon(Icons.send),
      ),
    );
  }
}
