import 'dart:convert';

class DeviceProfile {
  const DeviceProfile({
    required this.id,
    required this.name,
    required this.app,
  });

  final String id;
  final String name;
  final String app;

  Map<String, dynamic> toJson() => {
        'app': app,
        'id': id,
        'name': name,
      };

  String toQrPayload() => jsonEncode(toJson());

  static DeviceProfile? fromQrPayload(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return null;
      if (data['app'] != 'quickshare') return null;
      final id = data['id'] as String?;
      final name = data['name'] as String?;
      if (id == null || name == null) return null;
      return DeviceProfile(id: id, name: name, app: 'quickshare');
    } on FormatException {
      return null;
    }
  }
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
