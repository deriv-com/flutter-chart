import 'dart:ui' as ui;
import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/paint_functions/paint_text.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:flutter/material.dart';

/// A lightweight worm chart widget.
class WormChart extends StatefulWidget {
  /// Initializes
  const WormChart({
    required this.ticks,
    this.zoomFactor = 0.05,
    this.updateAnimationDuration = Duration.zero,
    this.lineStyle = const LineStyle(),
    this.highestTickStyle = const ScatterStyle(
      color: Color(0xFF00A79E),
      radius: 3,
    ),
    this.lowestTickStyle = const ScatterStyle(
      color: Color(0xFFCC2E3D),
      radius: 3,
    ),
    this.lastTickStyle = const ScatterStyle(
      color: Color(0xFF377CFC),
      radius: 3,
    ),
    this.topPadding = 5,
    this.bottomPadding = 20,
    this.crossHairEnabled = false,
    Key? key,
  }) : super(key: key);

  /// The ticks list to show.
  final List<Tick> ticks;

  /// Indicates the proportion of the horizontal space that each tick is going to take.
  ///
  /// Default is 0.05 which means each tick occupies 5% of the horizontal space,
  /// and at most 20 of most recent ticks will be visible.
  final double zoomFactor;

  /// The duration of sliding animation as the chart gets updated.
  ///
  /// Default is zero meaning the animation is disabled.
  final Duration updateAnimationDuration;

  /// Chart's top padding.
  final double topPadding;

  /// Chart's bottom padding.
  final double bottomPadding;

  /// WormChart's line style.
  final LineStyle lineStyle;

  /// The style of the circle which is the tick with the highest [Tick.quote].
  final ScatterStyle highestTickStyle;

  /// The style of the circle which is the tick with the lowest [Tick.quote].
  final ScatterStyle lowestTickStyle;

  /// The style of the circle showing the last tick.
  final ScatterStyle? lastTickStyle;

  /// Whether the cross-hair feature is enabled or not.
  final bool crossHairEnabled;

  @override
  _WormChartState createState() => _WormChartState();
}

class _WormChartState extends State<WormChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _rightIndexAnimationController;

  late double _leftIndex;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _rightIndexAnimationController = AnimationController.unbounded(
      vsync: this,
      duration: widget.updateAnimationDuration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant WormChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.ticks.isNotEmpty) {
      if (_rightIndexAnimationController.value == 1) {
        _rightIndexAnimationController.value =
            widget.ticks.length.toDouble() + 1;
      } else {
        _rightIndexAnimationController
            .animateTo(widget.ticks.length.toDouble() + 1);
      }
    }
  }

  /// Converts index to x coordinate.
  double _indexToX(int index) => lerpDouble(
        0,
        _chartSize.width,
        (index - _leftIndex) /
            (_rightIndexAnimationController.value - _leftIndex),
      )!;

  /// Converts x coordinate to index value.
  double _xToIndex(double x) =>
      x *
          (_rightIndexAnimationController.value - _leftIndex) ~/
          _chartSize.width +
      _leftIndex;

  int? _crossHairIndex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _chartSize = Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: _rightIndexAnimationController,
            builder: (_, __) {
              if (_chartSize == Size.zero || widget.ticks.length < 2) {
                return const SizedBox.shrink();
              }

              _leftIndex = _rightIndexAnimationController.value -
                  _chartSize.width / (widget.zoomFactor * _chartSize.width);

              final int lowerIndex =
                  _searchLowerIndex(widget.ticks, _leftIndex);
              final int upperIndex = _searchUpperIndex(
                      widget.ticks, _rightIndexAnimationController.value) -
                  1;
              return ClipRect(
                child: IgnorePointer(
                  ignoring: !widget.crossHairEnabled,
                  child: GestureDetector(
                    onLongPressStart: _onLongPressStart,
                    onLongPressMoveUpdate: _onLongPressUpdate,
                    onLongPressEnd: _onLongPressEnd,
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      child: CustomPaint(
                        painter: _WormChartPainter(
                          widget.ticks,
                          indexToX: _indexToX,
                          lineStyle: widget.lineStyle,
                          highestTickStyle: widget.highestTickStyle,
                          lowestTickStyle: widget.lowestTickStyle,
                          lastTickStyle: widget.lastTickStyle,
                          topPadding: widget.topPadding,
                          bottomPadding: widget.bottomPadding,
                          startIndex: lowerIndex,
                          endIndex: upperIndex,
                          crossHairIndex: _crossHairIndex,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

  void _onLongPressStart(LongPressStartDetails details) {
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
  }

  void _updateCrossHairToPosition(double x) => setState(
        () => _crossHairIndex = findClosestIndex(
          _xToIndex(x),
          widget.ticks,
        ),
      );

  void _onLongPressEnd(LongPressEndDetails details) =>
      setState(() => _crossHairIndex = null);
}

class _WormChartPainter extends CustomPainter {
  _WormChartPainter(
    this.ticks, {
    required this.lineStyle,
    required this.highestTickStyle,
    required this.lowestTickStyle,
    required this.indexToX,
    required this.startIndex,
    required this.endIndex,
    this.crossHairIndex,
    this.lastTickStyle,
    this.topPadding = 0,
    this.bottomPadding = 0,
  })  : linePaint = Paint()
          ..color = lineStyle.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineStyle.thickness,
        highestCirclePaint = Paint()
          ..color = highestTickStyle.color
          ..style = PaintingStyle.fill,
        lowestCirclePaint = Paint()
          ..color = lowestTickStyle.color
          ..style = PaintingStyle.fill;

  final List<Tick> ticks;

  final int startIndex;
  final int endIndex;

  final Paint linePaint;
  final Paint highestCirclePaint;
  final Paint lowestCirclePaint;

  final ScatterStyle highestTickStyle;

  final ScatterStyle lowestTickStyle;

  final ScatterStyle? lastTickStyle;

  final int? crossHairIndex;

  final LineStyle lineStyle;

  final double topPadding;
  final double bottomPadding;

  final double Function(int) indexToX;

  @override
  void paint(Canvas canvas, Size size) {
    assert(topPadding + bottomPadding < 0.9 * size.height);

    if (endIndex - startIndex <= 2 ||
        startIndex < 0 ||
        endIndex >= ticks.length) {
      return;
    }

    final MinMaxIndices minMax = getMinMaxIndex(ticks, startIndex, endIndex);

    final int minIndex = minMax.minIndex;
    final int maxIndex = minMax.maxIndex;
    final double min = ticks[minIndex].quote;
    final double max = ticks[maxIndex].quote;

    Path? linePath;
    late Offset currentPosition;

    for (int i = startIndex; i <= endIndex; i++) {
      final Tick tick = ticks[i];

      final double x = indexToX(i);
      final double y = _quoteToY(
        tick.quote,
        max,
        min,
        size.height,
        topPadding: topPadding,
        bottomPadding: bottomPadding,
      );
      currentPosition = Offset(x, y);

      if (i == ticks.length - 1 && lastTickStyle != null) {
        _drawLastTickCircle(canvas, currentPosition);
      }

      _drawCircleIfMinMax(currentPosition, i, minIndex, maxIndex, canvas);

      if (linePath == null) {
        linePath = Path()..moveTo(x, y);
        continue;
      }

      linePath.lineTo(x, y);

      if (i == crossHairIndex) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        paintText(
          canvas,
          text: tick.quote.toString(),
          anchor: Offset(x, 10),
          style: const TextStyle(),
        );
      }
    }

    canvas.drawPath(linePath!, linePaint);

    if (lineStyle.hasArea) {
      linePath
        ..lineTo(currentPosition.dx, size.height)
        ..lineTo(linePath.getBounds().left, size.height);
      _drawArea(canvas, size, linePath, lineStyle);
    }
  }

  void _drawLastTickCircle(ui.Canvas canvas, ui.Offset currentPosition) =>
      canvas.drawCircle(
          currentPosition,
          lastTickStyle!.radius,
          Paint()
            ..color = lastTickStyle!.color
            ..style = PaintingStyle.fill);

  void _drawArea(
    Canvas canvas,
    Size size,
    Path linePath,
    LineStyle style,
  ) {
    final Paint areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        <Color>[
          style.color.withOpacity(0.2),
          style.color.withOpacity(0.001),
        ],
      );

    canvas.drawPath(linePath, areaPaint);
  }

  void _drawCircleIfMinMax(
    Offset position,
    int index,
    int minIndex,
    int maxIndex,
    Canvas canvas,
  ) {
    if (index == maxIndex) {
      canvas.drawCircle(position, highestTickStyle.radius, highestCirclePaint);
    }

    if (index == minIndex) {
      canvas.drawCircle(position, lowestTickStyle.radius, lowestCirclePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WormChartPainter oldDelegate) => true;
}

// TODO(NA): Extract X-Axis conversions later to be able to support both epoch and index
double _quoteToY(
  double quote,
  double max,
  double min,
  double height, {
  double topPadding = 0,
  double bottomPadding = 0,
}) =>
    quoteToCanvasY(
      quote: quote,
      topBoundQuote: max,
      bottomBoundQuote: min,
      canvasHeight: height,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
    );

int _searchLowerIndex(List<Tick> entries, double leftIndex) {
  if (leftIndex < 0) {
    return 0;
  }
  if (leftIndex > entries.length - 1) {
    return -1;
  }

  final int closest = findClosestIndex(leftIndex, entries);

  return closest <= leftIndex
      ? closest
      : (closest - 1 < 0 ? closest : closest - 1);
}

int _searchUpperIndex(List<Tick> entries, double rightIndex) {
  if (rightIndex < 0) {
    return -1;
  }
  if (rightIndex > entries.length - 1) {
    return entries.length;
  }

  final int closest = findClosestIndex(rightIndex, entries);

  return closest >= rightIndex
      ? closest
      : (closest + 1 > entries.length ? closest : closest + 1);
}
