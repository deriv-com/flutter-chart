import 'package:deriv_technical_analysis/src/indicators/indicator.dart';
import 'package:deriv_technical_analysis/src/models/ohlc.dart';
import 'package:deriv_technical_analysis/src/models/tick.dart';

/// A helper indicator which gets the close values of List of [OHLC]
class CloseValueIndicator extends Indicator {
  /// Initializes
  CloseValueIndicator(List<OHLC> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: getEpochOfIndex(index), quote: entries[index].close);
}
