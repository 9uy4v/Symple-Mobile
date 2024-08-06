import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';

class SocketProvider with ChangeNotifier {
  late Socket _socket;
  late String _serverIp;
  late int _serverPort;

  bool _isSending = false;

  bool get isSending => _isSending;

  Future<bool> handleCode(String code) async {
    // TO DO : add code verification here
    _serverIp = code.split(':')[0];
    _serverPort = int.parse(code.split(':')[1]);

    // checks if can connect
    if (await _createConnection()) {
      _socket.close();
      return true;
    } else {
      return false;
    }
  }

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

  void sendFiles(List<File> files) async {
    _isSending = true;
    notifyListeners();

    for (File file in files) {
      final Completer sendingFile = Completer();

      // checking if can connect right now, if not returns.
      if (!await _createConnection()) {
        return;
      }

      // making sure file exists (not deleted affter selected)
      if (!file.existsSync()) {
        continue;
        // TO DO : show alert about file not found and therefore not sent
      }
      _socket.write('S');

      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync();

      _socket.listen(
        (data) {
          final message = String.fromCharCodes(data);
          debugPrint('Recived : $message');

          if (message == 'AckCom') {
            _socket.write('$fileName:$fileSize');
          } else if (message == 'AckFile') {
            _socket.add(file.readAsBytesSync());
          } else if (message == 'Fin') {
            print('File passed successful');
            sendingFile.complete();
            _socket.close();
          } else {
            print('Error : $message');
          }
        },
      );

      await sendingFile.future;
    }

    _isSending = false;
    files.clear();
    notifyListeners();
  }
}
