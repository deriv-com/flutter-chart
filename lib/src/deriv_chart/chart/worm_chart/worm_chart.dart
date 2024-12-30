import 'dart:ui';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/find.dart';
import 'package:deriv_chart/src/deriv_chart/chart/crosshair/index_base_cross_hair.dart';
import 'package:deriv_chart/src/deriv_chart/chart/gestures/gesture_manager.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/conversion.dart';
import 'package:deriv_chart/src/deriv_chart/chart/helpers/functions/helper_functions.dart';
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
    this.pipSize = 4,
    this.zoomFactor = 0.05,
    this.updateAnimationDuration = Duration.zero,
    this.lineStyle = const LineStyle(),
    this.applyTickIndicatorsPadding = false,
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
    this.topPadding = 10,
    this.bottomPadding = 10,
    this.crossHairEnabled = false,
    this.onTap,
    Key? key,
  }) : super(key: key);

  /// The ticks list to show.
  final List<Tick> ticks;

  /// Indicates the proportion of the horizontal space that each tick is going
  /// to take.
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

  /// Number of decimals when showing the price of a tick on cross-hair.
  final int pipSize;

  /// Whether to apply padding around tick indicator dots (highest, lowest,
  /// last tick).
  ///
  /// Since for applying padding we have used [Canvas.saveLayer] for now and
  /// in case of performance it's relatively expensive, it can be disabled.
  final bool applyTickIndicatorsPadding;

  /// Will be called when the worm chart is tapped.
  ///
  /// This behaviour shouldn't be part of the WormChart but currently when we
  /// wrap the [WormChart] with GestureDetector the gesture functionality of it
  /// will conflict with the worm chart itself and the cross hair's position
  /// won't be correct when long press started.
  /// For now having this callback here in worm chart until
  /// a more solid solution is found.
  final VoidCallback? onTap;

  @override
  _WormChartState createState() => _WormChartState();
}

class _WormChartState extends State<WormChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _rightIndexAnimationController;

  late double _leftIndex;
  late double _minValue;
  late double _maxValue;

  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _rightIndexAnimationController = AnimationController.unbounded(
      vsync: this,
      duration: widget.updateAnimationDuration,
      value: widget.ticks.length.toDouble() + 1,
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

  /// Converts quote value to y position.
  double _quoteToY(double quote) => quoteToCanvasY(
        quote: quote,
        topBoundQuote: _maxValue,
        bottomBoundQuote: _minValue,
        canvasHeight: _chartSize.height,
        topPadding: widget.topPadding,
        bottomPadding: widget.bottomPadding,
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _chartSize = Size(constraints.maxWidth, constraints.maxHeight);

          return AnimatedBuilder(
            animation: _rightIndexAnimationController,
            builder: (_, __) {
              if (!_chartSize.isGraterThanZero ||
                  widget.ticks.length < 2 ||
                  widget.topPadding + widget.bottomPadding >=
                      0.9 * _chartSize.height) {
                return const SizedBox.shrink();
              }

              _leftIndex = _rightIndexAnimationController.value -
                  _chartSize.width / (widget.zoomFactor * _chartSize.width);

              final int lowerIndex =
                  _searchLowerIndex(widget.ticks, _leftIndex);
              final int upperIndex = _searchUpperIndex(
                      widget.ticks, _rightIndexAnimationController.value) -
                  1;

              final MinMaxIndices minMax =
                  getMinMaxIndex(widget.ticks, lowerIndex, upperIndex);

              _minValue = widget.ticks[minMax.minIndex].quote;
              _maxValue = widget.ticks[minMax.maxIndex].quote;

              return GestureManager(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ClipRect(
                      child: Container(
                        constraints: const BoxConstraints.expand(),
                        child: CustomPaint(
                          painter: WormChartPainter(
                            widget.ticks,
                            indexToX: _indexToX,
                            quoteToY: _quoteToY,
                            minMax: minMax,
                            lineStyle: widget.lineStyle,
                            highestTickStyle: widget.highestTickStyle,
                            lowestTickStyle: widget.lowestTickStyle,
                            lastTickStyle: widget.lastTickStyle,
                            startIndex: lowerIndex,
                            endIndex: upperIndex,
                            applyTickIndicatorsPadding:
                                widget.applyTickIndicatorsPadding,
                          ),
                        ),
                      ),
                    ),
                    IndexBaseCrossHair(
                      indexToX: _indexToX,
                      quoteToY: _quoteToY,
                      xToIndex: _xToIndex,
                      ticks: widget.ticks,
                      enabled: widget.crossHairEnabled,
                      pipSize: widget.pipSize,
                      onTap: widget.onTap,
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
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

extension _IsGreaterThanZero on Size {
  bool get isGraterThanZero => width > 0 && height > 0;
}
