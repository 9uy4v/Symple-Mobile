import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class SocketProvider with ChangeNotifier {
  late Socket socket;

  // creates connection with pc
  // returns true if connection successful and flase if error
  Future<bool> createConnection(String code) async {
    final serverIp = code.split(':')[0];
    final serverPort = code.split(':')[1];

    try {
      socket = await Socket.connect(serverIp, int.parse(serverPort));
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }

  //  convert file to binary data to send to pc
  // var bytes = await File('filename').readAsBytes();
  void sendFiles(List<File> files) {
    for (File file in files) {
      if (!file.existsSync()) {
        continue;
      }
      socket.write('S');

      final fileName = file.path.split('/').last;
      final fileSize = file.lengthSync();
      socket.write('$fileName:$fileSize');

      socket.listen(
        (data) {
          debugPrint('Got file data AKC (ack2) : ${String.fromCharCodes(data)}');
        },
      );

      socket.write(file.readAsBytesSync());
    }
  }
}
