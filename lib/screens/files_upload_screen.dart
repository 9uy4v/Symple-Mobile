import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/main.dart';
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
    final isSending =
        Provider.of<SocketProvider>(context, listen: true).isSending;
    publicContext = context;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<FilesProvider>(context, listen: false)
                    .clearFilesList();
                Provider.of<SocketProvider>(context, listen: false)
                    .disconnect();
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
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height / 2),
              child: ListView.builder(
                itemCount: Provider.of<FilesProvider>(context, listen: true)
                    .files
                    .length,
                itemBuilder: (context, index) {
                  final currentFile =
                      Provider.of<FilesProvider>(context, listen: false)
                          .files[index];
                  final fileName = currentFile.path.split('/').last;
                  final fileProgress =
                      Provider.of<FilesProvider>(context, listen: true)
                          .progressList[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Dismissible(
                      key: Key(fileName),
                      direction: isSending
                          ? DismissDirection.none
                          : DismissDirection.horizontal,
                      background: Container(
                        padding: const EdgeInsets.all(8),
                        color: const Color.fromARGB(255, 225, 100, 100),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        Provider.of<FilesProvider>(context, listen: false)
                            .removeFileByIndex(index);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(56, 235, 228, 234),
                                blurRadius: 3,
                                spreadRadius: 2,
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 246, 238, 244),
                              width: 2,
                            )),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              flex: 1,
                              child: SvgPicture.asset(
                                Provider.of<FilesProvider>(context,
                                        listen: false)
                                    .getFileIconPath(
                                  fileName.split('.').last,
                                ),
                                height: 25,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              flex: 6,
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: Text(
                                      fileName,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      Provider.of<FilesProvider>(context,
                                              listen: false)
                                          .getFileSizeString(currentFile),
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromARGB(255, 96, 96, 96),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (isSending)
                              Flexible(
                                flex: 1,
                                child: CircularUploadIndicator(
                                    progress: fileProgress),
                              ),
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
                      Provider.of<FilesProvider>(context, listen: false)
                          .selectFiles();
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
        visible: Provider.of<FilesProvider>(context, listen: true)
                .files
                .isNotEmpty &&
            !isSending,
        child: FloatingActionButton(
          onPressed: () {
            print('pressed send');
            if (!isSending) {
              Provider.of<FilesProvider>(context, listen: false)
                  .createPrecentageList();
              Provider.of<SocketProvider>(context, listen: false).sendFiles(
                  Provider.of<FilesProvider>(context, listen: false).files,
                  context);
            }
          },
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}

// TO DO : when exiting via button, send message to server to print the qr code again and clear files array
