import 'indicator_options.dart';

/// MACD Options.
class MACDOptions extends IndicatorOptions {
  ///Initializes a MACD Options.
  const MACDOptions({
    this.fastMAPeriod = 12,
    this.slowMAPeriod = 26,
    this.signalPeriod = 9,
  });

  /// The `period` for the `MACDFastMA`. Default is set to `12`.
  final int fastMAPeriod;

  /// The `period` for the `MACDSlowMA`. Default is set to `26`.
  final int slowMAPeriod;

  /// The `period` for the `MACDSignal`. Default is set to `9`.
  final int signalPeriod;

  @override
  List<int> get props => <int>[fastMAPeriod, slowMAPeriod, signalPeriod];
}
