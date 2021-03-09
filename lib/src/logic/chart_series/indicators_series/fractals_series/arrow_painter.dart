import 'dart:ui' as ui;

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/logic/chart_data.dart';
import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/paint/create_shape_path.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';


/// A [DataPainter] for painting arrow data.
class ArrowPainter extends DataPainter<DataSeries<Tick>> {

  /// Initializes
  ArrowPainter(DataSeries<Tick> series, this.isUpward) : super(series);

  ///show arrow is upward or downward
  bool isUpward=false;

  @override
  void onPaintData(Canvas canvas,
      Size size,
      EpochToX epochToX,
      QuoteToY quoteToY,
      AnimationInfo animationInfo,) {
    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Tick tick = series.visibleEntries[i];
      if(tick.quote.isNaN){
        break;
      }
      if (isUpward) {
        _paintUpwardArrows(
            canvas, x: epochToX(getEpochOf(tick)), y: quoteToY(tick.quote));
      }
      else {
        _paintDownwardArrows(
            canvas, x: epochToX(getEpochOf(tick)), y: quoteToY(tick.quote));
      }
    }
  }

  void _paintUpwardArrows(Canvas canvas, {
    double x,
    double y,
    double arrowSize,
  }) {
    final LineStyle style =
        series.style ?? theme.lineStyle ?? const LineStyle();

    final Paint arrowPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;


    canvas..drawPath(
        getUpwardArrowPath(
          x,
          y + arrowSize - 1,
          size: arrowSize,
        ),
        arrowPaint)..drawPath(
        getUpwardArrowPath(
          x,
          y,
          size: arrowSize,
        ),
        arrowPaint..color = style.color.withOpacity(0.64))..drawPath(
        getUpwardArrowPath(
          x,
          y - arrowSize + 1,
          size: arrowSize,
        ),
        arrowPaint..color = style.color.withOpacity(0.32));
  }

  void _paintDownwardArrows(Canvas canvas, {
    double x,
    double y,
    double arrowSize,
  }) {
    final LineStyle style =
        series.style ?? theme.lineStyle ?? const LineStyle();

    final Paint arrowPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    canvas..drawPath(
        getDownwardArrowPath(
          x,
          y - arrowSize + 1,
          size: arrowSize,
        ),
        arrowPaint)..drawPath(
        getDownwardArrowPath(
          x,
          y,
          size: arrowSize,
        ),
        arrowPaint..color = style.color.withOpacity(0.64))..drawPath(
        getDownwardArrowPath(
          x,
          y + arrowSize - 1,
          size: arrowSize,
        ),
        arrowPaint..color = style.color.withOpacity(0.32));
  }

}
