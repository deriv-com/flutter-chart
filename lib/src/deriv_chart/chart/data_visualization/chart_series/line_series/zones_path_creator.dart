import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';
import 'line_painter.dart';

/// A class which is responsible to create [DataPathInfo] for oscillators `show zones` option.
abstract class ZonesPathCreator {
  /// Initializes
  ZonesPathCreator({
    required bool isClosedInitially,
    required this.series,
    required this.lineValue,
    required this.canvasSize,
    Paint? zonePaint,
  })  : _paint = zonePaint ??
      (Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white24),
        _paths = <DataPathInfo>[],
        _isClosed = isClosedInitially;

  /// Considers adding a new tick to update the [_areaPath] in the process of
  /// creating current zone [DataPathInfo].
  ///
  /// Once a zone fill area is create, a [DataPathInfo] will be instantiated for it
  /// and will be added to [paths] list.
  void addTick(Tick tick, int index, EpochToX epochToX, QuoteToY quoteToY) {
    _rectPath ??= getLineRect(canvasSize, quoteToY);
    _areaPath ??= Path()..moveTo(0, quoteToY(lineValue));
    _areaPath?.lineTo(
        epochToX(series.getEpochOf(tick, index)), quoteToY(tick.quote));

    if (_isClosed && isOnZoneArea(tick)) {
      _isClosed = false;
    }

    if (!_isClosed && !isOnZoneArea(tick)) {
      _isClosed = true;
      _areaPath?.close();
      _areaPath = Path.combine(PathOperation.intersect, _rectPath!, _areaPath!);

      _paths.add(DataPathInfo(_areaPath!, _paint));
      _areaPath = Path()
        ..moveTo(
            epochToX(series.getEpochOf(tick, index)), quoteToY(tick.quote));
    }

    if (index == series.visibleEntries.endIndex - 1 && !_isClosed) {
      _areaPath!.lineTo(
          epochToX(series.getEpochOf(tick, index)), quoteToY(lineValue));

      _areaPath = Path.combine(PathOperation.intersect, _rectPath!, _areaPath!);

      _paths.add(DataPathInfo(_areaPath!, _paint));
    }
  }

  /// Indicates whether the [tick] is on zones area and should be involved
  /// in creating a zone.
  @protected
  bool isOnZoneArea(Tick tick);

  /// Gets the path of the rectangle that will be intersected with the [_areaPath]
  /// to create the actual fill area path.
  ///
  /// This rectangle somehow represents the horizontal line that we want to get the enclosed
  /// area between this line and [series] data. Since intersection with a line doesn't give
  /// us the desired fill path, we have to intersect the line data path with a rectangle to
  /// get the correct fill area path. The rect's boundaries will be different depending on
  /// whether we're creating the top/bottom zones fill. E.g. for a top zones fill area:
  ///
  ///  _______________________________________
  /// |                                       |
  /// |         The Rectangle                 |
  /// |          ____                         |
  /// |         /####\ intersected fill area  |
  /// ---------------------------------------- -> The horizontal line
  ///    ____/        \___
  ///   /                 \_______ -> The [series] data line
  Path getLineRect(Size canvasSize, QuoteToY quoteToY);

  final Paint _paint;

  final List<DataPathInfo> _paths;

  /// The result paths to be painted as zones fill.
  List<DataPathInfo> get paths => _paths;

  /// The data series which has the entries
  final DataSeries<Tick> series;

  /// The value of the horizontal line.
  final double lineValue;

  /// The size of the canvas.
  final Size canvasSize;

  /// The path of the horizontal line.
  Path? _rectPath;

  Path? _areaPath;
  late bool _isClosed;
}

/// A class to create [DataPathInfo] list for top zones.
class TopZonePathCreator extends ZonesPathCreator {
  /// Initializes.
  TopZonePathCreator({
    required DataSeries<Tick> series,
    required double lineValue,
    required Size canvasSize,
    Paint? zonePaint,
  }) : super(
    isClosedInitially: series.visibleEntries.first.quote < lineValue,
    series: series,
    canvasSize: canvasSize,
    lineValue: lineValue,
    zonePaint: zonePaint,
  );

  @override
  bool isOnZoneArea(Tick tick) => tick.quote >= lineValue;

  @override
  Path getLineRect(Size canvasSize, QuoteToY quoteToY) => Path()
    ..addRect(Rect.fromLTRB(0, 0, canvasSize.width, quoteToY(lineValue)));
}

/// A class to create [DataPathInfo] list for bottom zones.
class BottomZonePathCreator extends ZonesPathCreator {
  /// Initializes.
  BottomZonePathCreator({
    required DataSeries<Tick> series,
    required double lineValue,
    required Size canvasSize,
    Paint? zonePaint,
  }) : super(
    isClosedInitially: series.visibleEntries.first.quote > lineValue,
    series: series,
    canvasSize: canvasSize,
    lineValue: lineValue,
    zonePaint: zonePaint,
  );

  @override
  bool isOnZoneArea(Tick tick) => tick.quote <= lineValue;

  @override
  Path getLineRect(Size canvasSize, QuoteToY quoteToY) => Path()
    ..addRect(
      Rect.fromLTRB(
        0,
        quoteToY(lineValue),
        canvasSize.width,
        canvasSize.height,
      ),
    );
}