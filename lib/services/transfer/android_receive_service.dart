import 'dart:io';

import 'package:flutter/services.dart';

class AndroidReceiveService {
  static const _channel =
      MethodChannel('com.quickshare.easyfilesharing/receive');

  static Future<void> start({required String deviceName}) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('startReceiveService', {
      'deviceName': deviceName,
    });
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('stopReceiveService');
  }
}
