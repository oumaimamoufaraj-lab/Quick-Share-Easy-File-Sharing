import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

import '../../models/discovered_receiver.dart';
import '../../models/transfer_transport_kind.dart';
import 'mdns_constants.dart';

class MdnsDiscoveryService {
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;
  final Map<String, DiscoveredReceiver> _receivers = {};

  List<DiscoveredReceiver> get receivers {
    final list = _receivers.values.toList();
    list.sort((a, b) => a.deviceName.compareTo(b.deviceName));
    return list;
  }

  bool get isBrowsing => _discovery != null;
  bool get isAdvertising => _broadcast != null;

  Future<void> startAdvertising({
    required String deviceName,
    required String deviceId,
    required int port,
  }) async {
    if (kIsWeb) return;

    await stopAdvertising();

    final service = BonsoirService(
      name: _serviceInstanceName(deviceName, deviceId),
      type: MdnsConstants.serviceType,
      port: port,
      attributes: {
        'id': deviceId,
        'name': deviceName,
        'v': '2',
      },
    );

    final broadcast = BonsoirBroadcast(service: service);
    await broadcast.ready;
    await broadcast.start();
    _broadcast = broadcast;
  }

  Future<void> stopAdvertising() async {
    final broadcast = _broadcast;
    _broadcast = null;
    if (broadcast != null) {
      await broadcast.stop();
    }
  }

  Future<void> startBrowsing() async {
    if (kIsWeb) return;

    await stopBrowsing();

    final discovery = BonsoirDiscovery(type: MdnsConstants.serviceType);
    await discovery.ready;
    _discoverySub = discovery.eventStream?.listen(
      (event) => _onDiscoveryEvent(discovery, event),
    );
    await discovery.start();
    _discovery = discovery;
  }

  Future<void> stopBrowsing() async {
    await _discoverySub?.cancel();
    _discoverySub = null;

    final discovery = _discovery;
    _discovery = null;
    if (discovery != null) {
      await discovery.stop();
    }
    _receivers.clear();
  }

  void _onDiscoveryEvent(BonsoirDiscovery discovery, BonsoirDiscoveryEvent event) {
    final service = event.service;
    if (service == null) return;

    switch (event.type) {
      case BonsoirDiscoveryEventType.discoveryServiceFound:
        unawaited(service.resolve(discovery.serviceResolver));
      case BonsoirDiscoveryEventType.discoveryServiceResolved:
        _addResolvedService(service);
      case BonsoirDiscoveryEventType.discoveryServiceLost:
        _removeService(service);
      default:
        break;
    }
  }

  void _addResolvedService(BonsoirService service) {
    final host = _resolveHost(service);
    final port = service.port;
    if (host == null || host.isEmpty || port <= 0) return;

    final attributes = service.attributes;
    final deviceId = attributes['id'] ?? '';
    final deviceName = attributes['name'] ?? _displayName(service.name);
    final key = deviceId.isNotEmpty
        ? deviceId
        : '${service.name}@$host:$port';

    _receivers[key] = DiscoveredReceiver(
      key: key,
      host: host,
      port: port,
      deviceName: deviceName,
      deviceId: deviceId,
      serviceName: service.name,
      source: DiscoverySource.mdns,
    );
  }

  void _removeService(BonsoirService service) {
    final attributes = service.attributes;
    final deviceId = attributes['id'];
    if (deviceId != null && deviceId.isNotEmpty) {
      _receivers.remove(deviceId);
      return;
    }

    _receivers.removeWhere((_, receiver) => receiver.serviceName == service.name);
  }

  String? _resolveHost(BonsoirService service) {
    if (service is ResolvedBonsoirService) {
      return service.host;
    }
    return null;
  }

  String _serviceInstanceName(String deviceName, String deviceId) {
    final safeName = deviceName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '-');
    final suffix = deviceId.length > 8 ? deviceId.substring(0, 8) : deviceId;
    final base = safeName.isEmpty ? 'QuickShare' : safeName;
    return '$base-$suffix';
  }

  String _displayName(String serviceName) {
    final dash = serviceName.lastIndexOf('-');
    if (dash > 0) {
      return serviceName.substring(0, dash).replaceAll('-', ' ');
    }
    return serviceName;
  }

  Future<void> dispose() async {
    await stopBrowsing();
    await stopAdvertising();
  }
}
