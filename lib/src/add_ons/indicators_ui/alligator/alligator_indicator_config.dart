import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/alligator_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indicators_series/models/alligator_options.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series.dart';
import 'package:deriv_chart/src/models/indicator_input.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../callbacks.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'alligator_indicator_item.dart';

part 'alligator_indicator_config.g.dart';

/// Bollinger Bands Indicator Config
@JsonSerializable()
class AlligatorIndicatorConfig extends IndicatorConfig {
  /// Initializes
  const AlligatorIndicatorConfig({
    this.jawPeriod = 13,
    this.teethPeriod = 8,
    this.lipsPeriod = 5,
    this.jawOffset = 8,
    this.teethOffset = 5,
    this.lipsOffset = 3,
    this.showLines = true,
    this.showFractal = false,
    this.jawLineStyle = const LineStyle(color: Colors.blue),
    this.teethLineStyle = const LineStyle(color: Colors.red),
    this.lipsLineStyle = const LineStyle(color: Colors.green),
    bool showLastIndicator = false,
    String? title,
    super.number,
    super.pipSize,
  }) : super(
          showLastIndicator: showLastIndicator,
          title: title ?? AlligatorIndicatorConfig.name,
        );

  /// Initializes from JSON.
  factory AlligatorIndicatorConfig.fromJson(Map<String, dynamic> json) =>
      _$AlligatorIndicatorConfigFromJson(json);

  /// Unique name for this indicator.
  static const String name = 'alligator';

  @override
  Map<String, dynamic> toJson() => _$AlligatorIndicatorConfigToJson(this)
    ..putIfAbsent(IndicatorConfig.nameKey, () => name);

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

  /// show alligator lins  or not
  final bool showLines;

  /// show fractal indicator or not
  final bool showFractal;

  /// Jaw line style.
  final LineStyle jawLineStyle;

  /// Teeth line style.
  final LineStyle teethLineStyle;

  /// Lips line style.
  final LineStyle lipsLineStyle;

  @override
  Series getSeries(IndicatorInput indicatorInput) => AlligatorSeries(
        indicatorInput,
        alligatorOptions: AlligatorOptions(
          jawPeriod: jawPeriod,
          teethPeriod: teethPeriod,
          lipsPeriod: lipsPeriod,
          showLines: showLines,
          showFractal: showFractal,
          jawOffset: jawOffset,
          teethOffset: teethOffset,
          lipsOffset: lipsOffset,
          jawLineStyle: jawLineStyle,
          teethLineStyle: teethLineStyle,
          lipsLineStyle: lipsLineStyle,
          showLastIndicator: showLastIndicator,
        ),
      );

  @override
  IndicatorItem getItem(
    UpdateIndicator updateIndicator,
    VoidCallback deleteIndicator,
  ) =>
      AlligatorIndicatorItem(
        config: this,
        updateIndicator: updateIndicator,
        deleteIndicator: deleteIndicator,
      );

  @override
  AlligatorIndicatorConfig copyWith({
    int? jawPeriod,
    int? teethPeriod,
    int? lipsPeriod,
    int? jawOffset,
    int? teethOffset,
    int? lipsOffset,
    bool? showLines,
    bool? showFractal,
    LineStyle? jawLineStyle,
    LineStyle? teethLineStyle,
    LineStyle? lipsLineStyle,
    bool? showLastIndicator,
    String? title,
    int? pipSize,
    int? number,
  }) =>
      AlligatorIndicatorConfig(
        jawPeriod: jawPeriod ?? this.jawPeriod,
        teethPeriod: teethPeriod ?? this.teethPeriod,
        lipsPeriod: lipsPeriod ?? this.lipsPeriod,
        jawOffset: jawOffset ?? this.jawOffset,
        teethOffset: teethOffset ?? this.teethOffset,
        lipsOffset: lipsOffset ?? this.lipsOffset,
        showLines: showLines ?? this.showLines,
        showFractal: showFractal ?? this.showFractal,
        jawLineStyle: jawLineStyle ?? this.jawLineStyle,
        teethLineStyle: teethLineStyle ?? this.teethLineStyle,
        lipsLineStyle: lipsLineStyle ?? this.lipsLineStyle,
        showLastIndicator: showLastIndicator ?? this.showLastIndicator,
        title: title ?? this.title,
        number: number ?? this.number,
        pipSize: pipSize ?? this.pipSize,
      );
}
