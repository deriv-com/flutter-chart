import 'dart:ui' as ui;

import 'package:deriv_chart/src/logic/chart_series/data_painter.dart';
import 'package:deriv_chart/src/logic/chart_series/data_series.dart';
import 'package:deriv_chart/src/logic/chart_series/line_series/line_painter.dart';
import 'package:deriv_chart/src/models/animation_info.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/material.dart';

import '../../../chart_data.dart';

/// A [DataPainter] for painting line data.
class ZigZagPainter extends DataPainter<DataSeries<Tick>> {
  /// Initializes
  ZigZagPainter(DataSeries<Tick> series) : super(series);

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

    final Paint linePaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    final Path path = Path();

    bool isStartPointSet = false;

    if (series.visibleEntries.first.quote.isNaN) {
      var x = series.entries.indexOf(series.visibleEntries.first);
      Tick firstPoint;
      var y = 0.0;
      for (int i = x - 1; i >= 0; i--) {
        if (!series.entries[i].quote.isNaN) {
          firstPoint = series.entries[i];
          Tick lastPoint;
          for (int j = i + 1; j < series.entries.length; j++) {
            if (!series.entries[j].quote.isNaN) {
              lastPoint = series.entries[j];
              break;
            }
          }
          y = ((lastPoint.quote - firstPoint.quote) /
                  (lastPoint.epoch - firstPoint.epoch) *
                  (series.visibleEntries.first.epoch - lastPoint.epoch)) +
              lastPoint.quote;
          break;
        }
      }
      series.visibleEntries.first =
          Tick(epoch: series.visibleEntries.first.epoch, quote: y);
    }

    if (series.visibleEntries.last.quote.isNaN) {
      var x = series.entries.indexOf(series.visibleEntries.last);
      Tick firstPoint;
      var y = 0.0;
      for (int i = x + 1; i <= series.entries.length; i++) {
        if (!series.entries[i].quote.isNaN) {
          firstPoint = series.entries[i];
          Tick lastPoint;
          for (int j = i - 1; j >= 0; j--) {
            if (!series.entries[j].quote.isNaN) {
              lastPoint = series.entries[j];
              break;
            }
          }
          y = ((lastPoint.quote - firstPoint.quote) /
                  (lastPoint.epoch - firstPoint.epoch) *
                  (series.visibleEntries.last.epoch - lastPoint.epoch)) +
              lastPoint.quote;

          break;
        }
      }
      series.visibleEntries.last =
          Tick(epoch: series.visibleEntries.last.epoch, quote: y);
    }

    // Adding visible entries line to the path except the last which might be animated.
    for (int i = 0; i < series.visibleEntries.length - 1; i++) {
      final Tick tick = series.visibleEntries[i];

      if (!tick.quote.isNaN) {
        if (!isStartPointSet) {
          isStartPointSet = true;
          path.moveTo(epochToX(tick.epoch), quoteToY(tick.quote));
          continue;
        }

        final double x = epochToX(tick.epoch);
        final double y = quoteToY(tick.quote);
        path.lineTo(x, y);
      }
    }

    // Adding last visible entry line to the path
    final Tick lastTick = series.entries.last;
    final Tick lastVisibleTick = series.visibleEntries.last;
    double lastVisibleTickX;

    if (lastTick == lastVisibleTick && series.prevLastEntry != null) {
      lastVisibleTickX = ui.lerpDouble(
        epochToX(series.prevLastEntry.epoch),
        epochToX(lastTick.epoch),
        animationInfo.currentTickPercent,
      );

      final double tickY = quoteToY(ui.lerpDouble(
        series.prevLastEntry.quote,
        lastTick.quote,
        animationInfo.currentTickPercent,
      ));

      path.lineTo(lastVisibleTickX, tickY);
    } else {
      lastVisibleTickX = epochToX(lastVisibleTick.epoch);
      path.lineTo(lastVisibleTickX, quoteToY(lastVisibleTick.quote));
    }

    canvas.drawPath(path, linePaint);
  }
}
