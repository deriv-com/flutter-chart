import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Moving Average Envelope indicator options.
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

  ///
  final int jawOffset;
  ///
  final int jawPeriod;
  ///
  final int teethOffset;
  ///
  final int teethPeriod;
  ///
  final int lipsOffset;
  ///
  final int lipsPeriod;

  @override
  List<Object> get props => <Object>[
        jawOffset,
        jawPeriod,
        teethOffset,
        teethPeriod,
        lipsOffset,
        lipsPeriod,
      ];
}
