import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/annotations/barriers/horizontal_barrier/horizontal_barrier.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';


/// Tick indicator.
class TickIndicator extends HorizontalBarrier {
  /// Initializes a tick indicator.
  TickIndicator(
    Tick tick, {
    String? id,
    HorizontalBarrierStyle? style,
    HorizontalBarrierVisibility visibility = HorizontalBarrierVisibility.normal,
  }) : super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          style: style ??
              const HorizontalBarrierStyle(
                labelShape: LabelShape.pentagon,
              ),
          visibility: visibility,
          longLine: false,
        );
}
