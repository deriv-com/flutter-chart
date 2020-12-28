import 'package:deriv_chart/src/logic/indicators/indicator.dart';
import 'package:deriv_chart/src/models/candle.dart';
import 'package:deriv_chart/src/models/tick.dart';

/// A helper indicator which gets the close values of List of [Candle]
class CloseValueIndicator extends Indicator<Tick> {
  /// Initializes
  CloseValueIndicator(List<Tick> candles) : super(candles);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].close);
}
