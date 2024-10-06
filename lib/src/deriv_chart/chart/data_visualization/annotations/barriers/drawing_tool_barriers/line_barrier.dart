import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/drawing_tool_barriers/line_barrier_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/chart_annotation.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/drawing_tools/data_model/edge_point.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/line_barrier_object.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

/// Line barrier to annotate line start edge point and end edge point on the chart.
/// It will have two quote in the y-axis and two epoch in the x-axis of the respective edge points.
class LineBarrier extends ChartAnnotation<LineBarrierObject> {
  /// Initializes a line barrier.
  LineBarrier({
    required this.start,
    required this.end,
    String? id,
    String? title,
    BarrierStyle? style,
  }) : super(id ?? '$title$style', style: style);

  /// Start edge point of the line.
  final EdgePoint start;

  /// End edge point of the line.
  final EdgePoint end;

  @override
  SeriesPainter<Series> createPainter() => LineBarrierPainter(this);

  @override
  LineBarrierObject createObject() => LineBarrierObject(
        startBarrier: start.quote,
        endBarrier: end.quote,
        barrierStartEpoch: start.epoch,
        barrierEndEpoch: end.epoch,
      );

  @override
  List<double> recalculateMinMax() {
    final double startQuote = start.quote;
    final double endQuote = end.quote;
    return <double>[
      startQuote < endQuote ? startQuote : endQuote,
      startQuote > endQuote ? startQuote : endQuote
    ];
  }

  @override
  int? getMaxEpoch() => start.epoch > end.epoch ? start.epoch : end.epoch;

  @override
  int? getMinEpoch() => start.epoch < end.epoch ? start.epoch : end.epoch;
}
