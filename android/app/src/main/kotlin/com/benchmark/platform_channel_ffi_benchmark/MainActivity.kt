package com.benchmark.platform_channel_ffi_benchmark

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
            if (call.method == "getBattery") {
                result.success(100)
            } else {
                result.notImplemented()
            }
        }
    }

    companion object {
        private const val CHANNEL = "benchmark_channel"
    }
}
