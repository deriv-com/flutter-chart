import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';


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

  /// Sets some variables and paints this [SeriesPainter]'s data.
  void paint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
    required ChartConfig chartConfig,
    required ChartTheme theme,
  }) {
    this.chartConfig = chartConfig;
    this.theme = theme;

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
