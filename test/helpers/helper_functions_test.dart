// @dart=2.9

import 'package:deriv_chart/src/helpers/helper_functions.dart';
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

  group('CalculateTextColor', () {
    test(
        'CalculateTextColor calculates the correct color for the given brightness',
        () {
      expect(calculateTextColor(Colors.black), Colors.white);
      expect(calculateTextColor(Colors.white), Colors.black);
    });
  });
}

enum MockEnum {
  type1,
  type2,
}
