import 'ffi_service.dart';
import 'platform_channel_service.dart';

const int kDefaultIterations = 10000;

/// Runs [PlatformChannelService.getBatteryLevel] [iterations] times (async).
/// [lastBattery] is the value returned by the final iteration.
Future<({int elapsedMs, int lastBattery})> benchmarkPlatformChannel({
  int iterations = kDefaultIterations,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  int lastBattery = 0;
  for (int i = 0; i < iterations; i++) {
    lastBattery = await PlatformChannelService.getBatteryLevel();
  }
  stopwatch.stop();
  return (elapsedMs: stopwatch.elapsedMilliseconds, lastBattery: lastBattery);
}

/// Runs [FfiService.getBattery] [iterations] times (sync).
/// [lastBattery] is the value returned by the final iteration.
({int elapsedMs, int lastBattery}) benchmarkFfi({int iterations = kDefaultIterations}) {
  final Stopwatch stopwatch = Stopwatch()..start();
  int lastBattery = 0;
  for (int i = 0; i < iterations; i++) {
    lastBattery = FfiService.getBattery();
  }
  stopwatch.stop();
  return (elapsedMs: stopwatch.elapsedMilliseconds, lastBattery: lastBattery);
}
