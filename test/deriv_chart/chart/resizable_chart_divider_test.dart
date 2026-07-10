import 'package:deriv_chart/src/deriv_chart/chart/resizable_chart_divider.dart';
import 'package:deriv_chart/src/theme/chart_default_light_theme.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Provider<ChartTheme>.value(
          value: ChartDefaultLightTheme(),
          child: Scaffold(body: child),
        ),
      );

  testWidgets('reports vertical drag delta via onDragUpdate',
      (WidgetTester tester) async {
    final List<double> deltas = <double>[];

    await tester.pumpWidget(
      wrap(
        ResizableChartDivider(
          onDragUpdate: deltas.add,
        ),
      ),
    );

    final Offset start = tester.getCenter(find.byType(ResizableChartDivider));
    final TestGesture gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(deltas, isNotEmpty);
    expect(deltas.reduce((double a, double b) => a + b), closeTo(20, 0.5));
  });

  testWidgets('calls onDragEnd when the drag gesture finishes',
      (WidgetTester tester) async {
    bool dragEnded = false;

    await tester.pumpWidget(
      wrap(
        ResizableChartDivider(
          onDragUpdate: (_) {},
          onDragEnd: () => dragEnded = true,
        ),
      ),
    );

    final Offset start = tester.getCenter(find.byType(ResizableChartDivider));
    final TestGesture gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();

    expect(dragEnded, isFalse);

    await gesture.up();
    await tester.pump();

    expect(dragEnded, isTrue);
  });
}
