import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crosshair_dot_painter.dart';
import 'crosshair_line_painter.dart';

///
class IndexBaseCrossHair extends StatefulWidget {
  ///
  const IndexBaseCrossHair({
    required this.quoteToY,
    required this.indexToX,
    required this.xToIndex,
    required this.ticks,
    Key? key,
  }) : super(key: key);

  ///
  final QuoteToY quoteToY;

  ///
  final double Function(int) indexToX;

  ///
  final double Function(double x) xToIndex;

  ///
  final List<Tick> ticks;

  @override
  _IndexBaseCrossHairState createState() => _IndexBaseCrossHairState();
}

class _IndexBaseCrossHairState extends State<IndexBaseCrossHair>
    with SingleTickerProviderStateMixin {
  int? _crossHairIndex;
  late GestureManagerState gestureManager;

  late AnimationController _crossHairAnimationController;

  @override
  void initState() {
    super.initState();

    _crossHairAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    gestureManager = context.read<GestureManagerState>()
      ..registerCallback(_onLongPressStart)
      ..registerCallback(_onLongPressUpdate)
      ..registerCallback(_onLongPressEnd);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPressStart: _onLongPressStart,
        onLongPressMoveUpdate: _onLongPressUpdate,
        onLongPressEnd: _onLongPressEnd,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              AnimatedBuilder(
            animation: _crossHairAnimationController,
            builder: (_, __) => Opacity(
              opacity: _crossHairAnimationController.value,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (_crossHairIndex != null)
                    Positioned(
                      left: widget.indexToX(_crossHairIndex!),
                      child: CustomPaint(
                        size: Size(1, constraints.maxHeight),
                        painter: const CrosshairLinePainter(),
                      ),
                    ),
                  if (_crossHairIndex != null)
                    Positioned(
                      top:
                          widget.quoteToY(widget.ticks[_crossHairIndex!].quote),
                      left: widget.indexToX(_crossHairIndex!),
                      child: CustomPaint(
                        size: Size(1, constraints.maxHeight),
                        painter: const CrosshairDotPainter(),
                      ),
                    ),
                  if (_crossHairIndex != null)
                    Positioned(
                      top: 8,
                      bottom: 0,
                      width: constraints.maxWidth,
                      left: widget.indexToX(_crossHairIndex!) -
                          constraints.maxWidth / 2,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text('${widget.ticks[_crossHairIndex!].quote}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  void _onLongPressStart(LongPressStartDetails details) {
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
    _crossHairAnimationController.forward();
  }

  void _onLongPressUpdate(LongPressMoveUpdateDetails details) {
    final Offset position = details.localPosition;
    _updateCrossHairToPosition(position.dx);
  }

  void _updateCrossHairToPosition(double x) => setState(
        () => _crossHairIndex = findClosestIndex(
          widget.xToIndex(x),
          widget.ticks,
        ),
      );

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    await _crossHairAnimationController.reverse(from: 1);
    setState(() => _crossHairIndex = null);
  }
}
