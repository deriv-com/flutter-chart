import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/time_grid.dart';

void main() {
  group('gridEpochs should', () {
    test('include epoch on the right edge', () {
      expect(
        gridEpochs(
          timeGridInterval: Duration(seconds: 1000),
          leftBoundEpoch: 9000,
          rightBoundEpoch: 10000,
        ),
        contains(10000),
      );
    });
    test('include epoch on the left edge', () {
      expect(
        gridEpochs(
          timeGridInterval: Duration(seconds: 100),
          leftBoundEpoch: 900,
          rightBoundEpoch: 1000,
        ),
        contains(900),
      );
      expect(
        gridEpochs(
          timeGridInterval: Duration(days: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 00:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 15:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 00:00:00').millisecondsSinceEpoch,
          DateTime.parse('2020-07-25 00:00:00').millisecondsSinceEpoch,
        ]),
      );
    });
    test('return epochs within canvas, divisible by [timeGridInterval]', () {
      expect(
        gridEpochs(
          timeGridInterval: Duration(seconds: 100),
          leftBoundEpoch: 700,
          rightBoundEpoch: 1000,
        ),
        equals([1000, 900, 800, 700]),
      );
      expect(
        gridEpochs(
          timeGridInterval: Duration(seconds: 100),
          leftBoundEpoch: 699,
          rightBoundEpoch: 999,
        ),
        equals([900, 800, 700]),
      );
    });
    test('return correct epochs for 24h interval', () {
      expect(
        gridEpochs(
          timeGridInterval: Duration(days: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 15:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 15:00:00').millisecondsSinceEpoch,
        ),
        equals([DateTime.parse('2020-07-25 00:00:00').millisecondsSinceEpoch]),
      );
    });
  });

  group('timeGridInterval should', () {
    test('return given interval if only one is given', () {
      expect(
        timeGridInterval(
          10000000,
          intervals: [Duration(seconds: 10)],
        ),
        equals(Duration(seconds: 10)),
      );
      expect(
        timeGridInterval(
          0.000001,
          intervals: [Duration(seconds: 42)],
        ),
        equals(Duration(seconds: 42)),
      );
    });
    test(
        'return smallest given interval that has px width of at least [minDistanceBetweenLines]',
        () {
      expect(
        timeGridInterval(
          1000,
          minDistanceBetweenLines: 100,
          intervals: [
            Duration(seconds: 10),
            Duration(seconds: 99),
            Duration(seconds: 120),
            Duration(seconds: 200),
            Duration(seconds: 1000),
          ],
        ),
        equals(Duration(seconds: 120)),
      );
      expect(
        timeGridInterval(
          1000,
          minDistanceBetweenLines: 100,
          intervals: [
            Duration(seconds: 10),
            Duration(seconds: 100),
            Duration(seconds: 120),
            Duration(seconds: 200),
          ],
        ),
        equals(Duration(seconds: 100)),
      );
      expect(
        timeGridInterval(
          1000,
          minDistanceBetweenLines: 42,
          intervals: [
            Duration(seconds: 39),
            Duration(seconds: 40),
            Duration(seconds: 41),
            Duration(seconds: 45),
            Duration(seconds: 50),
          ],
        ),
        equals(Duration(seconds: 45)),
      );
    });
  });
}
