import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        'durationToString returns the right MM:SS format when hour is 0 and '
        'minute is not 2 digits', () {
      const Duration time = Duration(minutes: 4, seconds: 15);

      expect(durationToString(time), '04:15');
    });

    group('CalculateTextColor', () {
      test(
          'CalculateTextColor calculates the correct color for the given '
          'brightness', () {
        expect(calculateTextColor(Colors.black), Colors.white);
        expect(calculateTextColor(Colors.white), Colors.black);
      });
    });
  });
  group('Label width test', () {
    test(
        'label width returns the correct width from the given text, style and '
        'pipSize', () {
      expect(labelWidth(10, const TextStyle(), 10), 182);
      expect(labelWidth(100, const TextStyle(), 10), 196);
    });
  });

  group('getMinMax index function', () {
    test('Gets the min/max index of a list with no NaN value', () {
      const List<Tick> ticks = <Tick>[
        Tick(epoch: 0, quote: 12),
        Tick(epoch: 1, quote: 13),
        Tick(epoch: 2, quote: 10),
        Tick(epoch: 3, quote: 5),
        Tick(epoch: 4, quote: 2),
        Tick(epoch: 5, quote: 20),
        Tick(epoch: 6, quote: 4),
      ];

      final MinMaxIndices minMaxIndex = getMinMaxIndex(ticks, 3);

      expect(minMaxIndex.minIndex, 4);
      expect(minMaxIndex.maxIndex, 5);
    });

    test('Gets the min/max index of a list with no NaN value at the end', () {
      const List<Tick> ticks = <Tick>[
        Tick(epoch: 0, quote: 12),
        Tick(epoch: 1, quote: 13),
        Tick(epoch: 2, quote: 10),
        Tick(epoch: 3, quote: 5),
        Tick(epoch: 4, quote: 2),
        Tick(epoch: 5, quote: 20),
        Tick(epoch: 6, quote: double.nan),
      ];

      final MinMaxIndices minMaxIndex = getMinMaxIndex(ticks, 3);

      expect(minMaxIndex.minIndex, 4);
      expect(minMaxIndex.maxIndex, 5);
    });

    test('Gets the min/max index of a list with no NaN value in the middle',
        () {
      const List<Tick> ticks = <Tick>[
        Tick(epoch: 0, quote: 12),
        Tick(epoch: 1, quote: 13),
        Tick(epoch: 2, quote: 10),
        Tick(epoch: 3, quote: 5),
        Tick(epoch: 4, quote: double.nan),
        Tick(epoch: 5, quote: 20),
        Tick(epoch: 6, quote: 4),
      ];

      final MinMaxIndices minMaxIndex = getMinMaxIndex(ticks, 3);

      expect(minMaxIndex.minIndex, 6);
      expect(minMaxIndex.maxIndex, 5);
    });

    test('Gets the min/max index of a list with last two being NaN', () {
      const List<Tick> ticks = <Tick>[
        Tick(epoch: 0, quote: 12),
        Tick(epoch: 1, quote: 13),
        Tick(epoch: 2, quote: 10),
        Tick(epoch: 3, quote: 5),
        Tick(epoch: 4, quote: 2),
        Tick(epoch: 5, quote: double.nan),
        Tick(epoch: 6, quote: double.nan),
      ];

      final MinMaxIndices minMaxIndex = getMinMaxIndex(ticks, 3);

      expect(minMaxIndex.minIndex, 4);
      expect(minMaxIndex.maxIndex, 3);
    });
  });
}

enum MockEnum {
  type1,
  type2,
}
