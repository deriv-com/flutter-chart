import 'package:deriv_chart/src/models/time_range.dart';

/// [range] duration with [gaps] removed.
int durationWithoutGaps(
  TimeRange range,
  List<TimeRange> gaps,
) {
  int overlap = 0;
  for (final TimeRange gap in gaps) {
    overlap += gap.overlap(range)?.duration ?? 0;
  }
  return range.duration - overlap;
}
