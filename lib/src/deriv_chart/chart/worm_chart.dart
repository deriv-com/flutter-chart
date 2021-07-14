import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:flutter/material.dart';

///
class WormChart extends StatefulWidget {
  /// Initializes
  const WormChart({
    required this.ticks,
    Key? key,
    this.zoomFactor = 0.02,
    this.offsetAnimationDuration = Duration.zero,
  }) : super(key: key);

  /// The ticks list to show.
  final List<Tick> ticks;

  /// Indicates the proportion of the horizontal space that each tick is going to take.
  ///
  /// Default is 0.02 which means each tick occupies 2% of the horizontal space,
  /// and at most 10 ticks will be visible.
  final double zoomFactor;

  ///
  final Duration offsetAnimationDuration;

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

    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) => ClipRect(
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: _WormChartPainter(
                widget.ticks,
                widget.zoomFactor,
                offset: _animation.value,
              ),
            ),
          ),
        ),
      );
}

class _WormChartPainter extends CustomPainter {
  _WormChartPainter(this.ticks, this.zoomFactor, {this.offset = 1})
      : _paint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke;

  final List<Tick> ticks;

  final double zoomFactor;

  final Paint _paint;

  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    if (ticks.length < 2) {
      return;
    }

    final double ticksDistanceInPx = zoomFactor * size.width;

    final int numberOfVisibleTicks = (size.width / ticksDistanceInPx).floor();

    final int startIndex = numberOfVisibleTicks >= ticks.length
        ? 0
        : ticks.length - numberOfVisibleTicks;

    final List<double> minMax = _getMinMax(ticks, startIndex);

    final double min = minMax[0];
    final double max = minMax[1];

    Path? linePath;

    for (int i = ticks.length - 1; i >= startIndex; i--) {
      final Tick tick = ticks[i];
      if (!tick.quote.isNaN) {
        final double y = _quoteToY(tick.quote, max, min, size.height);
        final double x = size.width -
            (ticks.length - i) * ticksDistanceInPx +
            offset * ticksDistanceInPx;

        final Offset position = Offset(x, y);

        if (linePath == null) {
          linePath = Path()..moveTo(x, y);
          _drawCircleIfMinMax(tick, position, min, max, canvas);
          continue;
        }

        linePath.lineTo(x, y);

        _drawCircleIfMinMax(tick, position, min, max, canvas);
      }
    }
    canvas.drawPath(linePath!, _paint);
  }

  void _drawCircleIfMinMax(
    Tick tick,
    Offset position,
    double min,
    double max,
    Canvas canvas,
  ) {
    if (tick.quote == max) {
      canvas.drawCircle(
        position,
        2,
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
      );
    }

    if (tick.quote == min) {
      canvas.drawCircle(
        position,
        2,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true; // TODO(NA): Return the correct value depending on the series.
}

List<double> _getMinMax(List<Tick> ticks, int startIndex, [int? endIndex]) {
  final int end = endIndex ?? ticks.length - 1;
  double min = ticks.last.quote;
  double max = ticks.last.quote;

  for (int i = startIndex; i < end; i++) {
    final Tick tick = ticks[i];

    if (tick.quote > max) {
      max = tick.quote;
    }
    if (tick.quote < min) {
      min = tick.quote;
    }
  }

  return <double>[min, max];
}

double _quoteToY(double quote, double max, double min, double height) =>
    quoteToCanvasY(
      quote: quote,
      topBoundQuote: max,
      bottomBoundQuote: min,
      canvasHeight: height,
      topPadding: 2,
      bottomPadding: 2,
    );
