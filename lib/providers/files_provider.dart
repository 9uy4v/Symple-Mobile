import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilesProvider with ChangeNotifier {
  final List<File> _selectedFiles = [File('c/h/gming.png')];

  List<File> get files => _selectedFiles;

  void selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      _selectedFiles.addAll(result.paths.map((path) => File(path!)).toList());
      notifyListeners();
    }
  }
}
