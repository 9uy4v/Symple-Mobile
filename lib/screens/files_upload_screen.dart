import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';
import 'package:symple_mobile/widgets/file_loading_circle.dart';

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
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Dismissible(
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(131, 235, 228, 234),
                                blurRadius: 3,
                                spreadRadius: 2,
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 235, 228, 234),
                              width: 2,
                            )),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Icons.file_copy, // TO DO : replace with icon according to file type
                              size: 30,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              fileName, // TO DO : handle long file names
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                            const Spacer(),
                            if (isSending) CircularUploadIndicator(progress: fileProgress),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
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
