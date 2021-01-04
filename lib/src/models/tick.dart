import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'ohlc.dart';

/// Basic data entry.
@immutable
class Tick with EquatableMixin implements OHLC {
  /// Initializes
  const Tick({
    @required this.epoch,
    @required this.quote,
  });

  /// Epoch of the tick
  final int epoch;

  /// Tick price
  final double quote;

  @override
  double get close => quote;

  @override
  double get high => quote;

  @override
  double get low => quote;

  @override
  double get open => quote;

  List<Object> get props => [epoch, quote];
}
