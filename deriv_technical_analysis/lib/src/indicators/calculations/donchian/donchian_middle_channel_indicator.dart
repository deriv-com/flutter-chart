import 'package:deriv_technical_analysis/src/models/models.dart';

import '../../cached_indicator.dart';
import '../../indicator.dart';

/// Calculates the value for donchian middle channel.
class DonchianMiddleChannelIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  /// Initializes
  DonchianMiddleChannelIndicator(this.upperChannel, this.lowerChannel)
      : super(upperChannel.input);

  /// Donchian upper channel indicator.
  final Indicator<T> upperChannel;

  /// Donchian lower channel indicator.
  final Indicator<T> lowerChannel;

  @override
  T calculate(int index) {
    final double upper = upperChannel.getValue(index).quote;
    final double lower = lowerChannel.getValue(index).quote;
    return createResult(
      index: index,
      quote: lower + (upper - lower) / 2,
    );
  }
}
