import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/chart_scale_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:deriv_chart/src/theme/chart_theme.dart';
import 'package:flutter/material.dart';

import 'series.dart';

/// A class responsible to paint its [series] data.
abstract class SeriesPainter<S extends Series> {
  /// Initializes series for sub-class.
  SeriesPainter(this.series);

  /// The [Series] which this [SeriesPainter] belongs to.
  final S series;

  /// Chart's config.
  @protected
  late ChartConfig chartConfig;

  /// Chart's theme.
  @protected
  late ChartTheme theme;

  /// Chart's scale model.
  @protected
  late ChartScaleModel chartScaleModel;

  /// Sets some variables and paints this [SeriesPainter]'s data.
  void paint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
    required ChartConfig chartConfig,
    required ChartTheme theme,
    required ChartScaleModel chartScaleModel,
  }) {
    this.chartConfig = chartConfig;
    this.theme = theme;
    this.chartScaleModel = chartScaleModel;

    onPaint(
      canvas: canvas,
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );
  }

  /// Paints this [SeriesPainter]'s data.
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  });
}
