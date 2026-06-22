import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/transfer_endpoint.dart';

class ReceivedFilesStore {
  Directory? _directory;
  final Set<String> _displayNamesUsed = <String>{};

  Future<Directory> get directory async {
    if (_directory != null) return _directory!;
    final docs = await getApplicationDocumentsDirectory();
    _directory = Directory(p.join(docs.path, 'received'));
    if (!_directory!.existsSync()) {
      await _directory!.create(recursive: true);
    }
    return _directory!;
  }

  void resetSession() => _displayNamesUsed.clear();

  String resolveUniqueDisplayName(String originalName) {
    final safeName = _sanitizeFileName(originalName);
    if (!_displayNamesUsed.contains(safeName)) {
      _displayNamesUsed.add(safeName);
      return safeName;
    }

    final ext = p.extension(safeName);
    final stem = p.basenameWithoutExtension(safeName);
    var counter = 1;
    while (true) {
      final candidate = ext.isEmpty
          ? '$stem ($counter)'
          : '$stem ($counter)$ext';
      if (!_displayNamesUsed.contains(candidate)) {
        _displayNamesUsed.add(candidate);
        return candidate;
      }
      counter++;
    }
  }

  Future<ReceivedFileItem> saveFromBytes({
    required String originalName,
    required List<int> bytes,
  }) async {
    final displayName = resolveUniqueDisplayName(originalName);
    final dir = await directory;
    final id = const Uuid().v4();
    final storedName = '${id}_${_sanitizeFileName(displayName)}';
    final file = File(p.join(dir.path, storedName));
    await file.writeAsBytes(bytes, flush: true);

    return ReceivedFileItem(
      id: id,
      name: displayName,
      path: file.path,
      size: bytes.length,
      receivedAt: DateTime.now(),
    );
  }

  Future<ReceivedFileItem> saveFromFile({
    required String originalName,
    required String sourcePath,
    required int size,
  }) async {
    final displayName = resolveUniqueDisplayName(originalName);
    final dir = await directory;
    final id = const Uuid().v4();
    final storedName = '${id}_${_sanitizeFileName(displayName)}';
    final destination = File(p.join(dir.path, storedName));
    await File(sourcePath).copy(destination.path);

    return ReceivedFileItem(
      id: id,
      name: displayName,
      path: destination.path,
      size: size,
      receivedAt: DateTime.now(),
    );
  }

  Future<void> delete(ReceivedFileItem item) async {
    final file = File(item.path);
    if (file.existsSync()) {
      await file.delete();
    }
    _displayNamesUsed.remove(item.name);
  }

  String _sanitizeFileName(String name) {
    final base = p.basename(name).replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return base.isEmpty ? 'file' : base;
  }
}
