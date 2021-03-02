import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Alligator indicator options.
class AlligatorOptions extends IndicatorOptions {
  /// Initializes
  const AlligatorOptions({
    this.jawOffset = 8,
    this.jawPeriod = 13,
    this.teethOffset = 5,
    this.teethPeriod = 8,
    this.lipsOffset = 3,
    this.lipsPeriod = 5,
  }) : super();

  /// Shift to future in jaw series
  final int jawOffset;

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Shift to future in teeth series
  final int teethOffset;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Shift to future in lips series
  final int lipsOffset;

  /// Smoothing period for lips series
  final int lipsPeriod;

  @override
  List<Object> get props =>
      <Object>[
        jawOffset,
        jawPeriod,
        teethOffset,
        teethPeriod,
        lipsOffset,
        lipsPeriod,
      ];
}
