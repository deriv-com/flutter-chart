import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChartTheme chartTheme;

  setUp(() {
    chartTheme = ChartDefaultTheme();
  });

  group('ChartDefaultTheme test', () {
    testWidgets(
        '[ChartDefaultTheme.updateTheme] updates the theme brightness',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));

      final bool previousIsDarkTheme = chartTheme.isDarkTheme;

      chartTheme.updateTheme(
        brightness: previousIsDarkTheme ? Brightness.light : Brightness.dark,
      );

      expect(chartTheme.isDarkTheme, !previousIsDarkTheme);
    });

    test(
        '[ChartDefaultTheme.testStyle] returns the same TextStyle with specified color',
        () {
      final TextStyle textStyle = chartTheme.textStyle(
        textStyle: const TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
        color: Colors.redAccent,
      );

      expect(textStyle.fontSize, 29);
      expect(textStyle.fontWeight, FontWeight.bold);
      expect(textStyle.color, Colors.redAccent);
    });
  });
}
