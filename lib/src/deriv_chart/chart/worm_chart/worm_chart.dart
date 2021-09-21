import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/models/tick.dart';
import 'package:deriv_chart/src/theme/painting_styles/line_style.dart';
import 'package:deriv_chart/src/theme/painting_styles/scatter_style.dart';
import 'package:flutter/material.dart';

import 'worm_chart_painter.dart';

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
                        painter: WormChartPainter(
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

/// A model class to hod the information needed to paint a [Tick] indicator on the
/// chart's canvas.
class TickIndicatorModel {
  /// Initializes
  const TickIndicatorModel(this.position, this.style, this.paint);

  /// The position of this tick indicator.
  final Offset position;

  /// The style which has the information of how this tick indicator should look like.
  final ScatterStyle style;

  /// The paint object which is used for painting on the canvas.
  final Paint paint;
}
