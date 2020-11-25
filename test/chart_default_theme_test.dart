import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/theme/chart_default_dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  ChartTheme chartTheme;

  setUp(() {
    chartTheme = ChartDefaultDarkTheme();
  });

  group('ChartDefaultTheme test', () {
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
