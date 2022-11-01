import 'package:flutter_test/flutter_test.dart';

import 'package:web_adapter/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DerivChartApp());
  });
}
