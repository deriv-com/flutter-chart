import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/time_grid.dart';

void main() {
  group('gridEpochs should', () {
    test('include epoch on the right edge', () {
      expect(
        gridEpochs(
          timeGridInterval: 1000,
          leftBoundEpoch: 9000,
          rightBoundEpoch: 10000,
        ),
        contains(10000),
      );
    });
    test('include epoch on the left edge', () {
      expect(
        gridEpochs(
          timeGridInterval: 100,
          leftBoundEpoch: 900,
          rightBoundEpoch: 1000,
        ),
        contains(900),
      );
    });
    test('return epochs within canvas, divisible by [timeGridInterval]', () {
      expect(
        gridEpochs(
          timeGridInterval: 100,
          leftBoundEpoch: 700,
          rightBoundEpoch: 1000,
        ),
        equals([1000, 900, 800, 700]),
      );
      expect(
        gridEpochs(
          timeGridInterval: 100,
          leftBoundEpoch: 699,
          rightBoundEpoch: 999,
        ),
        equals([900, 800, 700]),
      );
    });
  });

  group('timeGridInterval should', () {
    test('return given interval if only one is given', () {
      expect(
        timeGridIntervalInSeconds(
          10000000,
          intervalsInSeconds: [10],
        ),
        equals(10),
      );
      expect(
        timeGridIntervalInSeconds(
          0.000001,
          intervalsInSeconds: [42],
        ),
        equals(42),
      );
    });
    test(
        'return smallest given interval that has px width of at least [minDistanceBetweenLines]',
        () {
      expect(
        timeGridIntervalInSeconds(
          1000,
          minDistanceBetweenLines: 100,
          intervalsInSeconds: [10, 99, 120, 200, 1000],
        ),
        equals(120),
      );
      expect(
        timeGridIntervalInSeconds(
          1000,
          minDistanceBetweenLines: 100,
          intervalsInSeconds: [10, 100, 120, 200],
        ),
        equals(100),
      );
      expect(
        timeGridIntervalInSeconds(
          1000,
          minDistanceBetweenLines: 42,
          intervalsInSeconds: [39, 40, 41, 45, 50],
        ),
        equals(45),
      );
    });
  });
}
