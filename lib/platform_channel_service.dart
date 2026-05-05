import 'package:flutter/services.dart';

/// Async platform channel (`MethodChannel`) — serialization + thread hop per call.
class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('benchmark_channel');

  static Future<int> getBatteryLevel() async {
    final int? result = await _channel.invokeMethod<int>('getBattery');
    return result ?? 0;
  }
}
