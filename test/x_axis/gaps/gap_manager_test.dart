import 'package:deriv_chart/src/x_axis/gaps/gap_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deriv_chart/src/models/time_range.dart';

void main() {
  GapManager manager;

  setUp(() {
    manager = GapManager();
  });

  group('manager.removeGaps should return', () {
    test('full duration when no gaps are given', () {
      expect(
        manager.removeGaps(TimeRange(100, 123)),
        equals(23),
      );
    });

    test('full duration when gaps do not overlap with range', () {
      manager.replaceGaps([TimeRange(1000, 1100)]);
      expect(
        manager.removeGaps(TimeRange(1111, 2222)),
        equals(1111),
      );
    });

    test('0 when gap covers the epoch range', () {
      manager.replaceGaps([TimeRange(250, 400)]);
      expect(
        manager.removeGaps(TimeRange(300, 400)),
        equals(0),
      );
    });

    test('duration minus gap when gap falls in the middle', () {
      manager.replaceGaps([TimeRange(350, 360)]);
      expect(
        manager.removeGaps(TimeRange(300, 400)),
        equals(90),
      );
    });

    test('duration minus overlaps with two gaps', () {
      manager.replaceGaps(
        [TimeRange(250, 360), TimeRange(390, 1000)],
      );
      expect(
        manager.removeGaps(TimeRange(300, 400)),
        equals(30),
      );
    });

    test('duration minus overlaps with many gaps', () {
      manager.replaceGaps(
        [
          TimeRange(250, 360),
          TimeRange(390, 400),
          TimeRange(420, 422),
          TimeRange(490, 499),
          TimeRange(800, 900),
          TimeRange(1000, 1200),
          TimeRange(2000, 3000),
        ],
      );
      expect(
        manager.removeGaps(TimeRange(300, 1000)),
        equals(519),
      );
    });
  });
}
