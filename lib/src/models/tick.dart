// @dart=2.9

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Basic data entry.
// Since we have field option in indicators menu (Close, High, Hl2, etc),
// and since sometimes we have Tick data and sometimes Candle, We didn't want us
// to have to check if it is a <Tick>[] use something like QuoteIndicator(ticks)
// as input for Indicators that do the calculation and if it's a <Candle>[] use
// Close|High|Hl2|ValueIndicator(ticks).
// To avoid doing this check, we made Tick class comply with OHLC interface. So we
// can use either <Tick>[] or <Candle>[] as input for Close|High|Hl2|ValueIndicators.
@immutable
class Tick with EquatableMixin implements IndicatorOHLC, IndicatorResult {
  /// Initializes
  const Tick({
    @required this.epoch,
    @required this.quote,
  });

  /// Epoch of the tick
  final int epoch;

  /// Tick price
  @override
  final double quote;

  @override
  double get close => quote;

  @override
  double get high => quote;

  @override
  double get low => quote;

  @override
  double get open => quote;

  @override
  List<Object> get props => <Object>[epoch, quote];
}
