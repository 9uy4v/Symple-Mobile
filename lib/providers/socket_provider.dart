import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';

class SocketProvider with ChangeNotifier {
  late Socket socket;
  late String serverIp;
  late int serverPort;

  Future<bool> handleCode(String code) async {
    // TO DO : add code verification here
    serverIp = code.split(':')[0];
    serverPort = int.parse(code.split(':')[1]);

    // checks if can connect
    if (await _createConnection()) {
      socket.close();
      return true;
    } else {
      return false;
    }
  }

  // creates connection with pc
  // returns true if connection successful and false if error
  Future<bool> _createConnection() async {
    try {
      socket = await Socket.connect(serverIp, serverPort);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  //  convert file to binary data to send to pc
  // var bytes = await File('filename').readAsBytes();
  void sendFiles(List<File> files) async {
    for (File file in files) {
      final Completer _sendingFile = new Completer();

      // checking if can connect right now, if not returns.
      if (!await _createConnection()) {
        return;
      }

      if (!file.existsSync()) {
        continue;
      }
      socket.write('S');

      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync();

      socket.listen(
        (data) {
          final message = String.fromCharCodes(data);
          debugPrint('Recived : $message');

          if (message == 'AckCom') {
            socket.write('$fileName:$fileSize');
          } else if (message == 'AckFile') {
            socket.add(file.readAsBytesSync());
          } else if (message == 'Fin') {
            print('File passed successful');
            _sendingFile.complete();
            socket.close();
          } else {
            print('Error : $message');
          }
        },
      );

      await _sendingFile.future;
    }
  }
}
