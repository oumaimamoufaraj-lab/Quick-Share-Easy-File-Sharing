import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  NetworkInfoService({NetworkInfo? info}) : _info = info ?? NetworkInfo();

  final NetworkInfo _info;

  Future<String?> getWifiIPv4() async {
    if (Platform.isIOS || Platform.isAndroid) {
      final wifiIp = await _info.getWifiIP();
      if (wifiIp != null &&
          wifiIp.isNotEmpty &&
          wifiIp != '0.0.0.0' &&
          _isPrivateLan(wifiIp)) {
        return wifiIp;
      }
    }

    String? fallback;
    for (final interface in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    )) {
      for (final addr in interface.addresses) {
        if (addr.isLoopback || addr.isLinkLocal) continue;
        if (_isPrivateLan(addr.address)) {
          return addr.address;
        }
        fallback ??= addr.address;
      }
    }
    return fallback;
  }

  static bool _isPrivateLan(String ip) {
    if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
    if (ip.startsWith('172.')) {
      final second = int.tryParse(ip.split('.').elementAtOrNull(1) ?? '');
      if (second != null && second >= 16 && second <= 31) return true;
    }
    return false;
  }
}
