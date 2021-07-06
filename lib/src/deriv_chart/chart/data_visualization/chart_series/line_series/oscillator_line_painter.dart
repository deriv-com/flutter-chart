import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import 'zones_path_creator.dart';
import 'line_painter.dart';

/// A [LinePainter] for painting line with two main top and bottom horizontal lines.
/// They can have more than 2 lines.
class OscillatorLinePainter extends LinePainter {
  /// Initializes an Oscillator line painter.
  OscillatorLinePainter(
    DataSeries<Tick> series, {
    double? topHorizontalLine,
    double? bottomHorizontalLine,
    this.topHorizontalLinesStyle = const LineStyle(color: Colors.blueGrey),
    this.bottomHorizontalLinesStyle = const LineStyle(color: Colors.blueGrey),
    LineStyle? secondaryHorizontalLinesStyle,
    List<double> secondaryHorizontalLines = const <double>[],
  })  : _topHorizontalLine = topHorizontalLine,
        _secondaryHorizontalLines = secondaryHorizontalLines,
        _secondaryHorizontalLinesStyle = secondaryHorizontalLinesStyle ??
            const LineStyle(color: Colors.blueGrey),
        _bottomHorizontalLine = bottomHorizontalLine,
        super(
          series,
        );

  final double? _topHorizontalLine;
  final double? _bottomHorizontalLine;

  /// Line style of the top horizontal line
  final LineStyle topHorizontalLinesStyle;

  /// Line style of the bottom horizontal line
  final LineStyle bottomHorizontalLinesStyle;

  final List<double> _secondaryHorizontalLines;
  final LineStyle _secondaryHorizontalLinesStyle;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    super.onPaintData(canvas, size, epochToX, quoteToY, animationInfo);

    _paintHorizontalLines(canvas, quoteToY, size);
  }

  @override
  List<DataPathInfo> createPath(
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
    Size size,
  ) {
    final List<DataPathInfo> paths = <DataPathInfo>[];

    if (series.visibleEntries.length < 2) {
      return paths;
    }

    if (_topHorizontalLine == null || _bottomHorizontalLine == null) {
      return super.createPath(epochToX, quoteToY, animationInfo, size);
    }

    final Path dataLinePath = Path();

    double? lastVisibleTickX;

    int i = series.visibleEntries.startIndex;

    final Paint topZonesPaint = Paint()
      ..color = topHorizontalLinesStyle.color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Paint bottomZonesPaint = Paint()
      ..color = bottomHorizontalLinesStyle.color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final TopZonePathCreator topZonePathCreator = TopZonePathCreator(
      series: series,
      lineValue: _topHorizontalLine!,
      canvasSize: size,
      zonePaint: topZonesPaint,
    );

    final BottomZonePathCreator bottomZonePathCreator = BottomZonePathCreator(
      series: series,
      lineValue: _bottomHorizontalLine!,
      canvasSize: size,
      zonePaint: bottomZonesPaint,
    );

    while (series.visibleEntries.isNotEmpty &&
        i < series.visibleEntries.endIndex) {
      final Tick tick = series.entries![i];

      if (tick.quote.isNaN) {
        continue;
      } else if (lastVisibleTickX == null) {
        lastVisibleTickX = epochToX(getEpochOf(tick, i));

        dataLinePath.moveTo(lastVisibleTickX, quoteToY(tick.quote));
      }

      topZonePathCreator.addTick(tick, i, epochToX, quoteToY);
      bottomZonePathCreator.addTick(tick, i, epochToX, quoteToY);

      if (i == series.visibleEntries.endIndex - 1) {
        final Offset? lastVisibleTickPosition =
            calculateLastVisibleTickPosition(
                epochToX, animationInfo, quoteToY, dataLinePath);

        if (lastVisibleTickPosition != null) {
          dataLinePath.lineTo(
              lastVisibleTickPosition.dx, lastVisibleTickPosition.dy);
        }
      } else {
        dataLinePath.lineTo(
            epochToX(getEpochOf(tick, i)), quoteToY(tick.quote));
      }

      i++;
    }

    paths
      ..addAll(topZonePathCreator.paths)
      ..addAll(bottomZonePathCreator.paths);

    final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;
    paths.add(DataPathInfo(
        dataLinePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = style.color
          ..strokeWidth = style.thickness));

    return paths;
  }

  void _paintHorizontalLines(Canvas canvas, QuoteToY quoteToY, Size size) {
    _paintSecondaryHorizontalLines(canvas, quoteToY, size);

    const HorizontalBarrierStyle textStyle =
        HorizontalBarrierStyle(textStyle: TextStyle(fontSize: 10));
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = topHorizontalLinesStyle.thickness;

    if (_topHorizontalLine != null) {
      paint.color = topHorizontalLinesStyle.color;
      canvas.drawLine(
          Offset(0, quoteToY(_topHorizontalLine!)),
          Offset(
              size.width -
                  _labelWidth(_topHorizontalLine!, textStyle.textStyle,
                      chartConfig.pipSize),
              quoteToY(_topHorizontalLine!)),
          paint);
    }

    if (_bottomHorizontalLine != null) {
      paint
        ..color = bottomHorizontalLinesStyle.color
        ..strokeWidth = bottomHorizontalLinesStyle.thickness;

      canvas.drawLine(
          Offset(0, quoteToY(_bottomHorizontalLine!)),
          Offset(
              size.width -
                  _labelWidth(_topHorizontalLine!, textStyle.textStyle,
                      chartConfig.pipSize),
              quoteToY(_bottomHorizontalLine!)),
          paint);
    }

    _paintLabels(size, quoteToY, canvas);
  }

  void _paintSecondaryHorizontalLines(
      Canvas canvas, QuoteToY quoteToY, Size size) {
    final LineStyle horizontalLineStyle = _secondaryHorizontalLinesStyle;
    final Paint horizontalLinePaint = Paint()
      ..color = horizontalLineStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = horizontalLineStyle.thickness;

    for (final double line in _secondaryHorizontalLines) {
      canvas.drawLine(Offset(0, quoteToY(line)),
          Offset(size.width, quoteToY(line)), horizontalLinePaint);
    }
  }

  void _paintLabels(Size size, QuoteToY quoteToY, Canvas canvas) {
    final HorizontalBarrierStyle style = HorizontalBarrierStyle(
      textStyle: TextStyle(fontSize: 10, color: theme.base01Color),
    );

    if (_topHorizontalLine != null) {
      final TextPainter topValuePainter = makeTextPainter(
        _topHorizontalLine!.toStringAsFixed(0),
        style.textStyle,
      );
      final Rect topLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - topValuePainter.width / 2,
            quoteToY(_topHorizontalLine!)),
        width: topValuePainter.width + padding * 2,
        height: style.labelHeight,
      );
      paintWithTextPainter(
        canvas,
        painter: topValuePainter,
        anchor: topLabelArea.center,
      );
    }

    if (_bottomHorizontalLine != null) {
      final TextPainter bottomValuePainter = makeTextPainter(
        _bottomHorizontalLine!.toStringAsFixed(0),
        style.textStyle,
      );

      final Rect bottomLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - bottomValuePainter.width / 2,
            quoteToY(_bottomHorizontalLine!)),
        width: bottomValuePainter.width + padding * 2,
        height: style.labelHeight,
      );

      paintWithTextPainter(
        canvas,
        painter: bottomValuePainter,
        anchor: bottomLabelArea.center,
      );
    }
  }
}

double _labelWidth(double text, TextStyle style, int pipSize) =>
    makeTextPainter(
      text.toStringAsFixed(pipSize),
      style,
    ).width;
