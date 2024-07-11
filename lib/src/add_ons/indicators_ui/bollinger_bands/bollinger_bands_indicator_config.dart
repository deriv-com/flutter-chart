import 'package:deriv_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/bollinger_bands_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/ma_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/bollinger_bands_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/color_converter.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'bollinger_bands_indicator_item.dart';

part 'bollinger_bands_indicator_config.g.dart';

/// Bollinger Bands Indicator Config
@JsonSerializable()
@ColorConverter()
class BollingerBandsIndicatorConfig extends MAIndicatorConfig {
  /// Initializes
  const BollingerBandsIndicatorConfig({
    int period = 50,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    String fieldType = 'close',
    this.standardDeviation = 2,
    this.upperLineStyle = const LineStyle(color: Colors.white),
    this.middleLineStyle = const LineStyle(color: Colors.white),
    this.lowerLineStyle = const LineStyle(color: Colors.white),
    this.fillColor = Colors.white12,
    this.showChannelFill = true,
    bool showLastIndicator = false,
  }) : super(
          period: period,
          movingAverageType: movingAverageType,
          fieldType: fieldType,
          showLastIndicator: showLastIndicator,
        );

  /// Initializes from JSON.
  factory BollingerBandsIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$BollingerBandsIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'bollinger_bands';

  @override
  Map<String, dynamic> toJson() => _$BollingerBandsIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

  /// Standard Deviation value
  final double standardDeviation;

  /// Upper line style.
  final LineStyle upperLineStyle;

  /// Middle line style.
  final LineStyle middleLineStyle;

  /// Lower line style.
  final LineStyle lowerLineStyle;

  /// Fill color.
  final Color fillColor;

  /// Whether the area between upper and lower channel is filled.
  final bool showChannelFill;

  @override
  String get displayTitle => 'BB';

  @override
  String get configSummary =>
      '$period, ${fieldType.characters.first.toUpperCase()}, '
      '$standardDeviation, ${movingAverageType.shortTitle}, '
      '${showChannelFill ? 'Y' : 'N'}';

  @override
  Series getSeries(IndicatorInput indicatorInput) =>
      BollingerBandSeries.fromIndicator(
        IndicatorConfig.supportedFieldTypes[fieldType]!(indicatorInput),
        bbOptions: BollingerBandsOptions(
          period: period,
          movingAverageType: movingAverageType,
          standardDeviationFactor: standardDeviation,
          upperLineStyle: upperLineStyle,
          middleLineStyle: middleLineStyle,
          lowerLineStyle: lowerLineStyle,
          fillColor: fillColor,
          showChannelFill: showChannelFill,
          showLastIndicator: showLastIndicator,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      BollingerBandsIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );
}
