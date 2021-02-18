import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

// TODO(mohammadamir-fs): test macd visually.
/// Moving Average Convergance Divergence Indicator
class MACDIndicator<T extends IndicatorResult> extends CachedIndicator<T> {
  /// Creates a  Moving average convergance divergance indicator from a given indicator,
  /// with short term ema set to `12` periods and long term ema set to `26` periods as default.
  MACDIndicator.fromIndicator(
    Indicator<T> indicator, {
    int shortBarcount = 12,
    int longBarCount = 26,
  })  : assert(shortBarcount < longBarCount),
        _shortTermEma = EMAIndicator<T>(indicator, shortBarcount),
        _longTermEma = EMAIndicator<T>(indicator, longBarCount),
        super.fromIndicator(indicator);

  final EMAIndicator<T> _shortTermEma;
  final EMAIndicator<T> _longTermEma;

  @override
  T calculate(int index) => createResult(
        index: index,
        quote: _shortTermEma.getValue(index).quote -
            _longTermEma.getValue(index).quote,
      );
}
