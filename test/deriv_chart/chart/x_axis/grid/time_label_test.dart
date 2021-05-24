import 'package:deriv_chart/src/deriv_chart/chart/x_axis/functions/calc_no_overlay_time_gaps.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/grid/time_label.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deriv_chart/src/models/time_range.dart';

void main() {
  test('start of day -> date in format `2 Jul`', () {
    expect(
      timeLabel(DateTime.parse('2020-07-02 00:00:00Z')),
      '2 Jul',
    );
  });
  test('start of the month -> full month name', () {
    expect(
      timeLabel(DateTime.parse('2020-07-01 00:00:00Z')),
      'July',
    );
  });
  test('start of the year -> year', () {
    expect(
      timeLabel(DateTime.parse('2020-01-01 00:00:00Z')),
      '2020',
    );
  });

  test('test should Remove labels inside time gaps and have overlap', () {
    final List<DateTime> gridTimestamps = [
      DateTime.utc(2020, 12, 10, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 11, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 12, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 13, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 14, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 15, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 16, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 17, 0, 0, 0, 0)
    ];

    List<TimeRange> gaps = [
      TimeRange(1607567040000, 1607644800000),
      TimeRange(1607653440000, 1607731200000),
      TimeRange(1607739840000, 1607990400000),
      TimeRange(1607999040000, 1608163200000)
    ];

    final List<DateTime> noOverLapTimeStamps = [
      DateTime.utc(2020, 12, 10, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 11, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 12, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 15, 0, 0, 0, 0),
      DateTime.utc(2020, 12, 17, 0, 0, 0, 0)
    ];
    const double minDistanceBetweenTimeGridLines = 80;

    double msPerPx = 1000;
    expect(
      calculateNoOverlapGridTimestamps(
        gridTimestamps,
        minDistanceBetweenTimeGridLines,
        (int leftEpoch, int rightEpoch) => (rightEpoch - leftEpoch) / msPerPx,
        (int epoch) => gaps.any((TimeRange range) => range.contains(epoch)),
      ),
      noOverLapTimeStamps,
    );
  });
}
