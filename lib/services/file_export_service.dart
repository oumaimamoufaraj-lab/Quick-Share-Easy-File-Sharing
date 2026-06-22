import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileExportService {
  const FileExportService();

  static const _maxSaveBytes = 15 * 1024 * 1024;

  Future<bool> saveToFiles({
    required String sourcePath,
    required String fileName,
  }) async {
    final file = File(sourcePath);
    if (!file.existsSync()) return false;

    final length = await file.length();
    if (length > _maxSaveBytes) return false;

    final bytes = await file.readAsBytes();
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save to Files',
      fileName: fileName,
      bytes: bytes,
    );
    return savedPath != null;
  }
}
