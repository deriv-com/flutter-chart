import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

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
