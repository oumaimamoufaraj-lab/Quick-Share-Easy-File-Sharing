import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../models/share_response.dart';
import '../../models/transfer_endpoint.dart';
import '../../models/transfer_transport_kind.dart';
import 'browser_upload_page.dart';
import 'received_files_store.dart';
import 'transfer_constants.dart';

class _PendingChunkUpload {
  _PendingChunkUpload({
    required this.uploadId,
    required this.filename,
    required this.totalSize,
    required this.totalChunks,
    required this.tempFile,
  });

  final String uploadId;
  final String filename;
  final int totalSize;
  final int totalChunks;
  final File tempFile;
  final Set<int> receivedChunks = <int>{};
}

class LocalShareServer {
  LocalShareServer({ReceivedFilesStore? store})
      : _store = store ?? ReceivedFilesStore();

  final ReceivedFilesStore _store;
  final Random _random = Random.secure();
  final Map<String, _PendingChunkUpload> _pendingChunkUploads =
      <String, _PendingChunkUpload>{};
  HttpServer? _server;
  String? _token;
  String? _pin;
  String? _deviceName;
  String? _deviceId;
  TransferTransportKind _transport = TransferTransportKind.http;
  final Duration _sessionTtl = const Duration(minutes: 30);
  DateTime? _expiresAt;
  Directory? _chunkTempDir;

  final _receivedController = StreamController<ReceivedFileItem>.broadcast();

  Stream<ReceivedFileItem> get onFileReceived => _receivedController.stream;

  ReceivedFilesStore get store => _store;

  bool get isRunning => _server != null;

  bool get isSessionActive => _token != null;

  int? get boundPort => _server?.port;

  String? get token => _token;
  String? get pin => _pin;

  Future<TransferEndpoint> start({
    required String hostIp,
    required String deviceName,
    required String deviceId,
    int port = 0,
  }) async {
    await stop();

    await _beginSession(deviceName: deviceName, deviceId: deviceId);
    _transport = TransferTransportKind.http;

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    final boundPort = _server!.port;
    final baseUrl = 'http://$hostIp:$boundPort';

    _server!.listen(
      _handleRequest,
      onError: (Object error) {},
    );

    return _buildEndpoint(baseUrl: baseUrl);
  }

  Future<TransferEndpoint> startOfflineSession({
    required String deviceName,
    required String deviceId,
  }) async {
    await stop();
    await _beginSession(deviceName: deviceName, deviceId: deviceId);
    _transport = TransferTransportKind.multipeer;
    return _buildEndpoint(baseUrl: 'multipeer://$deviceId');
  }

  Future<void> _beginSession({
    required String deviceName,
    required String deviceId,
  }) async {
    _store.resetSession();
    _token = const Uuid().v4();
    _pin = _generatePin();
    _deviceName = deviceName;
    _deviceId = deviceId;
    _expiresAt = DateTime.now().add(_sessionTtl);
    _chunkTempDir = await Directory.systemTemp.createTemp('quickshare_chunks_');
  }

  TransferEndpoint _buildEndpoint({required String baseUrl}) {
    return TransferEndpoint(
      baseUrl: baseUrl,
      token: _token!,
      deviceName: _deviceName!,
      deviceId: _deviceId!,
      pin: _pin!,
      transport: _transport,
    );
  }

  String _generatePin() {
    final value = 1000 + _random.nextInt(9000);
    return value.toString();
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _token = null;
    _pin = null;
    _deviceName = null;
    _deviceId = null;
    _expiresAt = null;
    _transport = TransferTransportKind.http;
    _pendingChunkUploads.clear();
    if (_chunkTempDir != null && _chunkTempDir!.existsSync()) {
      await _chunkTempDir!.delete(recursive: true);
      _chunkTempDir = null;
    }
    _store.resetSession();
    if (server != null) {
      await server.close(force: true);
    }
  }

  bool _isSessionValid(String? token, String? pin) {
    if (_token == null || token == null || token != _token) return false;
    if (pin == null || pin != _pin) return false;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      return false;
    }
    return true;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final body = await request.fold<List<int>>(
      <int>[],
      (previous, element) => previous..addAll(element),
    );
    final response = await processRequest(
      method: request.method,
      path: request.uri.path,
      queryParameters: request.uri.queryParameters,
      body: body,
    );
    request.response.statusCode = response.statusCode;
    if (response.contentType != null) {
      request.response.headers.set('content-type', response.contentType!);
    }
    request.response.add(response.body);
    await request.response.close();
  }

  Future<ShareResponse> processRequest({
    required String method,
    required String path,
    required Map<String, String> queryParameters,
    List<int> body = const [],
  }) async {
    try {
      if (_isExpired()) {
        return ShareResponse(
          statusCode: HttpStatus.gone,
          body: utf8.encode('Session expired'),
        );
      }

      if (method == 'GET' && (path == '/' || path.isEmpty)) {
        return _buildHomePageResponse(queryParameters);
      }
      if (method == 'GET' && path == '/status') {
        return _buildStatusResponse(queryParameters);
      }
      if (method == 'GET' && path == '/discover') {
        return _buildDiscoverResponse(queryParameters);
      }
      if (method == 'POST' && path == '/upload') {
        return await _buildUploadResponse(queryParameters, body);
      }
      if (method == 'POST' && path == '/upload/chunk') {
        return await _buildUploadChunkResponse(queryParameters, body);
      }

      return ShareResponse(
        statusCode: HttpStatus.notFound,
        body: utf8.encode('Not found'),
      );
    } on Object {
      return ShareResponse(
        statusCode: HttpStatus.internalServerError,
        body: utf8.encode('Server error'),
      );
    }
  }

  bool _isExpired() =>
      _expiresAt != null && DateTime.now().isAfter(_expiresAt!);

  int get _effectiveChunkSize => _transport == TransferTransportKind.multipeer
      ? TransferConstants.multipeerChunkSizeBytes
      : TransferConstants.chunkSizeBytes;

  ShareResponse _buildStatusResponse(Map<String, String> queryParameters) {
    final token = queryParameters['token'];
    final pin = queryParameters['pin'];
    if (!_isSessionValid(token, pin)) {
      return ShareResponse(
        statusCode: HttpStatus.forbidden,
        contentType: 'application/json',
        body: utf8.encode(jsonEncode({'status': 'invalid'})),
      );
    }

    return ShareResponse(
      statusCode: HttpStatus.ok,
      contentType: 'application/json',
      body: utf8.encode(
        jsonEncode({
          'status': 'ready',
          'name': _deviceName,
          'id': _deviceId,
          'expiresAt': _expiresAt?.toIso8601String(),
          'chunkSize': _effectiveChunkSize,
          'chunkThreshold': TransferConstants.chunkThresholdBytes,
          'transport': _transport.name,
        }),
      ),
    );
  }

  ShareResponse _buildDiscoverResponse(Map<String, String> queryParameters) {
    if (_isExpired()) {
      return ShareResponse(
        statusCode: HttpStatus.gone,
        contentType: 'application/json',
        body: utf8.encode(jsonEncode({'status': 'expired'})),
      );
    }

    final pin = queryParameters['pin'];
    if (_token == null || pin == null || pin != _pin) {
      return ShareResponse(
        statusCode: HttpStatus.forbidden,
        contentType: 'application/json',
        body: utf8.encode(jsonEncode({'status': 'invalid'})),
      );
    }

    return ShareResponse(
      statusCode: HttpStatus.ok,
      contentType: 'application/json',
      body: utf8.encode(
        jsonEncode({
          'status': 'ready',
          'token': _token,
          'name': _deviceName,
          'id': _deviceId,
          'transport': _transport.name,
        }),
      ),
    );
  }

  Future<ShareResponse> _buildUploadResponse(
    Map<String, String> queryParameters,
    List<int> body,
  ) async {
    final token = queryParameters['token'];
    final pin = queryParameters['pin'];
    if (!_isSessionValid(token, pin)) {
      return ShareResponse(
        statusCode: HttpStatus.forbidden,
        body: utf8.encode('Invalid session or PIN'),
      );
    }

    final filename = queryParameters['filename'] ?? 'received_file';
    if (body.length > TransferConstants.chunkThresholdBytes) {
      return ShareResponse(
        statusCode: HttpStatus.requestEntityTooLarge,
        body: utf8.encode('File too large for single upload. Use chunked upload.'),
      );
    }

    final item = await _store.saveFromBytes(
      originalName: filename,
      bytes: body,
    );
    _receivedController.add(item);

    return ShareResponse(
      statusCode: HttpStatus.ok,
      contentType: 'application/json',
      body: utf8.encode(
        jsonEncode({
          'ok': true,
          'name': item.name,
          'size': item.size,
        }),
      ),
    );
  }

  Future<ShareResponse> _buildUploadChunkResponse(
    Map<String, String> queryParameters,
    List<int> body,
  ) async {
    final token = queryParameters['token'];
    final pin = queryParameters['pin'];
    if (!_isSessionValid(token, pin)) {
      return ShareResponse(
        statusCode: HttpStatus.forbidden,
        body: utf8.encode('Invalid session or PIN'),
      );
    }

    final uploadId = queryParameters['uploadId'];
    final chunkIndex = int.tryParse(queryParameters['chunkIndex'] ?? '');
    final totalChunks = int.tryParse(queryParameters['totalChunks'] ?? '');
    final filename = queryParameters['filename'] ?? 'received_file';
    final totalSize = int.tryParse(queryParameters['totalSize'] ?? '');

    if (uploadId == null ||
        chunkIndex == null ||
        totalChunks == null ||
        totalSize == null ||
        chunkIndex < 0 ||
        chunkIndex >= totalChunks ||
        totalChunks <= 0) {
      return ShareResponse(
        statusCode: HttpStatus.badRequest,
        body: utf8.encode('Invalid chunk parameters'),
      );
    }

    final chunkDir = _chunkTempDir ?? await Directory.systemTemp.createTemp(
      'quickshare_chunks_',
    );
    _chunkTempDir ??= chunkDir;

    var pending = _pendingChunkUploads[uploadId];
    if (pending == null) {
      final tempFile = File(p.join(chunkDir.path, '$uploadId.part'));
      if (!tempFile.existsSync()) {
        await tempFile.create(recursive: true);
        final createRaf = await tempFile.open(mode: FileMode.write);
        await createRaf.truncate(totalSize);
        await createRaf.close();
      }
      pending = _PendingChunkUpload(
        uploadId: uploadId,
        filename: filename,
        totalSize: totalSize,
        totalChunks: totalChunks,
        tempFile: tempFile,
      );
      _pendingChunkUploads[uploadId] = pending;
    }

    final offset = chunkIndex * _effectiveChunkSize;
    final raf = await pending.tempFile.open(mode: FileMode.write);
    await raf.setPosition(offset);
    await raf.writeFrom(body);
    await raf.close();
    pending.receivedChunks.add(chunkIndex);

    if (!_isChunkUploadComplete(pending)) {
      return ShareResponse(
        statusCode: HttpStatus.ok,
        contentType: 'application/json',
        body: utf8.encode(jsonEncode({'ok': true, 'complete': false})),
      );
    }

    final item = await _store.saveFromFile(
      originalName: pending.filename,
      sourcePath: pending.tempFile.path,
      size: pending.totalSize,
    );
    _pendingChunkUploads.remove(uploadId);
    if (pending.tempFile.existsSync()) {
      await pending.tempFile.delete();
    }
    _receivedController.add(item);

    return ShareResponse(
      statusCode: HttpStatus.ok,
      contentType: 'application/json',
      body: utf8.encode(
        jsonEncode({
          'ok': true,
          'complete': true,
          'name': item.name,
          'size': item.size,
        }),
      ),
    );
  }

  bool _isChunkUploadComplete(_PendingChunkUpload pending) {
    if (pending.receivedChunks.length < pending.totalChunks) return false;
    for (var i = 0; i < pending.totalChunks; i++) {
      if (!pending.receivedChunks.contains(i)) return false;
    }
    return true;
  }

  ShareResponse _buildHomePageResponse(Map<String, String> queryParameters) {
    final token = queryParameters['token'] ?? _token ?? '';
    final name = _deviceName ?? 'File Share';
    return ShareResponse(
      statusCode: HttpStatus.ok,
      contentType: 'text/html; charset=utf-8',
      body: utf8.encode(
        buildBrowserUploadPage(
          deviceName: name,
          sessionToken: token,
          chunkSize: _effectiveChunkSize,
          chunkThreshold: TransferConstants.chunkThresholdBytes,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await stop();
    await _receivedController.close();
  }
}
