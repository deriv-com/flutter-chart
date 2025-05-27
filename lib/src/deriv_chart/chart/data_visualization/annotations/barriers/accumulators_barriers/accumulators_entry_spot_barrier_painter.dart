import 'dart:ui' as ui;

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_accumulators_entry_spot.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/theme/colors.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/entry_spot_style.dart';
import 'package:flutter/material.dart';

import 'accumulators_entry_spot_barrier.dart';

/// A class for painting horizontal barrier with entry spot.
class AccumulatorsEntrySpotBarrierPainter<
    T extends AccumulatorsEntrySpotBarrier> extends SeriesPainter<T> {
  /// Initializes [series].
  AccumulatorsEntrySpotBarrierPainter(T series) : super(series);

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    if (!series.isOnRange) {
      return;
    }

    final HorizontalBarrierStyle style =
        series.style as HorizontalBarrierStyle? ?? theme.horizontalBarrierStyle;

    final EntrySpotStyle entrySpotStyle = theme.entrySpotStyle;

    double? animatedValue;

    double? dotX;

    // If previous object is null then its first load and no need to perform
    // transition animation from previousObject to new object.
    if (series.previousObject == null) {
      animatedValue = series.quote;
      if (series.epoch != null) {
        dotX = epochToX(series.epoch!);
      }
    } else {
      final BarrierObject previousBarrier = series.previousObject!;
      // Calculating animated values regarding `currentTickPercent` in
      // transition animation
      // from previousObject to new object
      animatedValue = ui.lerpDouble(
        previousBarrier.quote,
        series.quote,
        animationInfo.currentTickPercent,
      );

      if (series.epoch != null && series.previousObject!.leftEpoch != null) {
        dotX = ui.lerpDouble(
          epochToX(series.previousObject!.leftEpoch!),
          epochToX(series.epoch!),
          animationInfo.currentTickPercent,
        );
      }
    }

    final double y = quoteToY(animatedValue!);

    final double lineStartX = dotX ?? 0;
    final double lineEndX =
        series.epoch != null ? epochToX(series.startingEpoch) : 0;

    if (lineStartX > lineEndX && style.hasLine) {
      _paintLine(
          canvas, lineStartX, lineEndX, y, LegacyLightThemeColors.base04);
    }

    _paintEntrySpotDot(canvas, dotX ?? 0, y, entrySpotStyle);
  }

  void _paintEntrySpotDot(
    Canvas canvas,
    double dotX,
    double y,
    EntrySpotStyle style,
  ) {
    paintAccumulatorsEntrySpot(canvas, Offset(dotX, y), style);
  }

  void _paintLine(
    Canvas canvas,
    double mainLineStartX,
    double mainLineEndX,
    double y,
    Color color,
  ) {
    paintHorizontalDashedLine(
      canvas,
      mainLineEndX,
      mainLineStartX,
      y,
      color,
      1,
    );
  }

  @override
  List<CustomPainterSemantics> buildSemantics(
      {required ui.Size size,
      required EpochToX epochToX,
      required QuoteToY quoteToY}) {
    return <CustomPainterSemantics>[];
  }
}
