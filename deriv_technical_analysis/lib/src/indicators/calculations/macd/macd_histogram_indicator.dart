import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/macd/macd_indicator.dart';
import 'package:deriv_technical_analysis/src/indicators/calculations/macd/signal_macd_indicator.dart';

///Histogram of Moving Average Convergance Divergence Indicator.
///Difference of MACD & SignalMACD Indicator.
class MACDHistogramIndicator<T extends IndicatorResult>
    extends CachedIndicator<T> {
  ///Initializes a Histogram of Moving Average Convergance Divergence Indicator.
  MACDHistogramIndicator.fromIndicator(
    MACDIndicator<T> macdIndicator,
    SignalMACDIndicator<T> signalMACDIndicator,
  )   : _macdIndicator = macdIndicator,
        _signalMACDIndicator = signalMACDIndicator,
        super.fromIndicator(macdIndicator);

  final MACDIndicator<T> _macdIndicator;
  final SignalMACDIndicator<T> _signalMACDIndicator;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: _macdIndicator.getValue(index).quote -
            _signalMACDIndicator.getValue(index).quote,
      );
}
