import 'package:flutter/material.dart';

import 'benchmark_runner.dart';
import 'ffi_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BenchmarkApp());
}

class BenchmarkApp extends StatelessWidget {
  const BenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Channel vs FFI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BenchmarkHomePage(),
    );
  }
}

class BenchmarkHomePage extends StatefulWidget {
  const BenchmarkHomePage({super.key});

  @override
  State<BenchmarkHomePage> createState() => _BenchmarkHomePageState();
}

class _BenchmarkHomePageState extends State<BenchmarkHomePage> {
  String _log = 'Tap a button to run $kDefaultIterations iterations.\n'
      'Platform Channel: async + codec.\n'
      'FFI: sync direct call (init loads native lib).';

  bool _busy = false;
  String _methodChannelBatteryLabel = '—';
  String _ffiBatteryLabel = '—';

  Future<void> _runChannel() async {
    setState(() {
      _busy = true;
      _log = 'Running MethodChannel benchmark…';
    });
    final ({int elapsedMs, int lastBattery}) result = await benchmarkPlatformChannel();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _log = 'Platform Channel: ${result.elapsedMs} ms ($kDefaultIterations calls)\n'
          '(typical range on device: ~150–400 ms — varies by OS load)';
      _methodChannelBatteryLabel = '${result.lastBattery}%';
    });
  }

  Future<void> _runFfi() async {
    setState(() {
      _busy = true;
      _log = 'Running FFI benchmark…';
    });
    try {
      FfiService.init();
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _log = 'FFI init failed: $e\n'
            'On Android ensure libnative.so is built (CMake). '
            'On iOS ensure get_battery_ffi.c is in the Runner target.';
      });
      return;
    }
    final ({int elapsedMs, int lastBattery}) result = benchmarkFfi();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _log = 'FFI: ${result.elapsedMs} ms ($kDefaultIterations calls)\n'
          '(typical range: ~5–20 ms — much lower overhead)';
      _ffiBatteryLabel = '${result.lastBattery}%';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Channel vs FFI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Compare async MethodChannel to synchronous FFI for the same '
              'stub “battery” value (native returns 100).',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _runChannel,
              child: const Text('Benchmark MethodChannel'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _busy ? null : _runFfi,
              child: const Text('Benchmark FFI'),
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Last battery (MethodChannel, from benchmark): '
                      '$_methodChannelBatteryLabel',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last battery (FFI, from benchmark): $_ffiBatteryLabel',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _log,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
