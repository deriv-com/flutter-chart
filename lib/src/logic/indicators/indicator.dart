import 'package:deriv_chart/src/models/tick.dart';

/// An indicator
abstract class Indicator {
  /// Value of the indicator for the given [index].
  Tick getValue(int index);
}
