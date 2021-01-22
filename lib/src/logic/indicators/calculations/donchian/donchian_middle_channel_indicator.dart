import 'package:deriv_chart/src/models/tick.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Calculates the value for donchian middle channel.
class DonchianMiddleChannelIndicator extends CachedIndicator {
  /// Initializes
  DonchianMiddleChannelIndicator(this.upperChannel, this.lowerChannel)
      : super(upperChannel.entries);

  /// Donchian upper channel indicator.
  final Indicator upperChannel;

  /// Donchian lower channel indicator.
  final Indicator lowerChannel;

  @override
  Tick calculate(int index) {
    final double upper = upperChannel.getValue(index).quote;
    final double lower = lowerChannel.getValue(index).quote;
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: lower + (upper - lower) / 2,
    );
  }
}
