import 'indicator_options.dart';

/// Alligator indicator options.
class GatorOptions extends IndicatorOptions {
  /// Initializes
  const GatorOptions({
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
