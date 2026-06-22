import '../../models/transfer_transport_kind.dart';

class DiscoveredReceiver {
  const DiscoveredReceiver({
    required this.key,
    required this.deviceName,
    required this.deviceId,
    required this.source,
    this.host = '',
    this.port = 0,
    this.serviceName = '',
    this.peerId = '',
  });

  final String key;
  final String host;
  final int port;
  final String deviceName;
  final String deviceId;
  final String serviceName;
  final DiscoverySource source;
  final String peerId;

  bool get isMultipeer => source == DiscoverySource.multipeer;

  String get baseUrl => isMultipeer
      ? 'multipeer://$deviceId'
      : 'http://$host:$port';
}
