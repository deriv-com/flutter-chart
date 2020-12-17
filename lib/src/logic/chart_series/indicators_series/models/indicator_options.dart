import 'package:equatable/equatable.dart';

import '../ma_series.dart';

abstract class IndicatorOptions extends Equatable {}

class MAOptions extends IndicatorOptions {
  MAOptions(this.period, this.type);

  final int period;
  final MovingAverageType type;

  @override
  List<Object> get props => [period, type];
}
