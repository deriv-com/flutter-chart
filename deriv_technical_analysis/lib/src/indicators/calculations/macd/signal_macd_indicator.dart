import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/macd/macd_indicator.dart';

///Signal of Moving Average Convergance Divergence Indicator.
///Normaly a 9-day period EMA of MACD.
class SignalMACDIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  ///Initialezes a signal of MACD indicator.
  SignalMACDIndicator.fromIndicator(
    MACDIndicator<T> indicator, {
    int period = 9,
  })  : _signalMACDIndicator = EMAIndicator<T>(indicator, period),
        super.fromIndicator(indicator);

  final EMAIndicator<T> _signalMACDIndicator;

  @override
  T calculate(int index) => _signalMACDIndicator.getValue(index);
}
