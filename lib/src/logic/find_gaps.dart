import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/models/time_range.dart';

List<TimeRange> findGaps(List<Tick> entries, int granularity) {
  final List<TimeRange> gaps = [];

  for (var i = 1; i < entries.length; i++) {
    final left = entries[i - 1];
    final right = entries[i];

    if (right.epoch - left.epoch > granularity) {
      gaps.add(TimeRange(left.epoch + granularity, right.epoch));
    }
  }
  return gaps;
}
