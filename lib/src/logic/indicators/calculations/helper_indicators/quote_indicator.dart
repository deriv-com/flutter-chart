import 'package:deriv_chart/src/models/tick.dart';

import '../../abstract_indicator.dart';

/// A helper indicator to get the quote values of a list of [Tick].
class QuoteIndicator extends AbstractIndicator<Tick> {
  /// Initializes
  QuoteIndicator(List<Tick> entries) : super(entries);

  @override
  Tick getValue(int index) =>
      Tick(epoch: entries[index].epoch, quote: entries[index].quote);
}
