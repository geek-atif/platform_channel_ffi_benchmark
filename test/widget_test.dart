import 'package:flutter_test/flutter_test.dart';

import 'package:platform_channel_ffi_benchmark/main.dart';

void main() {
  testWidgets('Benchmark home loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BenchmarkApp());
    expect(find.text('Platform Channel vs FFI'), findsOneWidget);
    expect(find.text('Benchmark MethodChannel'), findsOneWidget);
    expect(find.text('Benchmark FFI'), findsOneWidget);
  });
}
