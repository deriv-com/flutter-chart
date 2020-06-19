import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_flutter_chart/src/logic/time_grid.dart';

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
}
