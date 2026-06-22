import 'dart:convert';

import '../../models/transfer_transport_kind.dart';

/// Describes a receiver that can accept file uploads on the local network.
class TransferEndpoint {
  const TransferEndpoint({
    required this.baseUrl,
    required this.token,
    required this.deviceName,
    required this.deviceId,
    required this.pin,
    this.transport = TransferTransportKind.http,
    this.peerId = '',
  });

  final String baseUrl;
  final String token;
  final String deviceName;
  final String deviceId;
  final String pin;
  final TransferTransportKind transport;
  final String peerId;

  bool get isMultipeer => transport == TransferTransportKind.multipeer;

  String get statusUrl =>
      '$baseUrl/status?token=$token&pin=${Uri.encodeComponent(pin)}';

  String uploadUrlFor(String filename) =>
      '$baseUrl/upload?token=$token&pin=${Uri.encodeComponent(pin)}&filename=${Uri.encodeComponent(filename)}';

  String chunkUrlFor({
    required String uploadId,
    required int chunkIndex,
    required int totalChunks,
    required String filename,
    required int totalSize,
  }) {
    final query = {
      'token': token,
      'pin': pin,
      'uploadId': uploadId,
      'chunkIndex': '$chunkIndex',
      'totalChunks': '$totalChunks',
      'filename': filename,
      'totalSize': '$totalSize',
    };
    return Uri.parse(baseUrl).replace(
      path: '/upload/chunk',
      queryParameters: query,
    ).toString();
  }

  String toQrPayload() => jsonEncode({
        'app': 'quickshare',
        'v': 2,
        'url': baseUrl,
        'token': token,
        'pin': pin,
        'name': deviceName,
        'id': deviceId,
        if (isMultipeer) 'transport': 'multipeer',
        if (peerId.isNotEmpty) 'peerId': peerId,
      });

  static TransferEndpoint? fromQrPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return _fromUrl(Uri.parse(trimmed));
    }
    if (trimmed.startsWith('multipeer://')) {
      return _fromMultipeerUrl(Uri.parse(trimmed));
    }

    try {
      final data = jsonDecode(trimmed);
      if (data is! Map<String, dynamic>) return null;
      if (data['app'] != 'quickshare') return null;

      final url = data['url'] as String?;
      final token = data['token'] as String?;
      final name = data['name'] as String? ?? 'Device';
      final id = data['id'] as String? ?? '';
      final pin = data['pin'] as String? ?? '';
      if (url == null || token == null || pin.isEmpty) return null;

      final transport = data['transport'] == 'multipeer'
          ? TransferTransportKind.multipeer
          : TransferTransportKind.http;

      return TransferEndpoint(
        baseUrl: url.replaceAll(RegExp(r'/+$'), ''),
        token: token,
        deviceName: name,
        deviceId: id,
        pin: pin,
        transport: transport,
        peerId: data['peerId'] as String? ?? '',
      );
    } on FormatException {
      return null;
    }
  }

  static TransferEndpoint? _fromUrl(Uri uri) {
    final token = uri.queryParameters['token'];
    final pin = uri.queryParameters['pin'];
    if (token == null || pin == null || pin.isEmpty) return null;
    final name = uri.queryParameters['name'] ?? 'Device';
    final id = uri.queryParameters['id'] ?? '';
    final base = uri.replace(
      path: '',
      query: null,
      fragment: null,
    );
    return TransferEndpoint(
      baseUrl: '${base.scheme}://${base.host}:${base.port}',
      token: token,
      deviceName: name,
      deviceId: id,
      pin: pin,
    );
  }

  static TransferEndpoint? _fromMultipeerUrl(Uri uri) {
    final token = uri.queryParameters['token'];
    final pin = uri.queryParameters['pin'];
    if (token == null || pin == null || pin.isEmpty) return null;
    final name = uri.queryParameters['name'] ?? 'Device';
    final id = uri.queryParameters['id'] ?? uri.host;
    return TransferEndpoint(
      baseUrl: 'multipeer://$id',
      token: token,
      deviceName: name,
      deviceId: id,
      pin: pin,
      transport: TransferTransportKind.multipeer,
      peerId: uri.queryParameters['peerId'] ?? '',
    );
  }

  TransferEndpoint copyWith({
    String? token,
    String? pin,
    String? peerId,
    TransferTransportKind? transport,
  }) {
    return TransferEndpoint(
      baseUrl: baseUrl,
      token: token ?? this.token,
      deviceName: deviceName,
      deviceId: deviceId,
      pin: pin ?? this.pin,
      transport: transport ?? this.transport,
      peerId: peerId ?? this.peerId,
    );
  }
}

class ReceivedFileItem {
  const ReceivedFileItem({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.receivedAt,
  });

  final String id;
  final String name;
  final String path;
  final int size;
  final DateTime receivedAt;
}

enum ReceiveServerState {
  idle,
  starting,
  active,
  error,
}

class UploadProgress {
  const UploadProgress({
    required this.sent,
    required this.total,
    required this.fileName,
    required this.fileIndex,
    required this.fileCount,
  });

  final int sent;
  final int total;
  final String fileName;
  final int fileIndex;
  final int fileCount;

  double get fraction => total == 0 ? 0 : sent / total;
}
