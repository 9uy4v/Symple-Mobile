import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:symple_mobile/main.dart';
import 'package:symple_mobile/providers/files_provider.dart';

class SocketProvider with ChangeNotifier {
  late SecureSocket _socket;
  late String _serverIp;
  late int _serverPort;

  bool _isSending = false;

  late Completer sendingFile;
  late Completer transTimeout;
  late File file;
  late String fileName;
  late int fileSize;

  bool get isSending => _isSending;

  // creates connection with pc
  // returns true if connection successful and false if error
  Future<bool> _createConnection() async {
    try {
      _socket = await SecureSocket.connect(
        _serverIp,
        _serverPort,
        context: SecurityContext.defaultContext,
        timeout: const Duration(seconds: 10),
        onBadCertificate: (certificate) => true,
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  Future<bool> handleCode(String code) async {
    // TODO : add code verification here
    code = utf8.decode(base64Decode(code));
    _serverIp = code.split(':')[0];
    _serverPort = int.parse(code.split(':')[1]);

    // checks if can connect
    if (await _createConnection()) {
      _socket.listen(
        (data) {
          final message = String.fromCharCodes(data);
          debugPrint('Recived : $message');

          // got intentions command, establish file info
          if (message == 'AckCom') {
            transTimeout.complete(); // finishing last timeout timer

            _socket.write('$fileName:$fileSize');

            transTimeout = Completer(); // starting another timeout timer

            // on timeout of defined timer
            transTimeout.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                // updating progress indecator to error
                Provider.of<FilesProvider>(publicContext, listen: false)
                    .updatePrecentage(file, -1);
                sendingFile.complete();
              },
            );
          }
          // got file info, send file
          else if (message == 'AckFle') {
            Provider.of<FilesProvider>(publicContext, listen: false)
                .updatePrecentage(file, 0.001);

            _socket.add(file.readAsBytesSync()); // sending file
          }
          // unknown or Inv- error
          else if (message.contains('Inv')) {
            print('Error : $message');

            // updating progress indecator to error
            Provider.of<FilesProvider>(publicContext, listen: false)
                .updatePrecentage(file, -1);
            sendingFile.complete(); // stopping current file transfer
          }
          // updating on file progress
          else if (message.contains('GOT')) {
            transTimeout.complete(); // canceling the last timeout timer
            transTimeout = Completer(); // creating a new timeout timer

            // updating uploaded precentage according to message from pc
            Provider.of<FilesProvider>(publicContext, listen: false)
                .updatePrecentage(file, double.parse(message.split(' ')[1]));

            // on timeout of defined timer
            transTimeout.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                // updating progress indecator to error
                Provider.of<FilesProvider>(publicContext, listen: false)
                    .updatePrecentage(file, -1);
                sendingFile.complete();
              },
            );
          }
          // finished getting file
          if (message.contains('Fin')) {
            print('File passed successful');

            transTimeout.complete(); // finishing the timeout timer
            sendingFile.complete(); // finishing this file's transfer

            Provider.of<FilesProvider>(publicContext, listen: false)
                .updatePrecentage(file, 1);
          }
        },
      );
      return true; // created connection successfuly
    }
    return false; // failed to create connection
  }

  Future<void> sendFiles(List<File> files, BuildContext context) async {
    _isSending = true;
    notifyListeners();

    for (File curFile in files) {
      // making sure file exists (not deleted after selected)
      if (!curFile.existsSync()) {
        Provider.of<FilesProvider>(context, listen: false)
            .updatePrecentage(file, -1); // shows error on transfer
        continue;
      }
      sendingFile = Completer();
      transTimeout = Completer();

      // setting all variables needed for transfer
      file = curFile;
      fileName = curFile.path.split('/').last;
      fileSize = curFile.lengthSync();

      _socket.write('S');

      // on timeout of defined timer
      await transTimeout.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // move to next file
          Provider.of<FilesProvider>(context, listen: false)
              .updatePrecentage(file, -1); // error on file
          sendingFile.complete(); // the app wil continue to the next file
        },
      );

      await sendingFile.future;
    }

    // TODO : maybe move the alert to another file for more readable code
    // TODO : complete alert dialog
    if (Provider.of<FilesProvider>(context, listen: false)
        .progressList
        .contains(-1)) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Some files were not transfered"),
          content: const Text(
              "The files may have been deleted by the time you transfered them or the connection with your computer ended"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK")),
            // TODO : add "try again" button (?)
            // TODO : add "reconnect to pc" button/ auto check pc connection
          ],
        ),
      );
    }

    _isSending = false;
  }

  void disconnect() {
    _socket.write('Q');
    _socket.close();
    _isSending = false;
  }
}
