import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';

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

  void sendFiles(List<File> files, BuildContext context) async {
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

          // got intentions command, establish file info and updating protocol
          if (message == 'AckCom') {
            _socket.write('$fileName:$fileSize:3');
          }
          // got updating protocol, send file
          else if (message == 'AckFile') {
            Provider.of<FilesProvider>(context, listen: false).updatePrecentage(file, 0.001);
            _socket.add(file.readAsBytesSync());
          }
          // updating on file progress
          else if (message.contains('GOT')) {
            Provider.of<FilesProvider>(context, listen: false).updatePrecentage(file, double.parse(message.split(' ')[2]) / fileSize);
            // TO DO : sort out GOT so we can get more than 3 updates :(
          }
          // finished getting file
          else if (message == 'Fin') {
            print('File passed successful');
            sendingFile.complete();
            Provider.of<FilesProvider>(context, listen: false).updatePrecentage(file, 1);
            _socket.close();
          }
          // unknown or Inv- error
          else {
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
