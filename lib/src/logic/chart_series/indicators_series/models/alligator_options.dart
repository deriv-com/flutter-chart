import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Alligator indicator options.
class AlligatorOptions extends IndicatorOptions {
  /// Initializes
  const AlligatorOptions({
    // this.jawOffset = 8,
    this.jawPeriod = 13,
    // this.teethOffset = 5,
    this.teethPeriod = 8,
    // this.lipsOffset = 3,
    this.lipsPeriod = 5,
  }) : super();

  /// Smoothing period for jaw series
  final int jawPeriod;

  /// Smoothing period for teeth series
  final int teethPeriod;

  /// Smoothing period for lips series
  final int lipsPeriod;

  @override
  List<Object> get props => <Object>[
        jawPeriod,
        teethPeriod,
        lipsPeriod,
      ];
}
