import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(context) {
    final isSending = Provider.of<SocketProvider>(context, listen: true).isSending;
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
                itemCount: Provider.of<FilesProvider>(context, listen: true).files.length,
                itemBuilder: (context, index) {
                  final fileName = Provider.of<FilesProvider>(context, listen: false).files[index].path.split('/').last;
                  final fileProgress = Provider.of<FilesProvider>(context, listen: true).progressList[index];
                  return Dismissible(
                    key: Key(fileName),
                    direction: isSending ? DismissDirection.none : DismissDirection.horizontal,
                    background: Container(
                      padding: const EdgeInsets.all(8),
                      color: const Color.fromARGB(255, 225, 100, 100),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      Provider.of<FilesProvider>(context, listen: false).removeFile(index);
                    },
                    child: Row(
                      children: [
                        if (isSending)
                          ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 30, maxWidth: 30),
                              child: fileProgress == 0
                                  // if 0% -> spinning circle
                                  ? const CircularProgressIndicator()
                                  : fileProgress < 1 && fileProgress > 0
                                      // if 1-99% -> progress showing circle
                                      ? CircularProgressIndicator(
                                          value: fileProgress,
                                        )
                                      // if 100% -> check
                                      : const Icon(
                                          Icons.check,
                                          size: 30,
                                          color: Colors.green,
                                        )),
                        if (!isSending)
                          const Icon(
                            Icons.file_copy,
                            size: 30,
                          ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          fileName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
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
      floatingActionButton: Visibility(
        visible: Provider.of<FilesProvider>(context, listen: true).files.isNotEmpty,
        child: FloatingActionButton(
          onPressed: () {
            print('pressed send');
            if (!Provider.of<SocketProvider>(context, listen: false).isSending) {
              Provider.of<FilesProvider>(context, listen: false).createPrecentageList();
              Provider.of<SocketProvider>(context, listen: false).sendFiles(Provider.of<FilesProvider>(context, listen: false).files, context);
            }
          },
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}


// TO DO : better looking loading animations
// TO DO : when exiting via button, send message to server to print the qr code again and clear files array
