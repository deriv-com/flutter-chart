import 'indicator_options.dart';

/// Alligator indicator options.
class AlligatorOptions extends IndicatorOptions {
  /// Initializes
  const AlligatorOptions({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.showLines = true,
    this.showFractal = false,
  }) : super();

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Smoothing period for lips series
  final int lipsPeriod;

  /// show alligator lins  or not
  final bool showLines;

  /// show fractal indicator or not
  final bool showFractal;

  @override
  List<Object> get props => <Object>[
        jawPeriod,
        teethPeriod,
        lipsPeriod,
        showLines,
        showFractal,
      ];
}
