# platform_channel_ffi_benchmark

Minimal Flutter app comparing:

| Approach | Characteristics |
|----------|-----------------|
| **MethodChannel** | Async, codec serialization, thread / engine hop |
| **FFI** | Sync, direct native call, no platform message encoding |

Both paths return a **stub** battery value `100` from native code (C on Android + iOS, Kotlin/Swift only for the channel side on Android/iOS).

## Project layout

- `lib/platform_channel_service.dart` — `MethodChannel('benchmark_channel')`
- `lib/ffi_service.dart` — `DynamicLibrary.open('libnative.so')` (Android) / `DynamicLibrary.process()` (iOS)
- `lib/benchmark_runner.dart` — 10 000 iterations helpers
- `lib/main.dart` — buttons + results
- **Android:** `MainActivity.kt` + `src/main/cpp/native.c` + CMake → `libnative.so`
- **iOS:** `AppDelegate.swift` channel registration + `get_battery_ffi.c` linked into Runner

## Run

```bash
cd platform_channel_ffi_benchmark
flutter pub get
flutter run
```

Use a **physical device or emulator** for meaningful timings. Debug builds add overhead; `--release` shows a starker gap for MethodChannel.

## Expected ballpark (not a guarantee)

- MethodChannel: often **~150–400 ms** for 10k calls (device-dependent)
- FFI: often **~5–20 ms** for 10k synchronous calls

FFI is **not** always the right tool: use channels for infrequent OS APIs and simpler maintenance; use FFI for hot paths (crypto, sensors, heavy numeric loops) when you accept native build complexity.

## Requirements

- Flutter SDK (project uses `sdk: ^3.11.0` in `pubspec.yaml`)
- Android: NDK (via Android Studio / `ndkVersion` from Flutter)
- iOS: Xcode (Swift channel + C for FFI in same Runner target)
