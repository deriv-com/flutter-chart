import 'dart:ui' as ui;
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
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
    this.offsetAnimationDuration = Duration.zero,
    this.lineStyle = const LineStyle(),
    this.highestTickStyle = const ScatterStyle(
      color: Color(0xFF00A79E),
      radius: 2,
    ),
    this.lowestTickStyle = const ScatterStyle(
      color: Color(0xFFCC2E3D),
      radius: 2,
    ),
    this.lastTickStyle,
    this.topPadding = 2,
    this.bottomPadding = 2,
    Key? key,
  }) : super(key: key);

  /// The ticks list to show.
  final List<Tick> ticks;

  /// Indicates the proportion of the horizontal space that each tick is going to take.
  ///
  /// Default is 0.02 which means each tick occupies 2% of the horizontal space,
  /// and at most 50 of most recent ticks will be visible.
  final double zoomFactor;

  /// The duration of sliding animation as the chart gets updated.
  ///
  /// Default is zero meaning the animation is disabled.
  final Duration offsetAnimationDuration;

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

  @override
  _WormChartState createState() => _WormChartState();
}

class _WormChartState extends State<WormChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.offsetAnimationDuration,
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant WormChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.offsetAnimationDuration != Duration.zero) {
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) => ClipRect(
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: _WormChartPainter(
                widget.ticks,
                widget.zoomFactor,
                offsetAnimationValue: _animation.value,
                lineStyle: widget.lineStyle,
                highestTickStyle: widget.highestTickStyle,
                lowestTickStyle: widget.lowestTickStyle,
                lastTickStyle: widget.lastTickStyle,
                topPadding: widget.topPadding,
                bottomPadding: widget.bottomPadding,
              ),
            ),
          ),
        ),
      );
}

class _WormChartPainter extends CustomPainter {
  _WormChartPainter(
    this.ticks,
    this.zoomFactor, {
    required this.lineStyle,
    required this.highestTickStyle,
    required this.lowestTickStyle,
    this.lastTickStyle,
    this.offsetAnimationValue = 1,
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

  final double zoomFactor;

  final Paint linePaint;
  final Paint highestCirclePaint;
  final Paint lowestCirclePaint;

  final ScatterStyle highestTickStyle;

  final ScatterStyle lowestTickStyle;

  final ScatterStyle? lastTickStyle;

  /// Chart will be shifted to the right by `offset * (distance between two consecutive ticks)`.
  ///
  /// A number between 0.0 to 1.0.
  final double offsetAnimationValue;

  final LineStyle lineStyle;

  final double topPadding;
  final double bottomPadding;

  @override
  void paint(Canvas canvas, Size size) {
    assert(topPadding + bottomPadding < 0.9 * size.height);

    if (ticks.length < 2) {
      return;
    }

    final double ticksDistanceInPx = zoomFactor * size.width;

    final int numberOfVisibleTicks = (size.width / ticksDistanceInPx).floor();

    final int startIndex = numberOfVisibleTicks >= ticks.length
        ? 0
        : ticks.length - numberOfVisibleTicks;

    final List<int> minMax = getMinMaxIndex(ticks, startIndex);

    final int minIndex = minMax[0];
    final int maxIndex = minMax[1];
    final double min = ticks[minIndex].quote;
    final double max = ticks[maxIndex].quote;

    Path? linePath;
    late Offset currentPosition;

    for (int i = ticks.length - 1; i >= startIndex; i--) {
      final Tick tick = ticks[i];
      if (!tick.quote.isNaN) {
        final double y = _quoteToY(tick.quote, max, min, size.height,
            topPadding: topPadding, bottomPadding: bottomPadding);

        final double x = size.width -
            (ticks.length - i) * ticksDistanceInPx +
            offsetAnimationValue * ticksDistanceInPx;

        currentPosition = Offset(x, y);

        if (i == ticks.length - 1 && lastTickStyle != null) {
          _drawLastTickCircle(canvas, currentPosition);
        }

        if (linePath == null) {
          linePath = Path()..moveTo(x, y);
          _drawCircleIfMinMax(
            currentPosition,
            i,
            minIndex,
            maxIndex,
            canvas,
          );
          continue;
        }

        linePath.lineTo(x, y);

        _drawCircleIfMinMax(currentPosition, i, minIndex, maxIndex, canvas);
      }
    }

    canvas.drawPath(linePath!, linePaint);

    if (lineStyle.hasArea) {
      linePath
        ..lineTo(currentPosition.dx, size.height)
        ..lineTo(linePath.getBounds().right, size.height);
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
