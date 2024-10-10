import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symple_mobile/screens/splash_screen.dart';

class FilesProvider with ChangeNotifier {
  final List<File> _selectedFiles = [];
  late List<double> _uploadedPrecentage;

  List<File> get files => _selectedFiles;
  List<double> get progressList => _uploadedPrecentage;

  String getFileIconPath(String fileExtention) {
    try {
      SvgPicture.asset('assets/icons/$fileExtention.svg');
      return 'assets/icons/$fileExtention.svg';
    } catch (e) {
      return 'assets/icons/file.svg';
    }
  }

  void clearFilesList() {
    _selectedFiles.clear();
  }

  void createPrecentageList() {
    _uploadedPrecentage = List<double>.generate(_selectedFiles.length, (i) => 0);
  }

  void updatePrecentage(File file, double precentage) {
    _uploadedPrecentage[_selectedFiles.indexOf(file)] = precentage;
    notifyListeners();
  }

  void selectFiles(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      onFileLoading: (p0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ));
      },
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

  void removeFileByIndex(int index) {
    _selectedFiles.removeAt(index);
    notifyListeners();
  }

  String getFileSizeString(File file) {
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + suffixes[i];
  }
}
