import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// riverpod refrance to regular provider for access without context
final filesRiverProvider = ChangeNotifierProvider<FilesProvider>(
  (ref) => FilesProvider(),
);

class FilesProvider with ChangeNotifier {
  // TO DO : consider making a lot of files with the file extention  built into the name
  //          for easy addition and change of icons for individual file extentions
  final Map<String, String> _fileIconsPath = {
    'mp3': 'assets/icons/audio.svg', // audio
    'aiff': 'assets/icons/audio.svg', // audio
    'wav': 'assets/icons/audio.svg', // audio
    'jpeg': 'assets/icons/image.svg', // images (and gif)
    'jpg': 'assets/icons/image.svg', // images (and gif)
    'png': 'assets/icons/image.svg', // images (and gif)
    'tiff': 'assets/icons/image.svg', // images (and gif)
    'gif': 'assets/icons/image.svg', // images (and gif)
    'avi': 'assets/icons/video.svg', // video
    'mp4': 'assets/icons/video.svg', // video
    'wmv': 'assets/icons/video.svg', // video
    'html': 'assets/icons/http.svg', // internet
    'http': 'assets/icons/http.svg', // internet
    'doc': 'assets/icons/word.svg', // word documents
    'docx': 'assets/icons/word.svg', // word documents
    'txt': 'assets/icons/document.svg', // text documents
    'eml': 'assets/icons/email.svg', // emails
    'exe': 'assets/icons/exe.svg', // exe
    'pdf': 'assets/icons/pdf.svg', // pdf
    'pptx': 'assets/icons/powerpoint.svg', // slideshows
    'zip': 'assets/icons/zip.svg', // zip
  };
  final List<File> _selectedFiles = [];
  late List<double> _uploadedPrecentage;

  List<File> get files => _selectedFiles;
  List<double> get progressList => _uploadedPrecentage;

  String getFileIconPath(String fileExtention) {
    if (!_fileIconsPath.containsKey(fileExtention)) {
      return 'assets/icons/file.svg';
    }
    return _fileIconsPath[fileExtention]!;
  }

  void createPrecentageList() {
    _uploadedPrecentage = List<double>.generate(_selectedFiles.length, (i) => 0);
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
