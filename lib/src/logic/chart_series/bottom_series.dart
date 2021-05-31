import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/series_painter.dart';

/// BottomSeries class that use to draw bottom indicator series in BottomChart
class BottomSeries extends Series {
  /// Constructor of BottomSeries
  BottomSeries(this.series, {this.hasZeroLine = false, String id}) : super(id);

  /// true if series needs to have horizontal zero line
  bool hasZeroLine;

  /// the series
  Series series;

  @override
  SeriesPainter<Series> createPainter() => series.createPainter();

  @override
  bool didUpdate(ChartData oldData) => series.didUpdate(oldData);

  @override
  int getMaxEpoch() => series.getMaxEpoch();

  @override
  int getMinEpoch() => series.getMinEpoch();

  @override
  void onUpdate(int leftEpoch, int rightEpoch) =>
      series.onUpdate(leftEpoch, rightEpoch);

  @override
  List<double> recalculateMinMax() => series.recalculateMinMax();
}
