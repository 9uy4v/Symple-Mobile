import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:symple_mobile/main.dart';
import 'package:symple_mobile/providers/files_provider.dart';

class SocketProvider with ChangeNotifier {
  late Socket _socket;
  late String _serverIp;
  late int _serverPort;

  bool _isSending = false;

  late Completer sendingFile;
  late File file;
  late String fileName;
  late int fileSize;
  late int updateNum;

  bool get isSending => _isSending;

  // creates connection with pc
  // returns true if connection successful and false if error
  Future<bool> _createConnection() async {
    try {
      _socket = await Socket.connect(_serverIp, _serverPort);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  Future<bool> handleCode(String code) async {
    // TO DO : add code verification here
    _serverIp = code.split(':')[0];
    _serverPort = int.parse(code.split(':')[1]);

    // checks if can connect
    if (await _createConnection()) {
      _socket.listen(
        (data) {
          final message = String.fromCharCodes(data);
          debugPrint('Recived : $message');

          // got intentions command, establish file info and updating protocol
          if (message == 'AckCom') {
            _socket.write('$fileName:$fileSize:$updateNum');
          }
          // got updating protocol, send file
          else if (message == 'AckFle') {
            Provider.of<FilesProvider>(publicContext, listen: false).updatePrecentage(file, 0.001);
            _socket.add(file.readAsBytesSync());
          }
          // unknown or Inv- error
          else if (message.contains('Inv')) {
            print('Error : $message');
            // updating to error code
            Provider.of<FilesProvider>(publicContext, listen: false).updatePrecentage(file, -1);
          }
          // updating on file progress
          else if (message.contains('GOT')) {
            Provider.of<FilesProvider>(publicContext, listen: false).updatePrecentage(file, double.parse(message.split(' ')[1]) / fileSize);
          }
          // finished getting file
          if (message.contains('Fin')) {
            print('File passed successful');
            sendingFile.complete();
            Provider.of<FilesProvider>(publicContext, listen: false).updatePrecentage(file, 1);
          }
        },
      );
      return true;
    } else {
      return false;
    }
  }

  void sendFiles(List<File> files, BuildContext context) async {
    _isSending = true;
    notifyListeners();

    for (File curFile in files) {
      // making sure file exists (not deleted after selected)
      if (!curFile.existsSync()) {
        continue;
        // TO DO : show alert about file not found and therefore not sent
      }
      sendingFile = Completer();

      file = curFile;
      // setting all variables needed for transfer
      fileName = curFile.path.split('/').last;
      fileSize = curFile.lengthSync();
      // TO DO : hardcode this on the python server side :
      updateNum = 3 * (fileSize / 1000000).ceil(); // 3 updates per megabyte

      _socket.write('S');

      await sendingFile.future;
    }

    _isSending = false;
    files.clear();
    notifyListeners();
  }
}
