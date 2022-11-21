import 'package:deriv_chart/deriv_chart.dart';
import 'package:deriv_chart/src/deriv_chart/chart/custom_painters/chart_painter.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/models/animation_info.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/multiple_animated_builder.dart';
import 'package:deriv_chart/src/deriv_chart/chart/x_axis/x_axis_model.dart';
import 'package:deriv_chart/src/models/chart_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Layer with barriers.
class BarrierArea extends StatefulWidget {
  /// Initializes marker area.
  const BarrierArea({
    required this.barriers,
    required this.quoteToCanvasY,
    required this.quoteFromCanvasY,
    required this.enableVerticalScale,
    required this.disableVerticalScale,
    Key? key,
  }) : super(key: key);

  /// The list of barriers.
  final List<Barrier> barriers;

  /// Conversion function for converting quote to chart's canvas' Y position.
  final double Function(double) quoteToCanvasY;

  /// Conversion function for converting quote from chart's canvas' Y position.
  final double Function(double) quoteFromCanvasY;

  /// Enables vertical scroll.
  final VoidCallback enableVerticalScale;

  /// Disables vertical scroll.
  final VoidCallback disableVerticalScale;

  @override
  _BarrierAreaState createState() => _BarrierAreaState();
}

class _BarrierAreaState extends State<BarrierArea>
    with TickerProviderStateMixin {
  late GestureManagerState gestureManager;
  String? _barrierDragId;
  double? _lastDragQuote;

  SystemMouseCursor _cursor = SystemMouseCursors.basic;

  late AnimationController _currentTickAnimationController;

  /// The animation of the current tick.
  late Animation<double> currentTickAnimation;

  @override
  void initState() {
    super.initState();
    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onDragStart)
      ..registerCallback(_onDragUpdate)
      ..registerCallback(_onDragEnd);
    _setupCurrentTickAnimation();
  }

  @override
  void didUpdateWidget(BarrierArea barrierArea) {
    super.didUpdateWidget(barrierArea);
    _playNewTickAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    gestureManager
      ..removeCallback(_onDragStart)
      ..removeCallback(_onDragUpdate)
      ..removeCallback(_onDragEnd);
    _currentTickAnimationController.dispose();
  }

  void _playNewTickAnimation() {
    if (!_currentTickAnimationController.isAnimating) {
      _currentTickAnimationController
        ..reset()
        ..forward();
    }
  }

  void _setupCurrentTickAnimation() {
    _currentTickAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    currentTickAnimation = CurvedAnimation(
      parent: _currentTickAnimationController,
      curve: Curves.easeOut,
    );
  }

  void _onDragStart(ScaleStartDetails details) {
    for (final Barrier barrier in widget.barriers) {
      if (barrier.labelTapArea.contains(details.focalPoint)) {
        _barrierDragId = barrier.id;
        _cursor = SystemMouseCursors.grabbing;
        return;
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_barrierDragId != null) {
      for (final Barrier barrier in widget.barriers) {
        if (barrier.id == _barrierDragId) {
          widget.disableVerticalScale();
          final double newQuote = widget
              .quoteFromCanvasY(details.localPosition.dy + details.delta.dy);
          _lastDragQuote = newQuote;

          barrier.onDrag?.call(newQuote, false);
          return;
        }
      }
    }
  }

  void _onDragEnd(ScaleEndDetails details) {
    if (_barrierDragId != null) {
      widget.enableVerticalScale();

      for (final Barrier barrier in widget.barriers) {
        if (barrier.id == _barrierDragId) {
          barrier.onDrag?.call(_lastDragQuote!, true);
          _cursor = SystemMouseCursors.grab;
          continue;
        }
      }
    }
    _barrierDragId = null;
  }

  void _onHover(PointerEvent details) {
    _cursor = SystemMouseCursors.basic;

    for (final Barrier barrier in widget.barriers) {
      if (barrier.labelTapArea.contains(details.position)) {
        _cursor = SystemMouseCursors.grab;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final XAxisModel xAxis = context.watch<XAxisModel>();

    return MultipleAnimatedBuilder(
      animations: <Animation<double>>[
        currentTickAnimation,
      ],
      builder: (BuildContext context, _) => MouseRegion(
        cursor: _cursor,
        onHover: _onHover,
        child: Stack(fit: StackFit.expand, children: <Widget>[
          ...widget.barriers.map((Barrier annotation) {
            annotation.update(xAxis.leftBoundEpoch, xAxis.rightBoundEpoch);

            return CustomPaint(
              key: ValueKey<String>(annotation.id),
              painter: ChartPainter(
                animationInfo: AnimationInfo(
                  currentTickPercent: currentTickAnimation.value,
                ),
                chartData: annotation,
                chartConfig: context.watch<ChartConfig>(),
                theme: context.watch<ChartTheme>(),
                epochToCanvasX: xAxis.xFromEpoch,
                quoteToCanvasY: widget.quoteToCanvasY,
              ),
            );
          }).toList()
        ]),
      ),
    );
  }
}
