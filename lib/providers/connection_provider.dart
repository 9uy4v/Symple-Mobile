import 'package:flutter/material.dart';
import 'dart:io';

class ConnectionProvider with ChangeNotifier {
  late SecureSocket socket;

  // creates connection with pc
  // returns true if connection successful and flase if error
  Future<bool> createConnection(String code) async {
    final serverIp = code.split(':')[0];
    final serverPort = code.split(':')[1];

    try {
      socket = await SecureSocket.connect(serverIp, serverPort as int);
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }

    return true;
  }
}
