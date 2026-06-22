import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/share_response.dart';
import '../../models/transfer_endpoint.dart';
import '../../models/transfer_transport_kind.dart';
import '../../models/upload_cancel_token.dart';
import 'multipeer_service.dart';
import 'transfer_constants.dart';

class TransferClient {
  const TransferClient({MultipeerService? multipeer})
      : _multipeer = multipeer;

  final MultipeerService? _multipeer;

  Future<bool> ping(TransferEndpoint endpoint) async {
    try {
      if (endpoint.isMultipeer) {
        final response = await _sendMultipeer(
          endpoint: endpoint,
          method: 'GET',
          path: '/status',
          query: {
            'token': endpoint.token,
            'pin': endpoint.pin,
          },
        );
        if (response.statusCode != HttpStatus.ok) return false;
        final data = jsonDecode(utf8.decode(response.body));
        return data is Map && data['status'] == 'ready';
      }

      final response = await http
          .get(Uri.parse(endpoint.statusUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body);
      return data is Map && data['status'] == 'ready';
    } on Object {
      return false;
    }
  }

  Future<TransferEndpoint> pairWithPin({
    required String baseUrl,
    required String pin,
    String? deviceName,
    String? deviceId,
    String? peerId,
    TransferTransportKind transport = TransferTransportKind.http,
  }) async {
    if (transport == TransferTransportKind.multipeer) {
      final multipeer = _multipeer;
      if (multipeer == null || peerId == null || peerId.isEmpty) {
        throw const TransferException(
          TransferError.receiverUnreachable,
          'Multipeer receiver is not available.',
        );
      }

      final response = await multipeer.sendRequest(
        peerId: peerId,
        method: 'GET',
        path: '/discover',
        query: {'pin': pin},
      );
      return _endpointFromDiscoverResponse(
        response: response,
        baseUrl: baseUrl,
        pin: pin,
        deviceName: deviceName,
        deviceId: deviceId,
        peerId: peerId,
        transport: TransferTransportKind.multipeer,
      );
    }

    final uri = Uri.parse(baseUrl).replace(
      path: '/discover',
      queryParameters: {'pin': pin},
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    return _endpointFromDiscoverResponse(
      response: ShareResponse(
        statusCode: response.statusCode,
        contentType: response.headers['content-type'],
        body: response.bodyBytes,
      ),
      baseUrl: baseUrl,
      pin: pin,
      deviceName: deviceName,
      deviceId: deviceId,
      peerId: peerId ?? '',
      transport: TransferTransportKind.http,
    );
  }

  TransferEndpoint _endpointFromDiscoverResponse({
    required ShareResponse response,
    required String baseUrl,
    required String pin,
    String? deviceName,
    String? deviceId,
    required String peerId,
    required TransferTransportKind transport,
  }) {
    if (response.statusCode == HttpStatus.forbidden) {
      throw const TransferException(
        TransferError.invalidSession,
        'Wrong PIN. Check the code shown on the receiver.',
      );
    }
    if (response.statusCode == HttpStatus.gone) {
      throw const TransferException(
        TransferError.sessionExpired,
        'Receive session expired. Ask the receiver to start again.',
      );
    }
    if (response.statusCode != HttpStatus.ok) {
      throw TransferException(
        TransferError.receiverUnreachable,
        'Could not reach receiver (${response.statusCode}).',
      );
    }

    final data = jsonDecode(utf8.decode(response.body));
    if (data is! Map || data['status'] != 'ready') {
      throw const TransferException(
        TransferError.receiverUnreachable,
        'Receiver is not ready.',
      );
    }

    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const TransferException(
        TransferError.receiverUnreachable,
        'Receiver did not return a valid session.',
      );
    }

    return TransferEndpoint(
      baseUrl: baseUrl.replaceAll(RegExp(r'/+$'), ''),
      token: token,
      pin: pin,
      deviceName: data['name'] as String? ?? deviceName ?? 'Device',
      deviceId: data['id'] as String? ?? deviceId ?? '',
      transport: transport,
      peerId: peerId,
    );
  }

  Future<void> uploadFile({
    required TransferEndpoint endpoint,
    required File file,
    required String fileName,
    UploadCancelToken? cancelToken,
    void Function(UploadProgress progress)? onProgress,
    int fileIndex = 0,
    int fileCount = 1,
  }) async {
    final length = await file.length();
    final useChunked = length > TransferConstants.chunkThresholdBytes ||
        (endpoint.isMultipeer &&
            length > TransferConstants.multipeerChunkSizeBytes);
    if (useChunked) {
      await _uploadChunked(
        endpoint: endpoint,
        file: file,
        fileName: fileName,
        length: length,
        cancelToken: cancelToken,
        onProgress: onProgress,
        fileIndex: fileIndex,
        fileCount: fileCount,
      );
      return;
    }

    await _uploadSingle(
      endpoint: endpoint,
      file: file,
      fileName: fileName,
      length: length,
      cancelToken: cancelToken,
      onProgress: onProgress,
      fileIndex: fileIndex,
      fileCount: fileCount,
    );
  }

  Future<void> _uploadSingle({
    required TransferEndpoint endpoint,
    required File file,
    required String fileName,
    required int length,
    UploadCancelToken? cancelToken,
    void Function(UploadProgress progress)? onProgress,
    required int fileIndex,
    required int fileCount,
  }) async {
    if (endpoint.isMultipeer) {
      final bytes = await file.readAsBytes();
      _throwIfCancelled(cancelToken);
      final response = await _sendMultipeer(
        endpoint: endpoint,
        method: 'POST',
        path: '/upload',
        query: {
          'token': endpoint.token,
          'pin': endpoint.pin,
          'filename': fileName,
        },
        body: bytes,
      );
      _ensureShareSuccess(response);
      onProgress?.call(
        UploadProgress(
          sent: length,
          total: length,
          fileName: fileName,
          fileIndex: fileIndex,
          fileCount: fileCount,
        ),
      );
      return;
    }

    final uri = Uri.parse(endpoint.uploadUrlFor(fileName));
    final client = http.Client();
    final request = http.StreamedRequest('POST', uri);

    var sent = 0;
    try {
      await for (final chunk in file.openRead()) {
        _throwIfCancelled(cancelToken);
        sent += chunk.length;
        request.sink.add(chunk);
        onProgress?.call(
          UploadProgress(
            sent: sent,
            total: length,
            fileName: fileName,
            fileIndex: fileIndex,
            fileCount: fileCount,
          ),
        );
      }
      await request.sink.close();
      _throwIfCancelled(cancelToken);

      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(minutes: 10)),
      );
      _ensureHttpSuccess(response);
    } finally {
      client.close();
    }
  }

  Future<void> _uploadChunked({
    required TransferEndpoint endpoint,
    required File file,
    required String fileName,
    required int length,
    UploadCancelToken? cancelToken,
    void Function(UploadProgress progress)? onProgress,
    required int fileIndex,
    required int fileCount,
  }) async {
    final uploadId = const Uuid().v4();
    final chunkSize = endpoint.isMultipeer
        ? TransferConstants.multipeerChunkSizeBytes
        : TransferConstants.chunkSizeBytes;
    final totalChunks = (length + chunkSize - 1) ~/ chunkSize;
    final client = http.Client();

    try {
      for (var chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
        _throwIfCancelled(cancelToken);

        final offset = chunkIndex * chunkSize;
        final end = min(offset + chunkSize, length);
        final chunkLength = end - offset;

        final raf = await file.open();
        await raf.setPosition(offset);
        final bytes = await raf.read(chunkLength);
        await raf.close();

        if (endpoint.isMultipeer) {
          final response = await _sendMultipeer(
            endpoint: endpoint,
            method: 'POST',
            path: '/upload/chunk',
            query: {
              'token': endpoint.token,
              'pin': endpoint.pin,
              'uploadId': uploadId,
              'chunkIndex': '$chunkIndex',
              'totalChunks': '$totalChunks',
              'filename': fileName,
              'totalSize': '$length',
            },
            body: bytes,
          );
          _ensureShareSuccess(response);
        } else {
          final uri = Uri.parse(
            endpoint.chunkUrlFor(
              uploadId: uploadId,
              chunkIndex: chunkIndex,
              totalChunks: totalChunks,
              filename: fileName,
              totalSize: length,
            ),
          );

          final response = await client
              .post(
                uri,
                body: bytes,
                headers: const {'Content-Type': 'application/octet-stream'},
              )
              .timeout(const Duration(minutes: 5));

          _ensureHttpSuccess(response);
        }

        onProgress?.call(
          UploadProgress(
            sent: end,
            total: length,
            fileName: fileName,
            fileIndex: fileIndex,
            fileCount: fileCount,
          ),
        );
      }
    } finally {
      client.close();
    }
  }

  Future<ShareResponse> _sendMultipeer({
    required TransferEndpoint endpoint,
    required String method,
    required String path,
    required Map<String, String> query,
    List<int> body = const [],
  }) async {
    final multipeer = _multipeer;
    if (multipeer == null || endpoint.peerId.isEmpty) {
      throw const TransferException(
        TransferError.receiverUnreachable,
        'Multipeer connection is not available.',
      );
    }
    return multipeer.sendRequest(
      peerId: endpoint.peerId,
      method: method,
      path: path,
      query: query,
      body: body,
    );
  }

  void _throwIfCancelled(UploadCancelToken? cancelToken) {
    if (cancelToken?.isCancelled ?? false) {
      throw const TransferCancelledException();
    }
  }

  void _ensureHttpSuccess(http.Response response) {
    _ensureStatusSuccess(
      response.statusCode,
      response.body,
    );
  }

  void _ensureShareSuccess(ShareResponse response) {
    _ensureStatusSuccess(
      response.statusCode,
      utf8.decode(response.body),
    );
  }

  void _ensureStatusSuccess(int statusCode, String body) {
    if (statusCode == HttpStatus.forbidden) {
      throw const TransferException(
        TransferError.invalidSession,
        'Invalid session or PIN. Scan the QR code again.',
      );
    }
    if (statusCode == HttpStatus.gone) {
      throw const TransferException(
        TransferError.sessionExpired,
        'Receive session expired. Ask the receiver to start again.',
      );
    }
    if (statusCode == HttpStatus.requestEntityTooLarge) {
      throw const TransferException(
        TransferError.fileTooLarge,
        'File is too large for a single upload.',
      );
    }
    if (statusCode != HttpStatus.ok) {
      throw TransferException(
        TransferError.uploadFailed,
        'Upload failed ($statusCode): $body',
      );
    }

    try {
      final data = jsonDecode(body);
      if (data is! Map || data['ok'] != true) {
        throw const TransferException(
          TransferError.uploadFailed,
          'Upload rejected by receiver',
        );
      }
    } on FormatException {
      // Chunk responses and legacy bodies are fine if status is 200.
    }
  }
}

enum TransferError {
  invalidSession,
  sessionExpired,
  receiverUnreachable,
  uploadFailed,
  fileTooLarge,
}

class TransferException implements Exception {
  const TransferException(this.code, this.message);

  final TransferError code;
  final String message;

  @override
  String toString() => message;
}

class TransferCancelledException implements Exception {
  const TransferCancelledException();

  @override
  String toString() => 'Upload cancelled';
}
