import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilesProvider with ChangeNotifier {
  final List<File> _selectedFiles = [];
  late List<double> _uploadedPrecentage;

  List<File> get files => _selectedFiles;
  List<double> get progressList => _uploadedPrecentage;

  void createPrecentageList() {
    _uploadedPrecentage = List<double>.generate(_selectedFiles.length, (i) => 0);
    notifyListeners(); // TO DO : maybe not needed
  }

  void updatePrecentage(File file, double precentage) {
    _uploadedPrecentage[_selectedFiles.indexOf(file)] = precentage;
    notifyListeners();
  }

  void selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      // adding files to array if not already in it
      _selectedFiles.addAll(result.paths
          .where(
            (element) => !_selectedFiles.contains(File(element!)),
          )
          .map(
            (e) => File(e!),
          )
          .toList());

      createPrecentageList();
      notifyListeners();
    }
  }

  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    notifyListeners();
  }
}
