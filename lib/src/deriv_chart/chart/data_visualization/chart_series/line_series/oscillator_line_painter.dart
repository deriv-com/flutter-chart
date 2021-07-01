import 'dart:ui';

import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import 'line_painter.dart';

/// A [LinePainter] for painting line with two main top and bottom horizontal lines.
/// They can have more than 2 lines.
class OscillatorLinePainter extends LinePainter {
  /// Initializes an Oscillator line painter.
  OscillatorLinePainter(
    DataSeries<Tick> series, {
    double? topHorizontalLine,
    double? bottomHorizontalLine,
    LineStyle? mainHorizontalLinesStyle,
    LineStyle? secondaryHorizontalLinesStyle,
    List<double> secondaryHorizontalLines = const <double>[],
  })  : _mainHorizontalLinesStyle =
            mainHorizontalLinesStyle ?? const LineStyle(color: Colors.blueGrey),
        _topHorizontalLine = topHorizontalLine,
        _secondaryHorizontalLines = secondaryHorizontalLines,
        _secondaryHorizontalLinesStyle = secondaryHorizontalLinesStyle ??
            const LineStyle(color: Colors.blueGrey),
        _bottomHorizontalLine = bottomHorizontalLine,
        super(
          series,
        );

  final double? _topHorizontalLine;
  final double? _bottomHorizontalLine;
  final LineStyle _mainHorizontalLinesStyle;
  final List<double> _secondaryHorizontalLines;
  final LineStyle _secondaryHorizontalLinesStyle;
  late Path _topHorizontalLinePath;
  late Path _bottomHorizontalLinePath;

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
    final Path topHorizontalLinePath = Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width, quoteToY(_topHorizontalLine!)));

    final Path bottomHorizontalLinePath = Path()
      ..addRect(
        Rect.fromLTRB(
            0, quoteToY(_bottomHorizontalLine!), size.width, size.height),
      );

    double lastVisibleTickX;
    lastVisibleTickX = epochToX(getEpochOf(
        series.visibleEntries.first, series.visibleEntries.startIndex));

    // TODO(NA): Check Nan.
    dataLinePath.moveTo(
      lastVisibleTickX,
      quoteToY(series.visibleEntries.first.quote),
    );

    int i = series.visibleEntries.startIndex;

    Path topAreaPath = Path()..moveTo(0, quoteToY(_topHorizontalLine!));
    final Paint zonePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;

    bool topAreaClosed =
        series.visibleEntries.first.quote < _topHorizontalLine!;

    final UpZonePathCreator upZonePathCreator = UpZonePathCreator(
      series: series,
      lineValue: _topHorizontalLine!,
      linePath: topHorizontalLinePath,
      zonePaint: zonePaint,
    );

    final DownZonePathCreator downZonePathCreator = DownZonePathCreator(
      series: series,
      lineValue: _bottomHorizontalLine!,
      linePath: bottomHorizontalLinePath,
      zonePaint: zonePaint,
    );

    while (series.visibleEntries.isNotEmpty &&
        i < series.visibleEntries.endIndex - 1) {
      final Tick tick = series.entries![i];

      upZonePathCreator.addTick(tick, i, epochToX, quoteToY);
      downZonePathCreator.addTick(tick, i, epochToX, quoteToY);

      // topAreaPath.lineTo(epochToX(getEpochOf(tick, i)), quoteToY(tick.quote));
      dataLinePath.lineTo(epochToX(getEpochOf(tick, i)), quoteToY(tick.quote));

      // if (topAreaClosed && tick.quote > _topHorizontalLine!) {
      //   topAreaClosed = false;
      // }

      // if (!topAreaClosed && tick.quote < _topHorizontalLine!) {
      //   topAreaClosed = true;
      //
      //   topAreaPath.close();
      //
      //   topAreaPath = Path.combine(
      //       PathOperation.intersect, topHorizontalLinePath, topAreaPath);
      //
      //   paths.add(DataPathInfo(topAreaPath, zonePaint));
      //
      //   topAreaPath = Path()
      //     ..moveTo(epochToX(getEpochOf(tick, i)), quoteToY(tick.quote));
      // }

      // if (i == series.visibleEntries.endIndex - 2 && !topAreaClosed) {
      //   topAreaPath.lineTo(
      //       epochToX(getEpochOf(tick, i)), quoteToY(_topHorizontalLine!));
      //
      //   topAreaPath = Path.combine(
      //       PathOperation.intersect, topHorizontalLinePath, topAreaPath);
      //
      //   paths.add(DataPathInfo(topAreaPath, zonePaint));
      // }

      i++;
    }

    paths..addAll(upZonePathCreator._path)..addAll(downZonePathCreator._path);

    final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;
    paths.add(DataPathInfo(
        dataLinePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = style.color
          ..strokeWidth = style.thickness));

    // // Adding visible entries line to the path except the last which might be animated.
    // for (int i = series.visibleEntries.startIndex;
    //     i < series.visibleEntries.endIndex - 1;
    //     i++) {
    //   final Tick tick = series.entries![i];
    //
    //   if (!tick.quote.isNaN) {
    //     final double y = quoteToY(tick.quote);
    //     dataLinePath.lineTo(lastVisibleTickX, y);
    //   }
    // }
    //
    // _lastVisibleTickX = _calculateLastVisibleTick(
    //     epochToX, animationInfo, quoteToY, dataLinePath);
    //
    // final LineStyle style = series.style as LineStyle? ?? theme.lineStyle;
    //
    // final Paint linePaint = Paint()
    //   ..color = style.color
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = style.thickness;
    //
    // paths.add(DataPathInfo(dataLinePath, linePaint));

    return paths;
  }

  void _paintHorizontalLines(Canvas canvas, QuoteToY quoteToY, Size size) {
    _paintSecondaryHorizontalLines(canvas, quoteToY, size);

    const HorizontalBarrierStyle textStyle =
        HorizontalBarrierStyle(textStyle: TextStyle(fontSize: 10));
    final Paint paint = Paint()
      ..color = _mainHorizontalLinesStyle.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _mainHorizontalLinesStyle.thickness;

    _topHorizontalLinePath = Path();
    _bottomHorizontalLinePath = Path();

    if (_topHorizontalLine != null) {
      _topHorizontalLinePath
        ..moveTo(0, quoteToY(_topHorizontalLine!))
        ..lineTo(
            size.width -
                _labelWidth(_topHorizontalLine!, textStyle.textStyle,
                    chartConfig.pipSize),
            quoteToY(_topHorizontalLine!));

      canvas.drawPath(_topHorizontalLinePath, paint);
    }

    if (_bottomHorizontalLine != null) {
      _bottomHorizontalLinePath
        ..moveTo(0, quoteToY(_bottomHorizontalLine!))
        ..lineTo(
            size.width -
                _labelWidth(_topHorizontalLine!, textStyle.textStyle,
                    chartConfig.pipSize),
            quoteToY(_bottomHorizontalLine!));

      canvas.drawPath(_bottomHorizontalLinePath, paint);
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

// TODO(mohammadamir-fs): add channel fill.
}

double _labelWidth(double text, TextStyle style, int pipSize) =>
    makeTextPainter(
      text.toStringAsFixed(pipSize),
      style,
    ).width;

/// A class which is responsible to create [DataPathInfo] for oscillators `show zones` option.
abstract class ZonesPathCreator {
  /// Initializes
  ZonesPathCreator({
    required bool isClosedInitially,
    required this.series,
    required this.lineValue,
    required this.linePath,
    Paint? zonePaint,
  })  : _paint = zonePaint ?? Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white24,
        _path = <DataPathInfo>[],
        _isClosed = isClosedInitially;

  /// Considers adding a new tick to update the [_areaPath] in the process of
  /// creating current zone [DataPathInfo].
  void addTick(Tick tick, int index, EpochToX epochToX, QuoteToY quoteToY) {
    _areaPath ??= Path()..moveTo(0, quoteToY(lineValue));
    _areaPath?.lineTo(
        epochToX(series.getEpochOf(tick, index)), quoteToY(tick.quote));

    if (_isClosed && isOverZoneArea(tick)) {
      _isClosed = false;
    }

    if (!_isClosed && !isOverZoneArea(tick)) {
      _isClosed = true;

      _areaPath?.close();

      _areaPath = Path.combine(PathOperation.intersect, linePath, _areaPath!);

      _path.add(DataPathInfo(_areaPath!, _paint));

      _areaPath = Path()
        ..moveTo(
            epochToX(series.getEpochOf(tick, index)), quoteToY(tick.quote));
    }

    if (index == series.visibleEntries.endIndex - 2 && !_isClosed) {
      _areaPath!.lineTo(
          epochToX(series.getEpochOf(tick, index)), quoteToY(lineValue));

      _areaPath = Path.combine(PathOperation.intersect, linePath, _areaPath!);

      _path.add(DataPathInfo(_areaPath!, _paint));
    }
  }

  /// Indicators whether the [tick] is on zones area and should be involved
  /// in creating a zone.
  @protected
  bool isOverZoneArea(Tick tick);

  final Paint _paint;
  final List<DataPathInfo> _path;
  Path? _areaPath;
  late bool _isClosed;
  final DataSeries<Tick> series;
  final double lineValue;
  final Path linePath;
}

///
class UpZonePathCreator extends ZonesPathCreator {
  ///
  UpZonePathCreator({
    required DataSeries<Tick> series,
    required double lineValue,
    required Path linePath,
    Paint? zonePaint,
  }) : super(
          isClosedInitially: series.visibleEntries.first.quote < lineValue,
          series: series,
          lineValue: lineValue,
          linePath: linePath,
          zonePaint: zonePaint,
        );

  @override
  bool isOverZoneArea(Tick tick) => tick.quote >= lineValue;
}

///
class DownZonePathCreator extends ZonesPathCreator {
  ///
  DownZonePathCreator({
    required DataSeries<Tick> series,
    required double lineValue,
    required Path linePath,
    Paint? zonePaint,
  }) : super(
          isClosedInitially: series.visibleEntries.first.quote > lineValue,
          series: series,
          lineValue: lineValue,
          linePath: linePath,
          zonePaint: zonePaint,
        );

  @override
  bool isOverZoneArea(Tick tick) => tick.quote <= lineValue;
}
