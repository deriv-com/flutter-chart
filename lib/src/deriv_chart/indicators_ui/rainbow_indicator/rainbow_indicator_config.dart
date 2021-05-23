import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/ma_rainbow_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/indicators_series/models/rainbow_options.dart';
import 'package:deriv_chart/src/middle_layer/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'rainbow_indicator_item.dart';

part 'rainbow_indicator_config.g.dart';

/// Rainbow Indicator Config
@JsonSerializable()
class RainbowIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  RainbowIndicatorConfig({
    int period,
    MovingAverageType movingAverageType,
    String fieldType,
    int bandsCount,
  })  : bandsCount = bandsCount ?? 10,
        rainbowColors = _getRainbowColors(bandsCount ?? 10),
        super(
          period: period,
          movingAverageType: movingAverageType,
          fieldType: fieldType,
        );

  /// Initializes from JSON.
  factory RainbowIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$RainbowIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'rainbow';

  /// Calculate the color of Rainbow and return list of colors
  static List<Color> _getRainbowColors(int bands) {
    const int minHue = 240, maxHue = 0;
    final List<Color> rainbow = <Color>[];
    for (int i = 0; i < bands; i++) {
      final double curPercent = i / bands;
      final HSLColor bandColor = HSLColor.fromAHSL(
          1, (curPercent * (maxHue - minHue)) + minHue, 1, 0.5);
      rainbow.add(bandColor.toColor());
    }
    return rainbow;
  }

  @override
  Map<String, dynamic> toJson() => _$RainbowIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

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
          movingAverageType: movingAverageType,
          bandsCount: bandsCount,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      RainbowIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
