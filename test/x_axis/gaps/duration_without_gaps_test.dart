import 'package:deriv_chart/src/x_axis/gaps/duration_without_gaps.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/models/time_range.dart';

void main() {
  group('durationWithoutGaps should return', () {
    test('full duration when no gaps are given', () {
      expect(
        durationWithoutGaps(
          TimeRange(100, 123),
          [],
        ),
        equals(23),
      );
    });

    test('full duration when gaps do not overlap with range', () {
      expect(
        durationWithoutGaps(
          TimeRange(1111, 2222),
          [TimeRange(1000, 1100)],
        ),
        equals(1111),
      );
    });

    test('0 when gap covers the epoch range', () {
      expect(
        durationWithoutGaps(
          TimeRange(300, 400),
          [TimeRange(250, 400)],
        ),
        equals(0),
      );
    });

    test('duration minus gap when gap falls in the middle', () {
      expect(
        durationWithoutGaps(
          TimeRange(300, 400),
          [TimeRange(350, 360)],
        ),
        equals(90),
      );
    });

    test('duration minus overlaps with gaps', () {
      expect(
        durationWithoutGaps(
          TimeRange(300, 400),
          [TimeRange(250, 360), TimeRange(390, 1000)],
        ),
        equals(30),
      );
      expect(
        durationWithoutGaps(
          TimeRange(300, 1000),
          [
            TimeRange(250, 360),
            TimeRange(390, 400),
            TimeRange(420, 422),
            TimeRange(490, 499),
            TimeRange(800, 900),
            TimeRange(1000, 1200),
            TimeRange(2000, 3000),
          ],
        ),
        equals(519),
      );
    });
  });
}
