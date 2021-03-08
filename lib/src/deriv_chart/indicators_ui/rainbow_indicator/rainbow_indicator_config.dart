import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/ma_rainbow_series.dart';
import 'package:deriv_chart/src/logic/chart_series/indicators_series/models/rainbow_options.dart';
import 'package:deriv_chart/src/logic/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';

import '../indicator_config.dart';

/// Rainbow Indicator Config
class RainbowIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const RainbowIndicatorConfig({
    int period,
    String movingAverageType,
    String fieldType,
    this.bandsCount,
    this.rainbowColors,
  }) : super(period: period, type: movingAverageType, fieldType: fieldType);

  /// Rainbow Moving Averages bands count
  final int bandsCount;

  final List<Color> rainbowColors;

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      RainbowSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType](indicatorInput),
        rainbowColors: rainbowColors,
        rainbowOptions: RainbowOptions(
          period: period,
          movingAverageType: type,
          bandsCount: bandsCount,
        ),
      );
}
