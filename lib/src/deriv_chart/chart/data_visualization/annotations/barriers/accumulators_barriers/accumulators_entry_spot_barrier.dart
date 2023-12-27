import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';

import 'accumulators_entry_spot_barrier_painter.dart';

/// [AccumulatorsEntrySpotBarrier] creates a dot and a dashed horizontal barrier
/// to the previous x epoch where accumulators marker was painted.
/// Example is below.
/// By checking that list of accumulator markers is not empty and when the
/// current tick is the next after painted marker, barrier will be automatically
/// added to a chart.

/// In order to add accumulators entry spot barrier
/// pass [AccumulatorsEntrySpotBarrier] to [annotations]
///
/// annotations: <Barrier>[
///           if (purchaseTime != null &&
///               entrySpot != null &&
///               isAccumulatorsContract(activeContract))
///             AccumulatorsEntrySpotBarrier(
///               nextTickAfterEntrySpot.quote,
///               startingEpoch: purchaseTime,
///               endingEpoch: purchaseTime + 1000,
///               style: HorizontalBarrierStyle(
///                 color: context.theme.brandOrangeColor,
///                 isDashed: false,
///               ),
///             ),
///
/// For [flutter-multipliers] project case specific [nextTickAfterEntrySpot] can
/// be defined in [DerivGoChart] as following:
///
/// final double? nextTickAfterEntrySpot = ticks.asMap()
///       .containsKey(ticks.indexOf(
///             ticks.lastWhere((Tick tick) =>
///                 tick.quote == entrySpot && purchaseTime == tick.epoch)) + 1
///         )
///     ? ticks[ticks.indexOf(ticks.lastWhere((Tick tick) =>
///                 tick.quote == entrySpot && purchaseTime == tick.epoch)) +
///             1]
///         .quote
///     : ticks.last.quote;

/// Horizontal barrier with entry spot class.
class AccumulatorsEntrySpotBarrier extends Barrier {
  /// Initializes barrier.
  AccumulatorsEntrySpotBarrier({
    required double value,
    required this.startingEpoch,
    required int endingEpoch,
    String? id,
    String? title,
    bool longLine = true,
    HorizontalBarrierStyle? style,
    this.visibility = HorizontalBarrierVisibility.keepBarrierLabelVisible,
  }) : super(
          id: id,
          title: title,
          epoch: endingEpoch,
          quote: value,
          style: style,
          longLine: longLine,
        );

  /// Barrier visibility behavior.
  final HorizontalBarrierVisibility visibility;

  /// Epoch which is similar to one with marker.
  /// Barrier will be painter from the next epoch to this one.
  /// [endingEpoch] is used for painting EntrySpot dot.
  /// Barrier goes left from [endingEpoch].
  final int startingEpoch;

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
      BarrierObject(leftEpoch: startingEpoch, rightEpoch: epoch, quote: quote);
}
