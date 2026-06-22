import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _languageKey = 'language_index';
  static const _onboardingKey = 'onboarding_complete';
  static const _deviceIdKey = 'device_id';
  static const _deviceNameKey = 'device_name';

  static Future<AppPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final appPrefs = AppPreferences(prefs);
    if (!prefs.containsKey(_deviceIdKey)) {
      await prefs.setString(_deviceIdKey, const Uuid().v4());
    }
    return appPrefs;
  }

  int get languageIndex => _prefs.getInt(_languageKey) ?? 0;

  Future<void> setLanguageIndex(int index) =>
      _prefs.setInt(_languageKey, index);

  bool get isOnboardingComplete => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  String get deviceId => _prefs.getString(_deviceIdKey)!;

  String get deviceName {
    final existing = _prefs.getString(_deviceNameKey);
    if (existing != null) return existing;
    final shortId = deviceId.substring(0, 8).toUpperCase();
    final prefix = Platform.isIOS ? 'iPhone' : 'Device';
    final name = '${prefix}_$shortId';
    _prefs.setString(_deviceNameKey, name);
    return name;
  }

  Future<void> setDeviceName(String name) =>
      _prefs.setString(_deviceNameKey, name.trim());

  Future<void> resetOnboarding() => _prefs.setBool(_onboardingKey, false);
}
