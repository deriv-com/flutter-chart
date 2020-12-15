// Remove labels inside time gaps and have overlap
import 'package:deriv_chart/src/x_axis/x_axis_model.dart';

import 'grid/calc_time_grid.dart';

List<DateTime> getNoOverlapGridTimestamps(XAxisModel model) {

  const double _minDistanceBetweenTimeGridLines = 90;
  print("eeeeeee ${model.leftBoundEpoch}");
  print("jjjjjj ${model.rightBoundEpoch}");
  // Calculate time labels' timestamps for current scale.
  final List<DateTime> _gridTimestamps = gridTimestamps(
    timeGridInterval: timeGridInterval(
      model.pxFromMs,
      minDistanceBetweenLines: _minDistanceBetweenTimeGridLines,
    ),
    leftBoundEpoch: model.leftBoundEpoch,
    rightBoundEpoch: model.rightBoundEpoch,
  );
  print(_gridTimestamps);

  List<DateTime> _noOverlapGridTimestamps = [];
  for (final DateTime timestamp in _gridTimestamps) {
    print(timestamp);
    if (!model.isInGap(timestamp.millisecondsSinceEpoch)) {
      if (_noOverlapGridTimestamps.isNotEmpty &&
          timestamp.millisecondsSinceEpoch ==
              _noOverlapGridTimestamps.last.millisecondsSinceEpoch) {
        continue;
      }
      print("xxxx");
      _noOverlapGridTimestamps.add(timestamp);
    }
  }
  return _noOverlapGridTimestamps;
}