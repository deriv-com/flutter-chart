import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';

import 'accumulators_entry_spot_barrier_painter.dart';

// [AccumulatorsEntrySpotBarrier] creates a dot and a dashed horizontal barrier
// to the previous x epoch where accumulators marker was painted.
// Example is below.
// By checking that list of accumulator markers is not empty and when the
// current tick is the next after painted marker, barrier will be automatically
// added to a chart.

//if (_accumulatorMarkers.isNotEmpty &&
//           _accumulatorMarkers.last.epoch == ticks[ticks.length - 2].epoch) {
//         WidgetsBinding.instance!.addPostFrameCallback(
//           (_) {
//             _barriers.add(
//               AccumulatorsEntrySpotBarrier(
//                 ticks.last.quote,
//                 startingEpoch: ticks[ticks.length - 2].epoch,
//                 endingEpoch: ticks.last.epoch,
//                 id: 'randomId',
//                 longLine: true,
//                 visibility: HorizontalBarrierVisibility.normal,
//                 style: HorizontalBarrierStyle(
//                   color: Colors.grey,
//                   isDashed: true,
//                 ),
//               ),
//             );
//           },
//         );
//       }


/// Horizontal barrier with entry spot class.
class AccumulatorsEntrySpotBarrier extends Barrier {
  /// Initializes barrier.
  AccumulatorsEntrySpotBarrier(
    double value, {
    this.startingEpoch,
    int? endingEpoch,
    String? id,
    String? title,
    bool longLine = true,
    HorizontalBarrierStyle? style,
    this.visibility = HorizontalBarrierVisibility.keepBarrierLabelVisible,
  }) : super(
          id: id,
          title: title,
          epoch: endingEpoch,
          value: value,
          style: style,
          longLine: longLine,
        );

  /// Barrier visibility behavior.
  final HorizontalBarrierVisibility visibility;

  /// Epoch which is similar to one with marker.
  /// Barrier will be painter from the next epoch to this one.
  /// [endingEpoch] is used for painting EntrySpot dot.
  /// Barrier goes left from [endingEpoch].
  final int? startingEpoch;

  @override
  SeriesPainter<Series> createPainter() =>
      AccumulatorsEntrySpotBarrierPainter<AccumulatorsEntrySpotBarrier>(this);

  @override
  List<double> recalculateMinMax() =>
      // When its visibility is NOT forceToStayOnRange, we return [NaN, NaN],
      // so the chart will ignore this barrier when it wants to define
      // its Y-Axis range.
      visibility == HorizontalBarrierVisibility.forceToStayOnRange
          ? super.recalculateMinMax()
          : <double>[double.nan, double.nan];

  @override
  BarrierObject createObject() =>
      BarrierObject(leftEpoch: startingEpoch, rightEpoch: epoch, value: value);
}
