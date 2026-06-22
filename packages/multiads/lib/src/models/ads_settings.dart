import '../constants/networks.dart';

class AdsSettings {
  final String openads;
  final List<String> banners;
  final List<String> inters;
  final List<String> natives;
  final List<String> rewards;

  AdsSettings.fromJson(Map<String, dynamic> json)
    : openads = _isMasterDisabled(json)
          ? ''
          : _parseOpenAds(json['openads'], json),
      banners = _isMasterDisabled(json)
          ? []
          : _parseNetworks(json['banners'], json, 'banner'),
      inters = _isMasterDisabled(json)
          ? []
          : _parseNetworks(json['inters'], json, 'inter'),
      natives = _isMasterDisabled(json)
          ? []
          : _parseNetworks(json['natives'], json, 'native'),
      rewards = _isMasterDisabled(json)
          ? []
          : _parseNetworks(json['rewards'], json, 'reward');

  /// `settings.enabled: false` disables every ad format.
  static bool _isMasterDisabled(Map<String, dynamic> json) {
    final enabled = json['enabled'];
    return enabled == false || enabled == 'false';
  }

  /// Resolves which networks serve a format.
  /// Explicit `false` / `"false"` / `["false"]` disables the format (no fallback).
  static List<String> _parseNetworks(
    dynamic listValue,
    Map<String, dynamic> json,
    String flag,
  ) {
    if (_isExplicitlyDisabled(listValue)) return [];

    final direct = _parseNetworkList(listValue)
        .where((network) => network != 'false')
        .toList();
    if (direct.isNotEmpty) return direct;

    final enabled = <String>[];
    for (final network in [Networks.admob, Networks.applovin, Networks.facebook]) {
      final config = json[network];
      if (config is Map && config[flag] == true) {
        enabled.add(network);
      }
    }
    return enabled;
  }

  static String _parseOpenAds(dynamic value, Map<String, dynamic> json) {
    if (_isExplicitlyDisabled(value)) return '';

    if (value is String && value.isNotEmpty && value != 'false') {
      return value;
    }

    for (final network in [Networks.admob, Networks.applovin, Networks.facebook]) {
      final config = json[network];
      if (config is Map && config['open'] == true) {
        return network;
      }
    }
    return '';
  }

  /// True when the remote config explicitly turns off this ad format.
  static bool _isExplicitlyDisabled(dynamic value) {
    if (value == false) return true;
    if (value is String && value == 'false') return true;
    if (value is List) {
      if (value.isEmpty) return false;
      return value.every(
        (e) => e == false || e == null || e.toString() == 'false',
      );
    }
    return false;
  }

  static List<String> _parseNetworkList(dynamic value) {
    if (value == false || value == null) return [];
    if (value is bool) return [];
    if (value is String) {
      if (value.isEmpty || value == 'false') return [];
      return [value];
    }
    if (value is List) {
      return value
          .where((e) => e != false && e != null)
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty && s != 'false')
          .toList();
    }
    return [];
  }
}
