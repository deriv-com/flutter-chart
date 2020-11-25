import 'package:deriv_chart/src/logic/indicators/abstract_indicator.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A helper indicator which gets the close values of List of [Candle]
class CloseValueIndicator extends AbstractIndicator<Candle> {
  /// Initializes
  CloseValueIndicator(List<Candle> candles) : super(candles);

  @override
  Tick getValue(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].close);
}
