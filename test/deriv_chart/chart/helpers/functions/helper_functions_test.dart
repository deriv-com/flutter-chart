import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getEnumValue function', () {
    test('Gets enum value as string without enum prefix', () {
      expect(getEnumValue(MockEnum.type1), 'type1');
    });
  });

  group('safe min/max', () {
    test('safeMin Calculates the correct result from giving 2 inputs', () {
      expect(safeMin(double.nan, double.nan).isNaN, true);
      expect(safeMin(10, double.nan), 10);
      expect(safeMin(double.nan, 5), 5);
      expect(safeMin(10, 5), 5);
    });

    test('safeMax Calculates the correct result from giving 2 inputs', () {
      expect(safeMax(double.nan, double.nan).isNaN, true);
      expect(safeMax(10, double.nan), 10);
      expect(safeMax(double.nan, 5), 5);
      expect(safeMax(10, 5), 10);
    });
  });

  group('duration to string', () {
    test('durationToString returns the right H:MM:SS format when hour is not 0',
        () {
      const Duration time = Duration(hours: 1, minutes: 20, seconds: 15);

      expect(durationToString(time), '1:20:15');
    });

    test('durationToString returns the right MM:SS format when hour is 0', () {
      const Duration time = Duration(minutes: 20, seconds: 15);

      expect(durationToString(time), '20:15');
    });

    test(
        'durationToString returns the right MM:SS format when hour is 0 and minute is not 2 digits',
        () {
      const Duration time = Duration(minutes: 4, seconds: 15);

      expect(durationToString(time), '04:15');
    });

    group('CalculateTextColor', () {
      test(
          'CalculateTextColor calculates the correct color for the given brightness',
          () {
        expect(calculateTextColor(Colors.black), Colors.white);
        expect(calculateTextColor(Colors.white), Colors.black);
      });
    });
  });
  group('Label width test', () {
    test(
        'label width returns the correct width from the given text, style and pipSize',
        () {
      expect(labelWidth(10, const TextStyle(), 10), 182);
      expect(labelWidth(100, const TextStyle(), 10), 196);
    });
  });
}

enum MockEnum {
  type1,
  type2,
}
