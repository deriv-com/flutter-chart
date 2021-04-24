// @dart=2.9

import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/x_axis/grid/calc_time_grid.dart';

void main() {
  // Timestamps.
  test('include timestamp on the right edge', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(milliseconds: 1000),
        leftBoundEpoch: 9000,
        rightBoundEpoch: 10000,
      ),
      contains(DateTime.fromMillisecondsSinceEpoch(10000, isUtc: true)),
    );
  });
  test('include timestamp on the left edge', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(milliseconds: 100),
        leftBoundEpoch: 900,
        rightBoundEpoch: 1000,
      ),
      contains(DateTime.fromMillisecondsSinceEpoch(900, isUtc: true)),
    );
  });
  test('timestamps for small intervals', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(milliseconds: 100),
        leftBoundEpoch: 700,
        rightBoundEpoch: 1000,
      ),
      equals([
        DateTime.fromMillisecondsSinceEpoch(700, isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(800, isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(900, isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true),
      ]),
    );
    expect(
      gridTimestamps(
        timeGridInterval: Duration(milliseconds: 100),
        leftBoundEpoch: 699,
        rightBoundEpoch: 999,
      ),
      equals([
        DateTime.fromMillisecondsSinceEpoch(700, isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(800, isUtc: true),
        DateTime.fromMillisecondsSinceEpoch(900, isUtc: true),
      ]),
    );
  });
  test('timestamps for 1h interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 1),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 22:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 01:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-24 22:00:00Z'),
        DateTime.parse('2020-07-24 23:00:00Z'),
        DateTime.parse('2020-07-25 00:00:00Z'),
        DateTime.parse('2020-07-25 01:00:00Z'),
      ]),
    );
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 1),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 22:20:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 01:10:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-24 23:00:00Z'),
        DateTime.parse('2020-07-25 00:00:00Z'),
        DateTime.parse('2020-07-25 01:00:00Z'),
      ]),
    );
  });
  test('timestamps for 2h interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 2),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 22:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 01:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-24 22:00:00Z'),
        DateTime.parse('2020-07-25 00:00:00Z'),
      ]),
    );
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 2),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 22:20:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 02:10:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-25 00:00:00Z'),
        DateTime.parse('2020-07-25 02:00:00Z'),
      ]),
    );
  });
  test('timestamps for 4h interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 4),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 05:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 01:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-24 08:00:00Z'),
        DateTime.parse('2020-07-24 12:00:00Z'),
        DateTime.parse('2020-07-24 16:00:00Z'),
        DateTime.parse('2020-07-24 20:00:00Z'),
        DateTime.parse('2020-07-25 00:00:00Z'),
      ]),
    );
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 4),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 22:20:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 02:10:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-25 00:00:00Z'),
      ]),
    );
  });
  test('timestamps for 8h interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(hours: 8),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 19:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 19:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-25 00:00:00Z'),
        DateTime.parse('2020-07-25 08:00:00Z'),
        DateTime.parse('2020-07-25 16:00:00Z'),
      ]),
    );
  });
  test('timestamps for 1 day interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(days: 1),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 15:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 15:00:00Z').millisecondsSinceEpoch,
      ),
      equals([DateTime.parse('2020-07-25 00:00:00Z')]),
    );
    expect(
      gridTimestamps(
        timeGridInterval: Duration(days: 1),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 00:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-25 15:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-24 00:00:00Z'),
        DateTime.parse('2020-07-25 00:00:00Z'),
      ]),
    );
  });
  test('timestamps for 1 week interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(days: DateTime.daysPerWeek),
        leftBoundEpoch:
            DateTime.parse('2020-07-24 15:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-07-29 15:00:00Z').millisecondsSinceEpoch,
      ),
      equals([DateTime.parse('2020-07-27 00:00:00Z')]),
    );
  });
  test('timestamps for 1 month interval', () {
    expect(
      gridTimestamps(
        timeGridInterval: Duration(days: 30),
        leftBoundEpoch:
            DateTime.parse('2020-06-24 08:00:00Z').millisecondsSinceEpoch,
        rightBoundEpoch:
            DateTime.parse('2020-08-29 12:00:00Z').millisecondsSinceEpoch,
      ),
      equals([
        DateTime.parse('2020-07-01 00:00:00Z'),
        DateTime.parse('2020-08-01 00:00:00Z'),
      ]),
    );
  });

  // Interval.
  test('given interval if only one is given', () {
    expect(
      timeGridInterval(
        (int ms) => ms / 10000000,
        intervals: [Duration(seconds: 10)],
      ),
      equals(Duration(seconds: 10)),
    );
    expect(
      timeGridInterval(
        (int ms) => ms / 0.000001,
        intervals: [Duration(seconds: 42)],
      ),
      equals(Duration(seconds: 42)),
    );
  });
  test('smallest given interval that satisfies [minDistanceBetweenLines]', () {
    expect(
      timeGridInterval(
        (int ms) => ms / 1000,
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
        (int ms) => ms / 1000,
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
        (int ms) => ms / 1000,
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
}
