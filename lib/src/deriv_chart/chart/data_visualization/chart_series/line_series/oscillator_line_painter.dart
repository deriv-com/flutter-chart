import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/helpers/combine_paths.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/barrier_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import 'line_painter.dart';

/// A [LinePainter] for painting line with two main top and bottom
/// horizontal lines. They can have more than 2 lines.
class OscillatorLinePainter extends LinePainter {
  /// Initializes an Oscillator line painter.
  OscillatorLinePainter(
    DataSeries<Tick> series, {
    double? topHorizontalLine,
    double? bottomHorizontalLine,
    this.topHorizontalLinesStyle = const LineStyle(color: Colors.blueGrey),
    this.bottomHorizontalLinesStyle = const LineStyle(color: Colors.blueGrey),
    this.labelStyle = const HorizontalBarrierStyle(
      textStyle: TextStyle(fontSize: 10, color: Color(0xFF0E0E0E)),
    ),
    LineStyle? secondaryHorizontalLinesStyle,
    List<double> secondaryHorizontalLines = const <double>[],
  })  : _topHorizontalLine = topHorizontalLine,
        _secondaryHorizontalLines = secondaryHorizontalLines,
        _secondaryHorizontalLinesStyle = secondaryHorizontalLinesStyle ??
            const LineStyle(color: Colors.blueGrey),
        _bottomHorizontalLine = bottomHorizontalLine,
        _topZonesPaint = Paint()
          ..color = topHorizontalLinesStyle.color.withOpacity(0.5)
          ..style = PaintingStyle.fill,
        _bottomZonesPaint = Paint()
          ..color = bottomHorizontalLinesStyle.color.withOpacity(0.5)
          ..style = PaintingStyle.fill,
        super(series);

  final double? _topHorizontalLine;
  final double? _bottomHorizontalLine;

  /// Line style of the top horizontal line
  final LineStyle topHorizontalLinesStyle;

  /// Line style of the bottom horizontal line
  final HorizontalBarrierStyle labelStyle;

  /// Line style of the bottom horizontal line
  final LineStyle bottomHorizontalLinesStyle;

  final List<double> _secondaryHorizontalLines;
  final LineStyle _secondaryHorizontalLinesStyle;

  /// Padding between lines.
  static const double padding = 4;

  /// Right margin.
  static const double rightMargin = 4;

  Paint? _linePaint;
  final Paint _topZonesPaint;
  final Paint _bottomZonesPaint;

  @override
  void onPaintData(
    Canvas canvas,
    Size size,
    EpochToX epochToX,
    QuoteToY quoteToY,
    AnimationInfo animationInfo,
  ) {
    final DataLinePathInfo linePath =
        createPath(epochToX, quoteToY, animationInfo);

    final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;

    _linePaint ??= Paint()
      ..color = style.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.thickness;

    canvas.drawPath(linePath.path, _linePaint!);

    if (_topHorizontalLine != null) {
      Path topIntersections;

      if (kIsWeb) {
        final List<Tick> horizontalLineEntries = series.entries!
            .map((Tick entry) =>
                Tick(epoch: entry.epoch, quote: _topHorizontalLine!))
            .toList();
        topIntersections = combinePaths(
          series,
          series.entries ?? <Tick>[],
          horizontalLineEntries,
          epochToX,
          quoteToY,
        ).$1;
      } else {
        final Path bottomAreaPath = Path.from(linePath.path)
          ..lineTo(linePath.endPosition.dx, size.height)
          ..lineTo(linePath.startPosition.dx, size.height);
        final Path topRect = Path()
          ..addRect(
            Rect.fromLTRB(
              linePath.startPosition.dx,
              0,
              linePath.endPosition.dx,
              quoteToY(_topHorizontalLine!),
            ),
          );

        topIntersections =
            Path.combine(PathOperation.intersect, bottomAreaPath, topRect);
      }

      canvas.drawPath(topIntersections, _topZonesPaint);
    }

    if (_bottomHorizontalLine != null) {
      Path bottomIntersection;

      if (kIsWeb) {
        final List<Tick> horizontalLineEntries = series.entries!
            .map((Tick entry) =>
                Tick(epoch: entry.epoch, quote: _bottomHorizontalLine!))
            .toList();

        bottomIntersection = combinePaths(
          series,
          series.entries ?? <Tick>[],
          horizontalLineEntries,
          epochToX,
          quoteToY,
        ).$2;
      } else {
        final Path topAreaPath = Path.from(linePath.path)
          ..lineTo(linePath.endPosition.dx, 0)
          ..lineTo(linePath.startPosition.dx, 0);
        final Path bottomRect = Path()
          ..addRect(
            Rect.fromLTRB(
              linePath.startPosition.dx,
              quoteToY(_bottomHorizontalLine!),
              linePath.endPosition.dx,
              size.height,
            ),
          );
        bottomIntersection =
            Path.combine(PathOperation.intersect, topAreaPath, bottomRect);
      }

      canvas.drawPath(bottomIntersection, _bottomZonesPaint);
    }

    _paintHorizontalLines(canvas, quoteToY, size);
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
                  labelWidth(_topHorizontalLine!, textStyle.textStyle,
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
                  labelWidth(_topHorizontalLine!, textStyle.textStyle,
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
    if (_topHorizontalLine != null) {
      final TextPainter topValuePainter = makeTextPainter(
        _topHorizontalLine!.toStringAsFixed(0),
        labelStyle.textStyle,
      );
      final Rect topLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - topValuePainter.width / 2,
            quoteToY(_topHorizontalLine!)),
        width: topValuePainter.width + padding * 2,
        height: labelStyle.labelHeight,
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
        labelStyle.textStyle,
      );

      final Rect bottomLabelArea = Rect.fromCenter(
        center: Offset(
            size.width - rightMargin - padding - bottomValuePainter.width / 2,
            quoteToY(_bottomHorizontalLine!)),
        width: bottomValuePainter.width + padding * 2,
        height: labelStyle.labelHeight,
      );

      paintWithTextPainter(
        canvas,
        painter: bottomValuePainter,
        anchor: bottomLabelArea.center,
      );
    }
  }
}
