// @dart=2.9

import 'indicator_options.dart';

/// Alligator indicator options.
class AlligatorOptions extends IndicatorOptions {
  /// Initializes
  const AlligatorOptions({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
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
