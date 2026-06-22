import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/discovered_receiver.dart';
import '../../models/share_response.dart';
import '../../models/transfer_transport_kind.dart';
import 'local_share_server.dart';

class MultipeerPeerEvent {
  const MultipeerPeerEvent({
    required this.type,
    required this.peerId,
    this.deviceName = '',
    this.deviceId = '',
  });

  final String type;
  final String peerId;
  final String deviceName;
  final String deviceId;
}

class MultipeerService {
  MultipeerService();

  static const _methodChannel =
      MethodChannel('com.quickshare.easyfilesharing/multipeer');
  static const _eventChannel =
      EventChannel('com.quickshare.easyfilesharing/multipeer/events');

  final Map<String, DiscoveredReceiver> _peers = {};
  final Map<String, Completer<void>> _connectionWaiters = {};
  StreamSubscription<dynamic>? _eventSub;
  LocalShareServer? _requestHandler;
  bool _isBrowsing = false;
  bool _isAdvertising = false;

  bool get isAvailable => !kIsWeb && Platform.isIOS;
  bool get isBrowsing => _isBrowsing;
  bool get isAdvertising => _isAdvertising;
  List<DiscoveredReceiver> get peers {
    final list = _peers.values.toList();
    list.sort((a, b) => a.deviceName.compareTo(b.deviceName));
    return list;
  }

  void attachRequestHandler(LocalShareServer server) {
    _requestHandler = server;
    if (!isAvailable) return;
    _methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> startAdvertising({
    required String peerName,
    required String deviceId,
    required String deviceName,
  }) async {
    if (!isAvailable) return;
    await stopAdvertising();
    await _methodChannel.invokeMethod<void>('startAdvertising', {
      'peerName': peerName,
      'deviceId': deviceId,
      'deviceName': deviceName,
    });
    _isAdvertising = true;
  }

  Future<void> stopAdvertising() async {
    if (!isAvailable || !_isAdvertising) return;
    await _methodChannel.invokeMethod<void>('stopAdvertising');
    _isAdvertising = false;
  }

  Future<void> startBrowsing() async {
    if (!isAvailable) return;
    if (_isBrowsing) return;
    await _ensureEventSubscription();
    await _methodChannel.invokeMethod<void>('startBrowsing');
    _isBrowsing = true;
  }

  Future<void> stopBrowsing() async {
    if (!isAvailable || !_isBrowsing) return;
    await _methodChannel.invokeMethod<void>('stopBrowsing');
    _isBrowsing = false;
    _peers.clear();
  }

  Future<void> connect(String peerId) async {
    if (!isAvailable) return;
    await _methodChannel.invokeMethod<void>('connect', {'peerId': peerId});
  }

  Future<void> connectAndWait(
    String peerId, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!isAvailable) return;
    await _ensureEventSubscription();

    final existing = _connectionWaiters[peerId];
    if (existing != null && !existing.isCompleted) {
      await existing.future.timeout(timeout);
      return;
    }

    final completer = Completer<void>();
    _connectionWaiters[peerId] = completer;
    try {
      await connect(peerId);
      await completer.future.timeout(
        timeout,
        onTimeout: () {
          throw MultipeerException(
            'Could not connect to the nearby receiver. Keep both devices close and try again.',
          );
        },
      );
    } finally {
      if (identical(_connectionWaiters[peerId], completer)) {
        _connectionWaiters.remove(peerId);
      }
    }
  }

  Future<void> disconnect() async {
    if (!isAvailable) return;
    await _methodChannel.invokeMethod<void>('disconnect');
  }

  Future<ShareResponse> sendRequest({
    required String peerId,
    required String method,
    required String path,
    Map<String, String> query = const {},
    List<int> body = const [],
  }) async {
    if (!isAvailable) {
      throw const MultipeerException('Multipeer is only available on iOS.');
    }

    final result = await _methodChannel.invokeMethod<dynamic>('sendRequest', {
      'peerId': peerId,
      'method': method,
      'path': path,
      'query': query,
      'body': body,
    });

    if (result is! Map) {
      throw const MultipeerException('Invalid multipeer response.');
    }
    return ShareResponse.fromMap(result);
  }

  Future<void> dispose() async {
    await _eventSub?.cancel();
    _eventSub = null;
    await stopBrowsing();
    await stopAdvertising();
    await disconnect();
  }

  Future<void> _ensureEventSubscription() async {
    _eventSub ??= _eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  void _onEvent(dynamic event) {
    if (event is! Map) return;
    final type = event['type'] as String? ?? '';
    final peerId = event['peerId'] as String? ?? '';
    if (peerId.isEmpty) return;

    switch (type) {
      case 'peerFound':
        final deviceName = event['deviceName'] as String? ?? 'Device';
        final deviceId = event['deviceId'] as String? ?? peerId;
        _peers[peerId] = DiscoveredReceiver(
          key: peerId,
          deviceName: deviceName,
          deviceId: deviceId,
          source: DiscoverySource.multipeer,
          peerId: peerId,
        );
      case 'peerLost':
        _peers.remove(peerId);
      case 'peerConnected':
        _connectionWaiters.remove(peerId)?.complete();
      case 'peerDisconnected':
        _connectionWaiters.remove(peerId)?.completeError(
              MultipeerException('Lost connection to the nearby receiver.'),
            );
      default:
        break;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method != 'handleRequest') {
      return null;
    }

    final handler = _requestHandler;
    if (handler == null || !handler.isSessionActive) {
      return ShareResponse(
        statusCode: HttpStatus.forbidden,
        body: 'Session not active'.codeUnits,
      ).toMap();
    }

    final args = call.arguments as Map<dynamic, dynamic>;
    final queryRaw = args['query'];
    final query = <String, String>{};
    if (queryRaw is Map) {
      queryRaw.forEach((key, value) {
        query['$key'] = '$value';
      });
    }

    final bodyRaw = args['body'];
    final body = bodyRaw is List
        ? bodyRaw.cast<int>()
        : (bodyRaw as Uint8List?)?.toList() ?? const <int>[];

    final response = await handler.processRequest(
      method: args['method'] as String? ?? 'GET',
      path: args['path'] as String? ?? '/',
      queryParameters: query,
      body: body,
    );
    return response.toMap();
  }
}

class MultipeerException implements Exception {
  const MultipeerException(this.message);

  final String message;

  @override
  String toString() => message;
}
