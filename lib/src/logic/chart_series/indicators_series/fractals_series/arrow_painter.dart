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
  ArrowPainter(DataSeries<Tick> series, {@required this.isUpward = false})
      : super(series);

  ///show arrow is upward or downward
  final bool isUpward;

  Paint arrowPaint;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final LineStyle style =
        series.style ?? theme.lineStyle ?? const LineStyle();

    arrowPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill
      ..strokeWidth = style.thickness;

    for (int i = series.visibleEntries.startIndex;
        i < series.visibleEntries.endIndex - 1;
        i++) {
      final Tick tick = series.entries[i];
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
    double x,
    double y,
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
    double x,
    double y,
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
}
