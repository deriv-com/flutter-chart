import 'package:deriv_chart/src/logic/chart_series/base_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_renderable.dart';
import 'package:deriv_chart/src/models/candle.dart';

/// Line series
class LineSeries extends BaseSeries {
  /// Initializes
  LineSeries(List<Candle> entries, String id) : super(entries, id);

  @override
  void updateRenderable(
    List<Candle> visibleEntries,
    int leftEpoch,
    int rightEpoch,
  ) =>
      rendererable =
          LineRenderable(this, visibleEntries, prevLastCandle);
}
