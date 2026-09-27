import 'dart:ui';

import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/series_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/barrier_objects.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_line.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../chart_data.dart';
import 'vertical_barrier.dart';

/// A class for painting horizontal barriers.
class VerticalBarrierPainter extends SeriesPainter<VerticalBarrier> {
  /// Initializes [series].
  VerticalBarrierPainter(VerticalBarrier series) : super(series);

  /// Calculates the animated epoch based on animation info
  int _calculateAnimatedEpoch(AnimationInfo? animationInfo) {
    if (series.previousObject == null || animationInfo == null) {
      return series.epoch!;
    }

    final VerticalBarrierObject prevObject =
        series.previousObject as VerticalBarrierObject;
    return lerpDouble(prevObject.epoch.toDouble(), series.epoch!,
            animationInfo.currentTickPercent)!
        .toInt();
  }

  /// Calculates the Y position for the dot based on animation info
  double? _calculateDotY(QuoteToY quoteToY, AnimationInfo? animationInfo) {
    if (series.quote == null) return null;

    if (series.previousObject == null || animationInfo == null) {
      return quoteToY(series.quote!);
    }

    final VerticalBarrierObject prevObject =
        series.previousObject as VerticalBarrierObject;
    if (prevObject.quote == null) return null;

    return quoteToY(lerpDouble(prevObject.quote, series.annotationObject.quote,
        animationInfo.currentTickPercent)!);
  }

  /// Calculates line positioning data
  ({double lineX, double lineStartY, double lineEndY}) _calculateLinePositions({
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    AnimationInfo? animationInfo,
  }) {
    final int animatedEpoch = _calculateAnimatedEpoch(animationInfo);
    final double lineX = epochToX(animatedEpoch);
    final double lineEndY = size.height - 20;
    double lineStartY = 0;

    final double? dotY = _calculateDotY(quoteToY, animationInfo);
    if (dotY != null && !series.longLine) {
      lineStartY = dotY;
    }

    return (lineX: lineX, lineStartY: lineStartY, lineEndY: lineEndY);
  }

  /// Creates and layouts the title TextPainter
  TextPainter _createTitlePainter(VerticalBarrierStyle style) {
    return TextPainter(
      text: TextSpan(
        text: series.title,
        style: style.textStyle.copyWith(color: style.color),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Calculates the X position for the title based on label position
  double _calculateTitleStartX(
    double lineX,
    TextPainter titlePainter,
    VerticalBarrierLabelPosition labelPosition,
  ) {
    switch (labelPosition) {
      case VerticalBarrierLabelPosition.auto:
        final double leftPosition = lineX - titlePainter.width - 5;
        return leftPosition < 0 ? lineX + 5 : leftPosition;
      case VerticalBarrierLabelPosition.right:
        return lineX + 5;
      case VerticalBarrierLabelPosition.left:
        return lineX - titlePainter.width - 5;
    }
  }

  @override
  void onPaint({
    required Canvas canvas,
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
    required AnimationInfo animationInfo,
  }) {
    if (!series.isOnRange) return;

    final VerticalBarrierStyle style =
        series.style as VerticalBarrierStyle? ?? theme.verticalBarrierStyle;

    final Paint paint = Paint()
      ..color = style.color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final linePositions = _calculateLinePositions(
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: animationInfo,
    );

    if (style.isDashed) {
      paintVerticalDashedLine(
        canvas,
        linePositions.lineX,
        linePositions.lineStartY,
        linePositions.lineEndY,
        style.color,
        1,
      );
    } else {
      canvas.drawLine(
        Offset(linePositions.lineX, linePositions.lineStartY),
        Offset(linePositions.lineX, linePositions.lineEndY),
        paint,
      );
    }

    _paintLineLabel(canvas, linePositions.lineX, linePositions.lineEndY, style);
  }

  void _paintLineLabel(
    Canvas canvas,
    double lineX,
    double lineEndY,
    VerticalBarrierStyle style,
  ) {
    if (series.title == null || series.title!.isEmpty) return;

    final TextPainter titlePainter = _createTitlePainter(style);
    final double titleStartX = _calculateTitleStartX(
      lineX,
      titlePainter,
      style.labelPosition,
    );

    titlePainter.paint(
      canvas,
      Offset(titleStartX, lineEndY - titlePainter.height),
    );
  }

  @override
  List<CustomPainterSemantics> buildSemantics({
    required Size size,
    required EpochToX epochToX,
    required QuoteToY quoteToY,
  }) {
    if (!series.isOnRange) {
      return <CustomPainterSemantics>[];
    }

    final VerticalBarrierStyle style =
        series.style as VerticalBarrierStyle? ?? theme.verticalBarrierStyle;

    final linePositions = _calculateLinePositions(
      size: size,
      epochToX: epochToX,
      quoteToY: quoteToY,
      animationInfo: null, // No animation for semantics
    );

    final String semanticsLabel =
        series.title != null && series.title!.isNotEmpty
            ? '${series.title} vertical barrier'
            : 'vertical barrier';

    final List<CustomPainterSemantics> semantics = <CustomPainterSemantics>[
      CustomPainterSemantics(
        rect: Rect.fromPoints(
          Offset(linePositions.lineX - 5, linePositions.lineStartY),
          Offset(linePositions.lineX + 5, linePositions.lineEndY),
        ),
        properties: SemanticsProperties(
          label: semanticsLabel,
          textDirection: TextDirection.ltr,
        ),
      ),
    ];

    // Add semantics for the label if it exists
    if (series.title != null && series.title!.isNotEmpty) {
      final TextPainter titlePainter = _createTitlePainter(style);
      final double titleStartX = _calculateTitleStartX(
        linePositions.lineX,
        titlePainter,
        style.labelPosition,
      );

      semantics.add(
        CustomPainterSemantics(
          rect: Rect.fromLTWH(
            titleStartX,
            linePositions.lineEndY - titlePainter.height,
            titlePainter.width,
            titlePainter.height,
          ),
          properties: SemanticsProperties(
            label: '${series.title} label',
            textDirection: TextDirection.ltr,
          ),
        ),
      );
    }

    return semantics;
  }
}
