import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../models/discovered_receiver.dart';
import '../../models/transfer_endpoint.dart';
import '../../models/transfer_transport_kind.dart';
import '../../models/upload_cancel_token.dart';
import '../../models/upload_failure_state.dart';
import 'android_receive_service.dart';
import 'local_share_server.dart';
import 'mdns_discovery_service.dart';
import 'multipeer_service.dart';
import 'network_info_service.dart';
import 'transfer_client.dart';
import 'transfer_constants.dart';

class TransferService extends ChangeNotifier {
  TransferService({
    LocalShareServer? server,
    TransferClient? client,
    NetworkInfoService? networkInfo,
    MdnsDiscoveryService? mdns,
    MultipeerService? multipeer,
  })  : _server = server ?? LocalShareServer(),
        _networkInfo = networkInfo ?? NetworkInfoService(),
        _mdns = mdns ?? MdnsDiscoveryService(),
        _multipeer = multipeer ?? MultipeerService() {
    _client = client ?? TransferClient(multipeer: _multipeer);
    _multipeer.attachRequestHandler(_server);
    _subscription = _server.onFileReceived.listen((file) {
      _receivedFiles.insert(0, file);
      notifyListeners();
    });
    _mdnsPollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_mdns.isBrowsing || _multipeer.isBrowsing) {
        notifyListeners();
      }
    });
  }

  final LocalShareServer _server;
  late final TransferClient _client;
  final NetworkInfoService _networkInfo;
  final MdnsDiscoveryService _mdns;
  final MultipeerService _multipeer;

  late final StreamSubscription<ReceivedFileItem> _subscription;
  late final Timer _mdnsPollTimer;

  ReceiveServerState _state = ReceiveServerState.idle;
  TransferEndpoint? _activeEndpoint;
  String? _errorMessage;
  final List<ReceivedFileItem> _receivedFiles = [];
  UploadCancelToken? _activeUploadToken;
  bool _isUploading = false;
  UploadFailureState? _lastFailure;

  ReceiveServerState get state => _state;
  TransferEndpoint? get activeEndpoint => _activeEndpoint;
  String? get errorMessage => _errorMessage;
  List<ReceivedFileItem> get receivedFiles =>
      List.unmodifiable(_receivedFiles);
  bool get isReceiving => _state == ReceiveServerState.active;
  bool get isOfflineReceiving => _activeEndpoint?.isMultipeer ?? false;
  bool get isUploading => _isUploading;
  UploadFailureState? get lastFailure => _lastFailure;
  bool get canRetryUpload => _lastFailure != null && !_isUploading;
  bool get isBrowsingReceivers =>
      _mdns.isBrowsing || _multipeer.isBrowsing;

  List<DiscoveredReceiver> get discoveredReceivers {
    final merged = <String, DiscoveredReceiver>{};
    for (final receiver in _multipeer.peers) {
      final key =
          receiver.deviceId.isNotEmpty ? receiver.deviceId : receiver.key;
      merged.putIfAbsent(key, () => receiver);
    }
    for (final receiver in _mdns.receivers) {
      merged[receiver.deviceId.isNotEmpty ? receiver.deviceId : receiver.key] =
          receiver;
    }
    final list = merged.values.toList();
    list.sort((a, b) => a.deviceName.compareTo(b.deviceName));
    return list;
  }

  Future<void> startReceiving({
    required String deviceName,
    required String deviceId,
  }) async {
    _state = ReceiveServerState.starting;
    _errorMessage = null;
    notifyListeners();

    try {
      final ip = await _networkInfo.getWifiIPv4();
      if (ip != null) {
        _activeEndpoint = await _server.start(
          hostIp: ip,
          deviceName: deviceName,
          deviceId: deviceId,
        );
        final port = _server.boundPort;
        if (port != null) {
          await _mdns.startAdvertising(
            deviceName: deviceName,
            deviceId: deviceId,
            port: port,
          );
        }
      } else if (_multipeer.isAvailable) {
        _activeEndpoint = await _server.startOfflineSession(
          deviceName: deviceName,
          deviceId: deviceId,
        );
      } else {
        throw const TransferException(
          TransferError.receiverUnreachable,
          'Connect to Wi‑Fi or use an iOS device nearby for offline receiving.',
        );
      }

      if (_multipeer.isAvailable) {
        await _multipeer.startAdvertising(
          peerName: deviceName,
          deviceId: deviceId,
          deviceName: deviceName,
        );
      }

      await WakelockPlus.enable();
      await AndroidReceiveService.start(deviceName: deviceName);
      _state = ReceiveServerState.active;
      _errorMessage = null;
    } on Object catch (error) {
      _state = ReceiveServerState.error;
      _errorMessage = error.toString();
      _activeEndpoint = null;
      await _server.stop();
      await _mdns.stopAdvertising();
      await _multipeer.stopAdvertising();
      await WakelockPlus.disable();
      await AndroidReceiveService.stop();
    }
    notifyListeners();
  }

  Future<void> stopReceiving() async {
    await _mdns.stopAdvertising();
    await _multipeer.stopAdvertising();
    await _multipeer.disconnect();
    await _server.stop();
    await WakelockPlus.disable();
    await AndroidReceiveService.stop();
    _activeEndpoint = null;
    _state = ReceiveServerState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> startBrowsingReceivers() async {
    var changed = false;
    if (!_mdns.isBrowsing) {
      await _mdns.startBrowsing();
      changed = true;
    }
    if (_multipeer.isAvailable && !_multipeer.isBrowsing) {
      await _multipeer.startBrowsing();
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> stopBrowsingReceivers() async {
    var changed = false;
    if (_mdns.isBrowsing) {
      await _mdns.stopBrowsing();
      changed = true;
    }
    if (_multipeer.isBrowsing) {
      await _multipeer.stopBrowsing();
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<TransferEndpoint> pairWithDiscoveredReceiver({
    required DiscoveredReceiver receiver,
    required String pin,
  }) async {
    await _connectMultipeerIfNeeded(receiver.peerId, receiver.isMultipeer);

    return _client.pairWithPin(
      baseUrl: receiver.baseUrl,
      pin: pin,
      deviceName: receiver.deviceName,
      deviceId: receiver.deviceId,
      peerId: receiver.peerId,
      transport: receiver.isMultipeer
          ? TransferTransportKind.multipeer
          : TransferTransportKind.http,
    );
  }

  Future<TransferEndpoint> resolveEndpoint(TransferEndpoint endpoint) async {
    if (!endpoint.isMultipeer || endpoint.peerId.isNotEmpty) {
      return endpoint;
    }

    if (!_multipeer.isBrowsing) {
      await startBrowsingReceivers();
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      DiscoveredReceiver? peer;
      for (final receiver in _multipeer.peers) {
        if (receiver.deviceId == endpoint.deviceId) {
          peer = receiver;
          break;
        }
      }
      if (peer != null) {
        await _connectMultipeerIfNeeded(peer.peerId, true);
        return endpoint.copyWith(peerId: peer.peerId);
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    throw const TransferException(
      TransferError.receiverUnreachable,
      'Could not find the nearby offline receiver. Open Send and wait for it to appear in Nearby Receivers.',
    );
  }

  Future<void> _connectMultipeerIfNeeded(String peerId, bool isMultipeer) async {
    if (!isMultipeer) return;
    try {
      await _multipeer.connectAndWait(peerId);
    } on MultipeerException catch (error) {
      throw TransferException(
        TransferError.receiverUnreachable,
        error.message,
      );
    }
  }

  Future<bool> pingReceiver(TransferEndpoint endpoint) =>
      _client.ping(endpoint);

  Future<void> uploadFiles({
    required TransferEndpoint endpoint,
    required List<File> files,
    required List<String> names,
    void Function(UploadProgress progress)? onProgress,
    int startIndex = 0,
  }) async {
    if (_isUploading) {
      throw const TransferException(
        TransferError.uploadFailed,
        'An upload is already in progress.',
      );
    }

    final reachable = await pingReceiver(endpoint);
    if (!reachable) {
      throw TransferException(
        TransferError.receiverUnreachable,
        endpoint.isMultipeer
            ? 'Receiver is not reachable. Stay nearby, keep receiving active, and verify the PIN.'
            : 'Receiver is not reachable. Make sure both devices are on the same Wi‑Fi, receiving is active, and the PIN is correct.',
      );
    }

    final cancelToken = UploadCancelToken();
    _activeUploadToken = cancelToken;
    _isUploading = true;
    _lastFailure = null;
    notifyListeners();

    try {
      for (var i = startIndex; i < files.length; i++) {
        if (cancelToken.isCancelled) {
          throw const TransferCancelledException();
        }
        try {
          await _uploadWithRetry(
            endpoint: endpoint,
            file: files[i],
            fileName: names[i],
            cancelToken: cancelToken,
            fileIndex: i + 1,
            fileCount: files.length,
            onProgress: onProgress,
          );
        } on TransferCancelledException {
          rethrow;
        } on TransferException catch (error) {
          _lastFailure = UploadFailureState(
            endpoint: endpoint,
            files: files,
            names: names,
            failedAtIndex: i,
            message: error.message,
          );
          rethrow;
        }
      }
      _lastFailure = null;
    } on TransferCancelledException {
      rethrow;
    } finally {
      _isUploading = false;
      _activeUploadToken = null;
      notifyListeners();
    }
  }

  Future<void> retryLastUpload({
    void Function(UploadProgress progress)? onProgress,
  }) async {
    final failure = _lastFailure;
    if (failure == null || _isUploading) return;

    await uploadFiles(
      endpoint: failure.endpoint,
      files: failure.files,
      names: failure.names,
      onProgress: onProgress,
      startIndex: failure.failedAtIndex,
    );
  }

  void clearLastFailure() {
    _lastFailure = null;
    notifyListeners();
  }

  Future<void> _uploadWithRetry({
    required TransferEndpoint endpoint,
    required File file,
    required String fileName,
    required UploadCancelToken cancelToken,
    required int fileIndex,
    required int fileCount,
    void Function(UploadProgress progress)? onProgress,
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt < TransferConstants.maxUploadAttempts; attempt++) {
      if (cancelToken.isCancelled) {
        throw const TransferCancelledException();
      }
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }

      try {
        await _client.uploadFile(
          endpoint: endpoint,
          file: file,
          fileName: fileName,
          cancelToken: cancelToken,
          fileIndex: fileIndex,
          fileCount: fileCount,
          onProgress: onProgress,
        );
        return;
      } on TransferCancelledException {
        rethrow;
      } on TransferException catch (error) {
        lastError = error;
        if (error.code == TransferError.invalidSession ||
            error.code == TransferError.sessionExpired) {
          rethrow;
        }
      }
    }

    throw lastError ??
        const TransferException(
          TransferError.uploadFailed,
          'Upload failed after multiple attempts.',
        );
  }

  void cancelUpload() {
    _activeUploadToken?.cancel();
  }

  Future<void> deleteReceived(ReceivedFileItem item) async {
    _receivedFiles.remove(item);
    await _server.store.delete(item);
    notifyListeners();
  }

  void clearReceivedList() {
    _receivedFiles.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _mdnsPollTimer.cancel();
    unawaited(stopReceiving());
    unawaited(_subscription.cancel());
    unawaited(_mdns.dispose());
    unawaited(_multipeer.dispose());
    unawaited(_server.dispose());
    super.dispose();
  }
}
