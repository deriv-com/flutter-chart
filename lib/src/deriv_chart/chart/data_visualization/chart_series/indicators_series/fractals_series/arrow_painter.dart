import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/data_series.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/create_shape_path.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../data_painter.dart';

/// A [DataPainter] for painting arrow data.
class ArrowPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  ArrowPainter(DataSeries<Tick> series, {this.isUpward = false})
      : super(series);

  /// Show arrow is upward or downward
  final bool isUpward;

  /// Paint the arrow on the canvas
  late Paint arrowPaint;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    if (series.entries == null) {
      return;
    }

    final LineStyle style = (series.style as LineStyle?) ?? theme.lineStyle;

    arrowPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill
      ..strokeWidth = style.thickness;

    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries![i];
      if (tick.quote.isNaN) {
        continue;
      }
      if (isUpward) {
        _paintUpwardArrows(
          canvas,
          x: epochToX(getEpochOf(tick, i)),
          y: quoteToY(tick.quote),
        );
      } else {
        _paintDownwardArrows(
          canvas,
          x: epochToX(getEpochOf(tick, i)),
          y: quoteToY(tick.quote),
        );
      }
    }
  }

  void _paintUpwardArrows(
    Canvas canvas, {
    required double x,
    required double y,
    double arrowSize = 10,
  }) {
    canvas.drawPath(
        getUpwardArrowPath(
          x,
          y - arrowSize,
          size: arrowSize,
        ),
        arrowPaint);
  }

  void _paintDownwardArrows(
    Canvas canvas, {
    required double x,
    required double y,
    double arrowSize = 10,
  }) {
    canvas.drawPath(
        getDownwardArrowPath(
          x,
          y + arrowSize,
          size: arrowSize,
        ),
        arrowPaint);
  }

  @override
  List<CustomPainterSemantics> buildSemantics(
      {required Size size,
      required EpochToX epochToX,
      required QuoteToY quoteToY}) {
    return <CustomPainterSemantics>[];
  }
}
