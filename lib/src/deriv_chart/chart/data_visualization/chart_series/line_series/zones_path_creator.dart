import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_series/indexed_entry.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';

import '../../chart_data.dart';
import '../data_series.dart';

/// A class which is responsible to create [DataPathInfo] for oscillators `show zones` option.
abstract class ZonesPathCreator {
  /// Initializes
  ZonesPathCreator({
    required this.series,
    required this.lineValue,
    required this.canvasSize,
    Paint? zonePaint,
  })  : _paint = zonePaint ??
            (Paint()
              ..style = PaintingStyle.fill
              ..color = Colors.white24),
        _paths = <DataPathInfo>[] {
    _firstNonNanTick = _findFirstNonNanTick();

    _isClosed = _isClosedInitially = !isOnZoneArea(_firstNonNanTick.entry);
  }

  IndexedEntry<Tick> _findFirstNonNanTick() {
    int index = series.visibleEntries.startIndex;
    IndexedEntry<Tick> firstNonNanTick =
        IndexedEntry<Tick>(series.visibleEntries.first, index);
    while (firstNonNanTick.entry.quote.isNaN &&
        index < series.visibleEntries.endIndex) {
      index++;
      firstNonNanTick =
          IndexedEntry<Tick>(series.visibleEntries.entries[index], index);
    }

    return firstNonNanTick;
  }

  late IndexedEntry<Tick> _firstNonNanTick;

  late bool _isClosedInitially;

  /// We consider closed state as when the tick in NOT in the zone area. We take this and
  /// [_isClosed] to know when to complete a zone fill path and add it to the [paths].
  ///
  /// E.g: If * be the tick and for top zones.
  ///
  /// ---------- Is in the [_isClosed] = `true` state and we know after touching
  ///  *          the line we're gonna start creating the path.
  ///
  ///       *
  ///     /###
  /// --/------- Is in the [_isClosed] = `false` state and we know after touching
  ///  *          the line we're gonna complete the current path and add it to the [paths].
  bool get isClosedInitially => _isClosedInitially;

  late bool _isClosed;

  /// Current state of the fill path whether is closed or not.
  /// Refer to [isClosedInitially].
  bool get isClosed => _isClosed;

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

  Path? _currentFillPath;

  /// Indicates that the [series] data line has ever touched the horizontal line.
  bool _touchedTheLine = false;

  /// Considers adding a new tick to update the [_currentFillPath] in the process of
  /// creating current zone [DataPathInfo].
  ///
  /// Once a zone fill area is create, a [DataPathInfo] will be instantiated for it
  /// and will be added to [paths] list.
  void addTick(
    Tick tick,
    int index,
    Offset tickPosition,
    EpochToX epochToX,
    QuoteToY quoteToY,
  ) {
    _rectPath ??= getLineRect(canvasSize, epochToX, quoteToY);
    _currentFillPath ??= Path()..moveTo(0, quoteToY(lineValue));
    _currentFillPath?.lineTo(tickPosition.dx, tickPosition.dy);

    if (_isClosed && isOnZoneArea(tick)) {
      _touchedTheLine = true;
      _isClosed = false;
    }

    if (!_isClosed && !isOnZoneArea(tick)) {
      _isClosed = true;

      if (index == series.visibleEntries.endIndex - 1) {
        _completeLastTickArea(tickPosition, quoteToY);
      }

      _addIntersectionToPaths();
      _currentFillPath = Path()..moveTo(tickPosition.dx, tickPosition.dy);
      return;
    }

    if (index == series.visibleEntries.endIndex - 1 &&
        (!_isClosedInitially || _touchedTheLine)) {
      _completeLastTickArea(tickPosition, quoteToY);

      _addIntersectionToPaths();
    }
  }

  void _completeLastTickArea(Offset tickPosition, QuoteToY quoteToY) {
    _currentFillPath!.lineTo(tickPosition.dx, quoteToY(lineValue));
  }

  void _addIntersectionToPaths() {
    final Path areaPath =
        Path.combine(PathOperation.intersect, _rectPath!, _currentFillPath!);

    _paths.add(DataPathInfo(areaPath, _paint));
  }

  /// Indicates whether the [tick] is on zones area and should be involved
  /// in creating a zone.
  @protected
  bool isOnZoneArea(Tick tick);

  /// Gets the path of the rectangle that will be intersected with the [_currentFillPath]
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
  /// |             The Rectangle             |
  /// |          ____                         |
  /// |         /####\ intersected fill area  |
  /// ---------/-----|------------------------ -> The horizontal line
  ///    _____/       \___
  ///  _/                 \______ -> The [series] data line
  Path getLineRect(Size canvasSize, EpochToX epochToX, QuoteToY quoteToY);
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
          series: series,
          canvasSize: canvasSize,
          lineValue: lineValue,
          zonePaint: zonePaint,
        );

  @override
  bool isOnZoneArea(Tick tick) => tick.quote >= lineValue;

  @override
  Path getLineRect(Size canvasSize, EpochToX epochToX, QuoteToY quoteToY) =>
      Path()
        ..addRect(
          Rect.fromLTRB(
            _firstNonNanTick.entry.quote.isNaN
                ? 0
                : epochToX(series.getEpochOf(
                    _firstNonNanTick.entry,
                    _firstNonNanTick.index,
                  )),
            0,
            canvasSize.width,
            quoteToY(lineValue),
          ),
        );
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
          series: series,
          canvasSize: canvasSize,
          lineValue: lineValue,
          zonePaint: zonePaint,
        );

  @override
  bool isOnZoneArea(Tick tick) => tick.quote <= lineValue;

  @override
  Path getLineRect(Size canvasSize, EpochToX epochToX, QuoteToY quoteToY) =>
      Path()
        ..addRect(
          Rect.fromLTRB(
            _firstNonNanTick.entry.quote.isNaN
                ? 0
                : epochToX(series.getEpochOf(
                    _firstNonNanTick.entry,
                    _firstNonNanTick.index,
                  )),
            quoteToY(lineValue),
            canvasSize.width,
            canvasSize.height,
          ),
        );
}

class DataPathInfo {
  DataPathInfo(this.path, this.paint);
  final Path path;
  final Paint paint;
}
