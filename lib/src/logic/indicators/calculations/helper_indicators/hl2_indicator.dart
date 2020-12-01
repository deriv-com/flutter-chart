import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to get the [(H + L) / 2] value of a list of [Tick]
class HL2Indicator extends AbstractIndicator<Tick> {
  /// Initializes
  HL2Indicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) {
    final Tick entry = entries[index];
    return Tick(
      epoch: getEpochOfIndex(index),
      quote: (entry.high + entry.low) / 2,
    );
  }
}
