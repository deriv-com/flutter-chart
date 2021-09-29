import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/data_visualization/chart_data.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:flutter/cupertino.dart';
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
  late Animation<double> _crossHairFadeAnimation;

  @override
  void initState() {
    super.initState();

    _crossHairAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _crossHairFadeAnimation = CurvedAnimation(
      parent: _crossHairAnimationController,
      curve: Curves.easeInOut,
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
          builder: (BuildContext context, BoxConstraints constraints) {
            if (_crossHairIndex == null) {
              return const SizedBox.shrink();
            }

            return FadeTransition(
              opacity: _crossHairFadeAnimation,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    top: widget.quoteToY(widget.ticks[_crossHairIndex!].quote),
                    left: widget.indexToX(_crossHairIndex!),
                    child: CustomPaint(
                      size: Size(1, constraints.maxHeight),
                      painter: const CrosshairDotPainter(),
                    ),
                  ),
                  Positioned(
                    width: constraints.maxWidth,
                    left: widget.indexToX(_crossHairIndex!) -
                        constraints.maxWidth / 2,
                    child: Column(
                      children: <Widget>[
                        _buildCrossHairDetail(),
                        CustomPaint(
                          size: Size(1, constraints.maxHeight),
                          painter: const CrosshairLinePainter(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Align _buildCrossHairDetail() => Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Color(0xFF323738),
          ),
          child: Text('${widget.ticks[_crossHairIndex!].quote}'),
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
