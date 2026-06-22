package com.quickshare.easyfilesharing

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startReceiveService" -> {
                    val deviceName = call.argument<String>("deviceName") ?: "Quick Share"
                    ReceiveForegroundService.start(this, deviceName)
                    result.success(null)
                }
                "stopReceiveService" -> {
                    ReceiveForegroundService.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.quickshare.easyfilesharing/receive"
    }
}
