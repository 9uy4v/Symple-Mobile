import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';

class SocketProvider with ChangeNotifier {
  late RawSocket _socket;
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
      _socket = await RawSocket.connect(_serverIp, _serverPort);
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
      // checking if can connect right now, if not returns.
      if (!await _createConnection()) {
        return;
      }

      // making sure file exists (not deleted affter selected)
      if (!file.existsSync()) {
        continue;
        // TO DO : show alert about file not found and therefore not sent
      }
      _socket.write(utf8.encode('S'));

      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync();

      final fileInfo = '$fileName:$fileSize:3'; // TO DO : set update number

      _socket.write(utf8.encode('${fileInfo.length.toString().padLeft(3, '0')}$fileInfo'));

      Provider.of<FilesProvider>(context, listen: false).updatePrecentage(file, 0.001);

      _socket.write(file.readAsBytesSync());

      while (_socket.available() == 0) {
        // do nothing
      }
      print('ihave');
      final data = _socket.read(3); // getting GOT message length

      while (String.fromCharCodes(data!) != 'Fin') {
        late int len;
        // getting GOT message length
        try {
          len = int.parse(String.fromCharCodes(data));
        } catch (e) {
          debugPrint('ERROR : ${String.fromCharCodes(data)}');
          break;
        }

        // reading and validating GOT message
        final gotMessage = _socket.read(len);
        if (gotMessage != null && String.fromCharCodes(gotMessage).contains('GOT')) {
          // adding to progress bar
          Provider.of<FilesProvider>(context, listen: false)
              .updatePrecentage(file, double.parse(String.fromCharCodes(gotMessage).split(' ')[2]) / fileSize);
        } else {
          debugPrint('ERROR CODE or null : ${String.fromCharCodes(gotMessage!)}');
        }
      }

      print('File passed successful');
      Provider.of<FilesProvider>(context, listen: false).updatePrecentage(file, 1);
      _socket.close();
    }

    _isSending = false;
    files.clear();
    notifyListeners();
  }
}
