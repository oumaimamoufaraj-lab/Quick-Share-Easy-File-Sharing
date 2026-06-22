import 'package:flutter/material.dart';

import '../services/app_preferences.dart';
import '../services/transfer/transfer_service.dart';

class AppScope extends InheritedNotifier<AppScopeController> {
  const AppScope({
    super.key,
    required AppScopeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppScopeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>()?.notifier;
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }
}

class AppScopeController extends ChangeNotifier {
  AppScopeController(
    this.preferences, {
    TransferService? transferService,
  })  : transfer = transferService ?? TransferService(),
        _languageIndex = preferences.languageIndex;

  final AppPreferences preferences;
  final TransferService transfer;
  int _languageIndex;

  int get languageIndex => _languageIndex;

  Future<void> setLanguage(int index) async {
    _languageIndex = index;
    await preferences.setLanguageIndex(index);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await preferences.setOnboardingComplete(true);
    notifyListeners();
  }

  bool get isOnboardingComplete => preferences.isOnboardingComplete;

  String get deviceId => preferences.deviceId;
  String get deviceName => preferences.deviceName;

  Future<void> updateDeviceName(String name) async {
    await preferences.setDeviceName(name);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await preferences.resetOnboarding();
    notifyListeners();
  }

  @override
  void dispose() {
    transfer.dispose();
    super.dispose();
  }
}
