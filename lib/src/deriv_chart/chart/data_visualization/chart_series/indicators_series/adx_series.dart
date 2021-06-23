import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';

class ADXSeries extends Series {
  ADXSeries(String id) : super(id);

  @override
  SeriesPainter<Series> createPainter() {
    // TODO: implement createPainter
    throw UnimplementedError();
  }

  @override
  bool didUpdate(ChartData oldData) {
    // TODO: implement didUpdate
    throw UnimplementedError();
  }

  @override
  int getMaxEpoch() {
    // TODO: implement getMaxEpoch
    throw UnimplementedError();
  }

  @override
  int getMinEpoch() {
    // TODO: implement getMinEpoch
    throw UnimplementedError();
  }

  @override
  void onUpdate(int leftEpoch, int rightEpoch) {
    // TODO: implement onUpdate
  }

  @override
  List<double> recalculateMinMax() {
    // TODO: implement recalculateMinMax
    throw UnimplementedError();
  }
}
