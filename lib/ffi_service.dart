import 'dart:ffi';
import 'dart:io';

typedef NativeGetBattery = Int32 Function();
typedef DartGetBattery = int Function();

/// Direct native call — no platform message encoding (demo returns constant from C).
class FfiService {
  static DartGetBattery? _getBattery;

  static bool get isInitialized => _getBattery != null;

  /// Call once before [getBattery]. Safe to call multiple times.
  static void init() {
    if (_getBattery != null) {
      return;
    }
    final DynamicLibrary dylib = Platform.isAndroid
        ? DynamicLibrary.open('libnative.so')
        : DynamicLibrary.process();
    _getBattery = dylib
        .lookup<NativeFunction<NativeGetBattery>>('getBatteryLevel')
        .asFunction();
  }

  static int getBattery() {
    final DartGetBattery? fn = _getBattery;
    if (fn == null) {
      throw StateError('FfiService.init() must be called first.');
    }
    return fn();
  }
}
