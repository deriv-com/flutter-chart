import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';

import 'horizontal_barrier.dart';

/// Tick indicator
class TickIndicator extends HorizontalBarrier {
  /// Initializes
  TickIndicator(
    Tick tick, {
    String id,
    HorizontalBarrierStyle style,
  }) : super(
          tick.quote,
          epoch: tick.epoch,
          id: id,
          style: style ??
              const HorizontalBarrierStyle(
                labelShape: LabelShape.pentagon,
              ),
          longLine: false,
        );
}
