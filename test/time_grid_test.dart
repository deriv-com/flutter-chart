import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/logic/time_grid.dart';

void main() {
  group('gridEpochs should', () {
    test('include epoch on the right edge', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(milliseconds: 1000),
          leftBoundEpoch: 9000,
          rightBoundEpoch: 10000,
        ),
        contains(DateTime.fromMillisecondsSinceEpoch(10000)),
      );
    });
    test('include epoch on the left edge', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(milliseconds: 100),
          leftBoundEpoch: 900,
          rightBoundEpoch: 1000,
        ),
        contains(DateTime.fromMillisecondsSinceEpoch(900)),
      );
    });
    test('return epochs within canvas, divisible by [timeGridInterval]', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(milliseconds: 100),
          leftBoundEpoch: 700,
          rightBoundEpoch: 1000,
        ),
        equals([
          DateTime.fromMillisecondsSinceEpoch(700),
          DateTime.fromMillisecondsSinceEpoch(800),
          DateTime.fromMillisecondsSinceEpoch(900),
          DateTime.fromMillisecondsSinceEpoch(1000),
        ]),
      );
      expect(
        gridTimestamps(
          timeGridInterval: Duration(milliseconds: 100),
          leftBoundEpoch: 699,
          rightBoundEpoch: 999,
        ),
        equals([
          DateTime.fromMillisecondsSinceEpoch(700),
          DateTime.fromMillisecondsSinceEpoch(800),
          DateTime.fromMillisecondsSinceEpoch(900),
        ]),
      );
    });
    test('return correct epochs for 1h interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 22:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 01:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 22:00:00'),
          DateTime.parse('2020-07-24 23:00:00'),
          DateTime.parse('2020-07-25 00:00:00'),
          DateTime.parse('2020-07-25 01:00:00'),
        ]),
      );
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 22:20:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 01:10:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 23:00:00'),
          DateTime.parse('2020-07-25 00:00:00'),
          DateTime.parse('2020-07-25 01:00:00'),
        ]),
      );
    });
    test('return correct epochs for 2h interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 2),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 22:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 01:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 22:00:00'),
          DateTime.parse('2020-07-25 00:00:00'),
        ]),
      );
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 2),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 22:20:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 02:10:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-25 00:00:00'),
          DateTime.parse('2020-07-25 02:00:00'),
        ]),
      );
    });
    test('return correct epochs for 4h interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 4),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 05:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 01:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 08:00:00'),
          DateTime.parse('2020-07-24 12:00:00'),
          DateTime.parse('2020-07-24 16:00:00'),
          DateTime.parse('2020-07-24 20:00:00'),
          DateTime.parse('2020-07-25 00:00:00'),
        ]),
      );
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 4),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 22:20:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 02:10:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-25 00:00:00'),
        ]),
      );
    });
    test('return correct epochs for 8h interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(hours: 8),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 19:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 19:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-25 00:00:00'),
          DateTime.parse('2020-07-25 08:00:00'),
          DateTime.parse('2020-07-25 16:00:00'),
        ]),
      );
    });
    test('return 00:00:00 of each day for 1 day interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(days: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 15:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 15:00:00').millisecondsSinceEpoch,
        ),
        equals([DateTime.parse('2020-07-25 00:00:00')]),
      );
      expect(
        gridTimestamps(
          timeGridInterval: Duration(days: 1),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 00:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-25 15:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-24 00:00:00'),
          DateTime.parse('2020-07-25 00:00:00'),
        ]),
      );
    });
    test('return 00:00:00 of each Monday for 1 week interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: Duration(days: DateTime.daysPerWeek),
          leftBoundEpoch:
              DateTime.parse('2020-07-24 15:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-07-29 15:00:00').millisecondsSinceEpoch,
        ),
        equals([DateTime.parse('2020-07-27 00:00:00')]),
      );
    });
    test('return 00:00:00 of each month\'s first day for 1 month interval', () {
      expect(
        gridTimestamps(
          timeGridInterval: month,
          leftBoundEpoch:
              DateTime.parse('2020-06-24 08:00:00').millisecondsSinceEpoch,
          rightBoundEpoch:
              DateTime.parse('2020-08-29 12:00:00').millisecondsSinceEpoch,
        ),
        equals([
          DateTime.parse('2020-07-01 00:00:00'),
          DateTime.parse('2020-08-01 00:00:00'),
        ]),
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

  group('timeLabel should', () {
    test('return date for 00:00:00', () {
      expect(
        timeLabel(DateTime.parse('2020-07-02 00:00:00')),
        '2 Jul',
      );
    });
    test('return month name for 00:00:00 of the first day of the month', () {
      expect(
        timeLabel(DateTime.parse('2020-07-01 00:00:00')),
        'July',
      );
    });
    test('return year for 00:00:00 of the first day of the year', () {
      expect(
        timeLabel(DateTime.parse('2020-01-01 00:00:00')),
        '2020',
      );
    });
  });
}
