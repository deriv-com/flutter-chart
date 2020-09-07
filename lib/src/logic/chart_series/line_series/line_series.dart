import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_renderable.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// Line series
class LineSeries extends BaseSeries<Tick> {
  /// Initializes
  LineSeries(List<Tick> entries, String id) : super(entries, id);

  @override
  void updateRenderable(
    List<Tick> visibleEntries,
    int leftEpoch,
    int rightEpoch,
  ) =>
      rendererable = LineRenderable(this, visibleEntries, prevLastEntry);
}
